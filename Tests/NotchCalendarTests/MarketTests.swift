import Foundation
import XCTest
@testable import NotchCalendar

@MainActor
final class MarketTests: XCTestCase {
    private let date = Date(timeIntervalSince1970: 1_800_000_000)

    func testSymbolsRejectExchangeSuffixesURLsAndLimitWatchlist() {
        XCTAssertEqual(MarketSymbol.normalize(" aapl \n"), "AAPL")
        for value in ["", "AAPL/", "600519", "MSFT.US", "^GSPC", "ＡAPL", "SIXLET", "A\nB"] {
            XCTAssertNil(MarketSymbol.normalize(value), value)
        }
        XCTAssertEqual(MarketSymbol.cleanWatchlist(["A", "a", "B", "C", "D", "E", "F", "G", "H", "I"]),
                       ["A", "B", "C", "D", "E", "F", "G", "H"])
    }

    func testClientDecodesDocumentedSchemaAndSafeRequest() async throws {
        let transport = MarketTestTransport(response: response(fields()))
        let client = AlphaVantageMarketClient(transport: transport)
        let quote = try await client.quote(symbol: "AAPL", apiKey: "TESTKEY123", at: date)
        XCTAssertEqual(quote.price, 204.25)
        XCTAssertEqual(quote.tradingDay, "2026-09-04")
        XCTAssertEqual(quote.volume, 123456)
        let request = await transport.lastRequest
        let components = try XCTUnwrap(request?.url.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) })
        XCTAssertEqual(components.scheme, "https")
        XCTAssertEqual(components.host, "www.alphavantage.co")
        XCTAssertEqual(components.queryItems?.first(where: { $0.name == "function" })?.value, "GLOBAL_QUOTE")
        XCTAssertNil(components.queryItems?.first(where: { $0.name == "entitlement" }))
        XCTAssertEqual(request?.timeoutInterval, 10)
        let limit = await transport.byteLimit
        XCTAssertEqual(limit, 64 * 1_024)
    }

    func testMissingOptionalRangeAndVolumeStillProvidesAQuote() throws {
        var values = fields()
        values.removeValue(forKey: "03. high")
        values.removeValue(forKey: "04. low")
        values.removeValue(forKey: "06. volume")
        let quote = try AlphaVantageMarketClient.decode(response(values).data, symbol: "AAPL", at: date)
        XCTAssertNil(quote.high)
        XCTAssertNil(quote.low)
        XCTAssertNil(quote.volume)
    }

    func testMalformedNonfiniteMismatchedAndImpossibleDatesAreRejected() {
        let replacements = [
            ("05. price", "NaN"), ("05. price", "inf"), ("05. price", "0"),
            ("03. high", "-1"), ("04. low", "999"), ("09. change", "-inf"),
            ("10. change percent", "NaN%"), ("10. change percent", "1.2"),
            ("08. previous close", "0"), ("01. symbol", "MSFT"),
            ("06. volume", "-1"), ("07. latest trading day", "2026-02-30"),
            ("07. latest trading day", "2099-09-04")
        ]
        for (key, value) in replacements {
            var values = fields(); values[key] = value
            XCTAssertThrowsError(try AlphaVantageMarketClient.decode(response(values).data, symbol: "AAPL", at: date)) {
                XCTAssertEqual($0 as? MarketError, .malformedData, "\(key)=\(value)")
            }
        }
        var missing = fields(); missing.removeValue(forKey: "05. price")
        XCTAssertThrowsError(try AlphaVantageMarketClient.decode(response(missing).data, symbol: "AAPL", at: date))
        XCTAssertThrowsError(try AlphaVantageMarketClient.decode(Data("<html>down</html>".utf8), symbol: "AAPL", at: date))
    }

    func testProviderLimitAndInvalidKeyAreClassifiedWithoutEchoingMessage() throws {
        for key in ["Note", "Information"] {
            let data = try JSONSerialization.data(withJSONObject: [key: "25 requests per day: secret-that-must-not-echo"])
            XCTAssertThrowsError(try AlphaVantageMarketClient.decode(data, symbol: "AAPL", at: date)) {
                XCTAssertEqual($0 as? MarketError, .rateLimited)
            }
        }
        let invalidKey = try JSONSerialization.data(withJSONObject: ["Information": "invalid API key secret"])
        XCTAssertThrowsError(try AlphaVantageMarketClient.decode(invalidKey, symbol: "AAPL", at: date)) {
            XCTAssertEqual($0 as? MarketError, .invalidKey)
        }
        XCTAssertThrowsError(try AlphaVantageMarketClient.decode(response([:]).data, symbol: "AAPL", at: date)) {
            XCTAssertEqual($0 as? MarketError, .noQuote)
        }
    }

    func testHTTPRateLimitAndOversizedBodies() async {
        for (response, expected) in [
            (RadarHTTPResponse(data: Data(), statusCode: 429), MarketError.rateLimited),
            (RadarHTTPResponse(data: Data(), statusCode: 503), MarketError.providerUnavailable),
            (RadarHTTPResponse(data: Data(repeating: 32, count: 65 * 1_024), statusCode: 200), MarketError.responseTooLarge)
        ] {
            do {
                _ = try await AlphaVantageMarketClient(transport: MarketTestTransport(response: response))
                    .quote(symbol: "AAPL", apiKey: "TESTKEY123", at: date)
                XCTFail("Expected \(expected)")
            } catch { XCTAssertEqual(error as? MarketError, expected) }
        }
    }

    func testClientDeadlineAndCancellation() async {
        let transport = MarketTestTransport(response: response(fields()), delay: .seconds(3))
        do {
            _ = try await AlphaVantageMarketClient(transport: transport, deadline: .milliseconds(10))
                .quote(symbol: "AAPL", apiKey: "TESTKEY123", at: date)
            XCTFail("Expected timeout")
        } catch { XCTAssertEqual(error as? MarketError, .timedOut) }
        let client = AlphaVantageMarketClient(transport: transport)
        let task = Task { try await client.quote(symbol: "AAPL", apiKey: "TESTKEY123", at: date) }
        task.cancel()
        do { _ = try await task.value; XCTFail("Expected cancellation") }
        catch { XCTAssertTrue(error is CancellationError) }
    }

    func testWatchlistEditsPersistAndPreserveExplicitEmptyList() {
        let defaults = isolatedDefaults()
        defer { clear(defaults) }
        defaults.set(["aapl", "AAPL", "BAD/SYM", "MSFT"], forKey: MarketStore.watchlistKey)
        let store = makeStore(defaults)
        XCTAssertEqual(store.watchlist, ["AAPL", "MSFT"])
        XCTAssertFalse(store.add("MSFT"))
        XCTAssertEqual(store.notice, .duplicateSymbol)
        XCTAssertTrue(store.add(" nvda "))
        store.move("NVDA", offset: -1)
        XCTAssertEqual(makeStore(defaults).watchlist, ["AAPL", "NVDA", "MSFT"])
        store.watchlist.forEach(store.remove)
        XCTAssertTrue(makeStore(defaults).watchlist.isEmpty)
    }

    func testNoKeyDoesNotNetworkAndKeyIsNeverWrittenToDefaults() async {
        let defaults = isolatedDefaults(); defer { clear(defaults) }
        let keychain = MarketTestKeyStorage()
        let client = MarketTestClient(date: date)
        let store = makeStore(defaults, keychain: keychain, client: client)
        await store.refresh()
        let before = await client.symbols
        XCTAssertTrue(before.isEmpty)
        XCTAssertFalse(store.hasAPIKey)
        XCTAssertTrue(store.saveKey("SENSITIVE123"))
        XCTAssertEqual(keychain.value, "SENSITIVE123")
        XCTAssertFalse(defaults.dictionaryRepresentation().description.contains("SENSITIVE123"))
        store.removeKey()
        XCTAssertNil(keychain.value)
        XCTAssertFalse(store.hasAPIKey)
    }

    func testFreshCacheSurvivesRestartAndConsumesNoRequests() async throws {
        let defaults = isolatedDefaults(); defer { clear(defaults) }
        defaults.set(["AAPL"], forKey: MarketStore.watchlistKey)
        let client = MarketTestClient(date: date)
        let store = makeStore(defaults, client: client)
        await store.refresh()
        XCTAssertEqual(store.remainingRequests, 24)
        let restarted = makeStore(defaults, client: client)
        XCTAssertEqual(restarted.quotes["AAPL"]?.price, 204.25)
        await restarted.refresh()
        XCTAssertEqual(restarted.notice, .allFresh)
        let symbols = await client.symbols
        XCTAssertEqual(symbols, ["AAPL"])
        XCTAssertFalse(try XCTUnwrap(restarted.quotes["AAPL"]).isFresh(at: date.addingTimeInterval(900)))
    }

    func testStaleQuoteIsPreservedDuringPartialFailureAndRequestsAreSerial() async throws {
        let defaults = isolatedDefaults(); defer { clear(defaults) }
        defaults.set(["AAPL", "MSFT", "NVDA"], forKey: MarketStore.watchlistKey)
        let stale = fixture(symbol: "MSFT", fetchedAt: date.addingTimeInterval(-3_600))
        defaults.set(try JSONEncoder().encode(["MSFT": stale]), forKey: MarketStore.quotesKey)
        let client = MarketTestClient(date: date, failures: ["MSFT": .network], delay: .milliseconds(5))
        let store = makeStore(defaults, client: client)
        await store.refresh()
        XCTAssertEqual(store.updatedCount, 2)
        XCTAssertEqual(store.completedRequests, 3)
        XCTAssertEqual(store.quotes["MSFT"], stale)
        XCTAssertEqual(store.errors["MSFT"], .network)
        XCTAssertNotNil(store.quotes["NVDA"])
        let maximumConcurrent = await client.maximumConcurrent
        XCTAssertEqual(maximumConcurrent, 1)
        XCTAssertFalse(store.isRefreshing)
    }

    func testProviderRateLimitStopsRemainderOfBatch() async {
        let defaults = isolatedDefaults(); defer { clear(defaults) }
        let client = MarketTestClient(date: date, failures: ["MSFT": .rateLimited])
        let store = makeStore(defaults, client: client)
        await store.refresh()
        let symbols = await client.symbols
        XCTAssertEqual(symbols, ["AAPL", "MSFT"])
        XCTAssertEqual(store.notice, .rateLimited)
        XCTAssertEqual(store.remainingRequests, 23)
        XCTAssertNil(store.quotes["NVDA"])
    }

    func testPersistedRollingQuotaIsNotBypassedOnRestartOrClockRollback() async {
        let defaults = isolatedDefaults(); defer { clear(defaults) }
        defaults.set(Array(repeating: date.timeIntervalSince1970 + 30, count: 25), forKey: MarketStore.requestsKey)
        let client = MarketTestClient(date: date)
        let store = makeStore(defaults, client: client)
        await store.refresh()
        XCTAssertEqual(store.notice, .localQuota)
        let symbols = await client.symbols
        XCTAssertTrue(symbols.isEmpty)
        XCTAssertEqual(makeStore(defaults).remainingRequests, 0)
    }

    func testExpiredRequestQuotaRecovers() {
        let defaults = isolatedDefaults(); defer { clear(defaults) }
        defaults.set(Array(repeating: date.timeIntervalSince1970 - 86_401, count: 25), forKey: MarketStore.requestsKey)
        XCTAssertEqual(makeStore(defaults).remainingRequests, 25)
    }

    func testCorruptOrMismatchedPersistedQuotesAreIgnored() throws {
        let defaults = isolatedDefaults(); defer { clear(defaults) }
        defaults.set(Data("invalid".utf8), forKey: MarketStore.quotesKey)
        XCTAssertTrue(makeStore(defaults).quotes.isEmpty)
        defaults.set(try JSONEncoder().encode(["AAPL": fixture(symbol: "MSFT", fetchedAt: date)]), forKey: MarketStore.quotesKey)
        XCTAssertTrue(makeStore(defaults).quotes.isEmpty)
        defaults.set(try JSONEncoder().encode(["AAPL": fixture(symbol: "AAPL", fetchedAt: date.addingTimeInterval(120))]), forKey: MarketStore.quotesKey)
        XCTAssertTrue(makeStore(defaults).quotes.isEmpty)
    }

    func testCancellationCannotOverwriteCacheAndCountsAttempt() async {
        let defaults = isolatedDefaults(); defer { clear(defaults) }
        let client = MarketTestClient(date: date, delay: .seconds(3))
        let store = makeStore(defaults, client: client)
        store.startRefresh()
        for _ in 0..<100 {
            let symbols = await client.symbols
            if !symbols.isEmpty { break }
            try? await Task.sleep(for: .milliseconds(1))
        }
        store.cancelRefresh()
        try? await Task.sleep(for: .milliseconds(20))
        XCTAssertTrue(store.quotes.isEmpty)
        XCTAssertFalse(store.isRefreshing)
        XCTAssertEqual(store.remainingRequests, 24)
    }

    func testConnectionVerificationUsesOnlyFirstSymbol() async {
        let defaults = isolatedDefaults(); defer { clear(defaults) }
        let client = MarketTestClient(date: date)
        let store = makeStore(defaults, client: client)
        await store.refresh(verifyConnection: true)
        let symbols = await client.symbols
        XCTAssertEqual(symbols, ["AAPL"])
        XCTAssertEqual(store.notice, .verified)
        XCTAssertEqual(store.remainingRequests, 24)
    }

    private func fields() -> [String: String] {
        ["01. symbol": "AAPL", "03. high": "205.0", "04. low": "201.0", "05. price": "204.25",
         "06. volume": "123456", "07. latest trading day": "2026-09-04", "08. previous close": "200.0",
         "09. change": "4.25", "10. change percent": "2.125%"]
    }

    private func response(_ fields: [String: String]) -> RadarHTTPResponse {
        RadarHTTPResponse(data: (try? JSONSerialization.data(withJSONObject: ["Global Quote": fields])) ?? Data(), statusCode: 200)
    }

    private func fixture(symbol: String, fetchedAt: Date) -> MarketQuote {
        MarketQuote(symbol: symbol, price: 204.25, previousClose: 200, change: 4.25,
                    changePercent: 2.125, tradingDay: "2026-09-04", high: 205, low: 201,
                    volume: 123456, fetchedAt: fetchedAt)
    }

    private func isolatedDefaults() -> UserDefaults {
        guard let defaults = UserDefaults(suiteName: "MarketTests.\(UUID().uuidString)") else {
            fatalError("Unable to create isolated test preferences")
        }
        return defaults
    }

    private func clear(_ defaults: UserDefaults) {
        for key in [MarketStore.watchlistKey, MarketStore.quotesKey, MarketStore.requestsKey] {
            defaults.removeObject(forKey: key)
        }
    }

    private func makeStore(_ defaults: UserDefaults,
                           keychain: MarketTestKeyStorage = MarketTestKeyStorage(value: "TESTKEY123"),
                           client: (any MarketQuoteClient)? = nil) -> MarketStore {
        let date = date
        return MarketStore(defaults: defaults, keyStorage: keychain,
                           client: client ?? MarketTestClient(date: date), now: { date }, requestSpacing: 0)
    }
}

@MainActor
private final class MarketTestKeyStorage: MarketKeyStorage {
    var value: String?
    init(value: String? = nil) { self.value = value }
    func read() throws -> String? { value }
    func save(_ key: String) throws { value = key }
    func remove() throws { value = nil }
}

private actor MarketTestTransport: RadarHTTPTransport {
    let response: RadarHTTPResponse
    let delay: Duration
    private(set) var lastRequest: URLRequest?
    private(set) var byteLimit = 0
    init(response: RadarHTTPResponse, delay: Duration = .zero) {
        self.response = response; self.delay = delay
    }
    func data(for request: URLRequest, maximumBytes: Int) async throws -> RadarHTTPResponse {
        lastRequest = request; byteLimit = maximumBytes
        try await Task.sleep(for: delay)
        return response
    }
}

private actor MarketTestClient: MarketQuoteClient {
    let date: Date
    let failures: [String: MarketError]
    let delay: Duration
    private(set) var symbols: [String] = []
    private(set) var maximumConcurrent = 0
    private var active = 0
    init(date: Date, failures: [String: MarketError] = [:], delay: Duration = .zero) {
        self.date = date; self.failures = failures; self.delay = delay
    }
    func quote(symbol: String, apiKey: String, at date: Date) async throws -> MarketQuote {
        symbols.append(symbol); active += 1; maximumConcurrent = max(active, maximumConcurrent)
        defer { active -= 1 }
        try await Task.sleep(for: delay)
        if let failure = failures[symbol] { throw failure }
        return MarketQuote(symbol: symbol, price: 204.25, previousClose: 200, change: 4.25,
                           changePercent: 2.125, tradingDay: "2026-09-04", high: 205, low: 201,
                           volume: 123456, fetchedAt: date)
    }
}
