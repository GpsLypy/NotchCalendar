import Combine
import Foundation

enum BriefingFilter: String, CaseIterable, Identifiable {
    case latest, unread, saved
    var id: String { rawValue }
}

@MainActor
final class BriefingStore: ObservableObject {
    @Published var selectedSource: BriefingSource?
    @Published var filter: BriefingFilter = .latest
    @Published var search = ""
    @Published private(set) var snapshots: [BriefingSource: BriefingSnapshot] = [:]
    @Published private(set) var failedSources: Set<BriefingSource> = []
    @Published private(set) var cachedSources: Set<BriefingSource> = []
    @Published private(set) var isLoading = false
    @Published private(set) var didLoad = false
    @Published private(set) var cacheWriteFailed = false
    @Published private(set) var savedLimitReached = false
    @Published private(set) var library: BriefingLibrary

    private let client: any BriefingClient
    private let cache: any BriefingCache
    private let defaults: UserDefaults
    private let now: () -> Date
    private var generation = 0

    init(client: any BriefingClient = BriefingFeedClient(), cache: any BriefingCache = BriefingDiskCache(), defaults: UserDefaults = .standard, now: @escaping () -> Date = Date.init) {
        self.client = client
        self.cache = cache
        self.defaults = defaults
        self.now = now
        library = BriefingLibrary.load(from: defaults)
    }

    var visibleArticles: [BriefingArticle] {
        var articles = filter == .saved ? library.saved : snapshots.values.flatMap(\.articles)
        if let selectedSource { articles = articles.filter { $0.source == selectedSource } }
        if filter == .unread { articles = articles.filter { !isRead($0) } }
        let query = search.trimmingCharacters(in: .whitespacesAndNewlines)
        if !query.isEmpty {
            articles = articles.filter {
                $0.title.localizedCaseInsensitiveContains(query)
                    || $0.source.name.localizedCaseInsensitiveContains(query)
                    || $0.topic.label(chinese: true).localizedCaseInsensitiveContains(query)
                    || $0.topic.label(chinese: false).localizedCaseInsensitiveContains(query)
            }
        }
        var seen: Set<String> = []
        let sorted = articles.sorted {
            $0.publishedAt == $1.publishedAt ? $0.id < $1.id : $0.publishedAt > $1.publishedAt
        }.filter { seen.insert($0.id).inserted }
        return filter == .saved ? sorted : Array(sorted.prefix(BriefingFeedClient.articleLimit))
    }

    var unreadCount: Int {
        Set(snapshots.values.flatMap(\.articles).filter { !isRead($0) }.map(\.id)).count
    }

    func isSaved(_ article: BriefingArticle) -> Bool { library.saved.contains { $0.id == article.id } }
    func isRead(_ article: BriefingArticle) -> Bool { library.readIDs.contains(article.id) }
    func isStale(_ source: BriefingSource) -> Bool { snapshots[source].map { !$0.isFresh(at: now()) } ?? false }

    func toggleSaved(_ article: BriefingArticle) {
        savedLimitReached = !library.toggleSaved(article)
        library.persist(to: defaults)
    }

    func toggleRead(_ article: BriefingArticle) { markRead(article, isRead: !isRead(article)) }

    func markRead(_ article: BriefingArticle, isRead: Bool = true) {
        library.setRead(article, isRead: isRead)
        library.persist(to: defaults)
    }

    func load(forceRefresh: Bool = false) async {
        generation += 1
        let current = generation
        let date = now()
        isLoading = true
        failedSources = []
        cacheWriteFailed = false
        defer {
            if generation == current { isLoading = false; didLoad = true }
        }

        for source in BriefingSource.allCases where snapshots[source] == nil {
            let snapshot = await cache.snapshot(for: source, at: date)
            guard !Task.isCancelled, generation == current else { return }
            if let snapshot { snapshots[source] = snapshot; cachedSources.insert(source) }
        }
        let needed = BriefingSource.allCases.filter { forceRefresh || snapshots[$0]?.isFresh(at: date) != true }
        guard !needed.isEmpty, !Task.isCancelled else { return }

        await withTaskGroup(of: BriefingLoadResult.self) { group in
            for source in needed {
                group.addTask { [client] in
                    do {
                        let snapshot = try await client.fetch(source: source, at: date)
                        guard snapshot.source == source, snapshot.isValid(at: date) else { return .failed(source) }
                        return .loaded(snapshot)
                    } catch {
                        return Task.isCancelled ? .cancelled : .failed(source)
                    }
                }
            }
            for await result in group {
                guard !Task.isCancelled, generation == current else { group.cancelAll(); return }
                switch result {
                case .loaded(let snapshot):
                    snapshots[snapshot.source] = snapshot
                    cachedSources.remove(snapshot.source)
                    do { try await cache.save(snapshot) }
                    catch { if generation == current { cacheWriteFailed = true } }
                case .failed(let source):
                    failedSources.insert(source)
                case .cancelled:
                    break
                }
            }
        }
    }
}

private enum BriefingLoadResult: Sendable {
    case loaded(BriefingSnapshot), failed(BriefingSource), cancelled
}
