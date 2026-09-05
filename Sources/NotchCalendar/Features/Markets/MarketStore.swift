import Combine
import Foundation

@MainActor
final class MarketStore: ObservableObject {
    static let watchlistKey = "markets.watchlist.v1"
    static let quotesKey = "markets.quotes.v1"
    static let requestsKey = "markets.requests.v1"
    static let dailyRequestLimit = 25

    @Published private(set) var watchlist: [String]
    @Published private(set) var quotes: [String: MarketQuote] = [:]
    @Published private(set) var errors: [String: MarketError] = [:]
    @Published private(set) var notice: MarketError?
    @Published private(set) var hasAPIKey = false
    @Published private(set) var isRefreshing = false
    @Published private(set) var completedRequests = 0
    @Published private(set) var plannedRequests = 0
    @Published private(set) var remainingRequests = MarketStore.dailyRequestLimit
    @Published private(set) var updatedCount = 0

    private let defaults: UserDefaults
    private let keyStorage: any MarketKeyStorage
    private let client: any MarketQuoteClient
    private let now: () -> Date
    private let requestSpacing: TimeInterval
    private var requestDates: [Date] = []
    private var refreshTask: Task<Void, Never>?
    private var refreshTaskID: UUID?
    private var generation = 0

    init(defaults: UserDefaults = .standard,
         keyStorage: any MarketKeyStorage = MarketKeychain(),
         client: any MarketQuoteClient = AlphaVantageMarketClient(),
         now: @escaping () -> Date = Date.init,
         requestSpacing: TimeInterval = 2) {
        self.defaults = defaults
        self.keyStorage = keyStorage
        self.client = client
        self.now = now
        self.requestSpacing = max(0, requestSpacing)
        watchlist = MarketSymbol.cleanWatchlist(defaults.stringArray(forKey: Self.watchlistKey) ?? ["AAPL", "MSFT", "NVDA"])
        if let data = defaults.data(forKey: Self.quotesKey), data.count <= 64 * 1_024,
           let saved = try? JSONDecoder().decode([String: MarketQuote].self, from: data) {
            quotes = saved.filter { watchlist.contains($0.key) && $0.value.symbol == $0.key && $0.value.isValid(at: now()) }
        }
        if let timestamps = defaults.array(forKey: Self.requestsKey) as? [Double] {
            requestDates = timestamps.filter { $0.isFinite && $0 > 0 }
                .map(Date.init(timeIntervalSince1970:)).sorted()
        }
        updateBudget()
        do { hasAPIKey = try keyStorage.read().map(AlphaVantageMarketClient.validKey) ?? false }
        catch { notice = .keychain }
        persistWatchlist()
    }

    @discardableResult
    func add(_ raw: String) -> Bool {
        guard let symbol = MarketSymbol.normalize(raw) else { notice = .invalidSymbol; return false }
        guard !watchlist.contains(symbol) else { notice = .duplicateSymbol; return false }
        guard watchlist.count < MarketSymbol.maximumWatchlistCount else { notice = .watchlistFull; return false }
        watchlist.append(symbol)
        notice = nil
        persistWatchlist()
        return true
    }

    func remove(_ symbol: String) {
        cancelRefresh()
        watchlist.removeAll { $0 == symbol }
        quotes.removeValue(forKey: symbol)
        errors.removeValue(forKey: symbol)
        persistWatchlist()
        persistQuotes()
    }

    func move(_ symbol: String, offset: Int) {
        guard let index = watchlist.firstIndex(of: symbol), watchlist.indices.contains(index + offset) else { return }
        watchlist.swapAt(index, index + offset)
        persistWatchlist()
    }

    @discardableResult
    func saveKey(_ raw: String) -> Bool {
        let key = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard AlphaVantageMarketClient.validKey(key) else { notice = .invalidKey; return false }
        cancelRefresh()
        do {
            try keyStorage.save(key)
            hasAPIKey = true
            notice = .saved
            return true
        } catch { notice = .keychain; return false }
    }

    func removeKey() {
        cancelRefresh()
        do {
            try keyStorage.remove()
            hasAPIKey = false
            notice = nil
        } catch { notice = .keychain }
    }

    func clearCache() {
        cancelRefresh()
        quotes = [:]
        errors = [:]
        notice = nil
        defaults.removeObject(forKey: Self.quotesKey)
    }

    func startRefresh(verifyConnection: Bool = false) {
        guard !isRefreshing, refreshTaskID == nil else { return }
        let taskID = UUID()
        refreshTaskID = taskID
        refreshTask = Task { [weak self] in
            await self?.refresh(verifyConnection: verifyConnection)
            if self?.refreshTaskID == taskID {
                self?.refreshTaskID = nil
                self?.refreshTask = nil
            }
        }
    }

    func cancelRefresh() {
        generation &+= 1
        refreshTask?.cancel()
        refreshTask = nil
        refreshTaskID = nil
        isRefreshing = false
    }

    /// Only an explicit user action calls this. Cached data never starts background networking.
    func refresh(verifyConnection: Bool = false) async {
        guard !isRefreshing, !watchlist.isEmpty else { return }
        let key: String
        do {
            guard let stored = try keyStorage.read(), AlphaVantageMarketClient.validKey(stored) else {
                hasAPIKey = false; notice = .invalidKey; return
            }
            key = stored
        } catch { notice = .keychain; return }

        updateBudget()
        let candidates = verifyConnection ? Array(watchlist.prefix(1))
            : watchlist.filter { !(quotes[$0]?.isFresh(at: now()) ?? false) }
        guard !candidates.isEmpty else { notice = .allFresh; return }
        guard remainingRequests > 0 else { notice = .localQuota; return }
        generation &+= 1
        let activeGeneration = generation
        isRefreshing = true
        notice = nil
        updatedCount = 0
        completedRequests = 0
        plannedRequests = min(candidates.count, remainingRequests)
        defer {
            if generation == activeGeneration { isRefreshing = false }
        }

        for symbol in candidates {
            guard generation == activeGeneration, !Task.isCancelled else { return }
            updateBudget()
            guard remainingRequests > 0 else { notice = .localQuota; break }
            if let lastRequest = requestDates.last {
                let delay = min(requestSpacing, max(0, requestSpacing - now().timeIntervalSince(lastRequest)))
                if delay > 0 {
                    do { try await Task.sleep(for: .seconds(delay)) }
                    catch { return }
                }
            }
            guard generation == activeGeneration, !Task.isCancelled else { return }
            // Count attempts, including failed/cancelled calls, so retries cannot evade the cap.
            requestDates.append(now())
            updateBudget()
            do {
                let quote = try await client.quote(symbol: symbol, apiKey: key, at: now())
                try Task.checkCancellation()
                guard generation == activeGeneration else { return }
                guard quote.symbol == symbol, quote.isValid(at: now()) else { throw MarketError.malformedData }
                if watchlist.contains(symbol) {
                    quotes[symbol] = quote
                    errors.removeValue(forKey: symbol)
                    updatedCount += 1
                    persistQuotes()
                }
            } catch is CancellationError { return }
            catch {
                guard generation == activeGeneration, !Task.isCancelled else { return }
                let failure = error as? MarketError ?? .network
                errors[symbol] = failure
                notice = failure
                if failure == .rateLimited || failure == .invalidKey {
                    completedRequests += 1
                    break
                }
            }
            completedRequests += 1
        }
        if verifyConnection, updatedCount > 0, notice == nil { notice = .verified }
    }

    func updateBudget() {
        let date = now()
        requestDates = requestDates.filter { date.timeIntervalSince($0) < 24 * 60 * 60 }
        // Future persisted dates remain charged, preventing clock rollback from resetting quota.
        requestDates = Array(requestDates.suffix(Self.dailyRequestLimit))
        remainingRequests = max(0, Self.dailyRequestLimit - requestDates.count)
        defaults.set(requestDates.map(\.timeIntervalSince1970), forKey: Self.requestsKey)
    }

    private func persistWatchlist() { defaults.set(watchlist, forKey: Self.watchlistKey) }
    private func persistQuotes() {
        if let data = try? JSONEncoder().encode(quotes) { defaults.set(data, forKey: Self.quotesKey) }
    }
}
