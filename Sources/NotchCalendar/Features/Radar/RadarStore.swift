import Combine
import Foundation

@MainActor
final class RadarStore: ObservableObject {
    @Published private(set) var feed: RadarFeed = .hot
    @Published private(set) var stories: [RadarStory] = []
    @Published private(set) var fetchedAt: Date?
    @Published private(set) var isLoading = false
    @Published private(set) var isRefreshing = false
    @Published private(set) var isShowingSavedData = false
    @Published private(set) var errorMessageKey: String?

    private let client: any RadarClient
    private let cache: any RadarCacheStore
    private let nowProvider: () -> Date
    private var requestGeneration = 0

    init(
        client: any RadarClient = HackerNewsRadarClient(),
        cache: any RadarCacheStore = RadarDiskCache(),
        now: @escaping () -> Date = Date.init
    ) {
        self.client = client
        self.cache = cache
        nowProvider = now
    }

    func load(_ requestedFeed: RadarFeed, forceRefresh: Bool = false) async {
        requestGeneration &+= 1
        let generation = requestGeneration
        let changedFeed = feed != requestedFeed
        feed = requestedFeed
        errorMessageKey = nil
        if changedFeed {
            stories = []
            fetchedAt = nil
            isShowingSavedData = false
        }
        isLoading = stories.isEmpty
        isRefreshing = !stories.isEmpty

        let now = nowProvider()
        let cachedSnapshot = await cache.snapshot(for: requestedFeed)
        guard isCurrent(generation, feed: requestedFeed) else { return }
        guard !Task.isCancelled else {
            finish(generation, feed: requestedFeed)
            return
        }

        if let cachedSnapshot {
            apply(cachedSnapshot)
            let isFresh = cachedSnapshot.isFresh(
                at: now,
                timeToLive: RadarDiskCache.timeToLive
            )
            isShowingSavedData = !isFresh
            if isFresh && !forceRefresh {
                isLoading = false
                isRefreshing = false
                return
            }
        }

        isLoading = stories.isEmpty
        isRefreshing = !stories.isEmpty

        do {
            let snapshot = try await client.fetch(feed: requestedFeed, at: now)
            try Task.checkCancellation()
            guard isCurrent(generation, feed: requestedFeed),
                  snapshot.isValid(for: requestedFeed) else {
                throw RadarClientError.malformedData
            }
            apply(snapshot)
            isShowingSavedData = false
            errorMessageKey = nil
            try? await cache.save(snapshot)
        } catch is CancellationError {
            finish(generation, feed: requestedFeed)
            return
        } catch {
            guard isCurrent(generation, feed: requestedFeed) else { return }
            isShowingSavedData = !stories.isEmpty
            errorMessageKey = stories.isEmpty
                ? "Radar could not load right now."
                : "Could not refresh. Showing the last saved signal."
        }

        finish(generation, feed: requestedFeed)
    }

    private func apply(_ snapshot: RadarSnapshot) {
        stories = snapshot.stories
        fetchedAt = snapshot.fetchedAt
    }

    private func isCurrent(_ generation: Int, feed requestedFeed: RadarFeed) -> Bool {
        requestGeneration == generation && feed == requestedFeed
    }

    private func finish(_ generation: Int, feed requestedFeed: RadarFeed) {
        guard isCurrent(generation, feed: requestedFeed) else { return }
        isLoading = false
        isRefreshing = false
    }
}
