import Foundation
import XCTest
@testable import NotchCalendar

@MainActor
final class RadarTests: XCTestCase {
    func testClientLoadsTenStoriesInRankOrderWithAtMostFourConcurrentRequests() async throws {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        var responses: [String: RadarHTTPResponse] = [
            "/v0/topstories.json": jsonResponse(Array(1...12))
        ]
        for id in 1...12 {
            responses["/v0/item/\(id).json"] = jsonResponse(
                storyFixture(id: id, time: Int(now.timeIntervalSince1970) - id)
            )
        }
        let transport = StubRadarTransport(responses: responses, itemDelay: .milliseconds(15))
        let client = HackerNewsRadarClient(transport: transport)

        let snapshot = try await client.fetch(feed: .hot, at: now)
        let maximumConcurrentRequests = await transport.maximumConcurrentRequests

        XCTAssertEqual(snapshot.stories.count, 10)
        XCTAssertEqual(snapshot.stories.map(\.id), Array(1...10))
        XCTAssertEqual(maximumConcurrentRequests, 4)
        XCTAssertEqual(snapshot.feed, .hot)
        XCTAssertEqual(snapshot.fetchedAt, now)
    }

    func testClientSkipsMalformedAndDeadItemsAndUsesHackerNewsFallbackURL() async throws {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let transport = StubRadarTransport(
            responses: [
                "/v0/askstories.json": jsonResponse([1, 2, 3]),
                "/v0/item/1.json": RadarHTTPResponse(
                    data: Data("{not-json".utf8),
                    statusCode: 200
                ),
                "/v0/item/2.json": jsonResponse(
                    storyFixture(
                        id: 2,
                        time: Int(now.timeIntervalSince1970) - 30,
                        dead: true
                    )
                ),
                "/v0/item/3.json": jsonResponse(
                    storyFixture(
                        id: 3,
                        time: Int(now.timeIntervalSince1970) - 60,
                        url: nil
                    )
                )
            ]
        )
        let client = HackerNewsRadarClient(transport: transport)

        let snapshot = try await client.fetch(feed: .ask, at: now)

        XCTAssertEqual(snapshot.stories.map(\.id), [3])
        XCTAssertEqual(
            snapshot.stories.first?.destinationURL.absoluteString,
            "https://news.ycombinator.com/item?id=3"
        )
    }

    func testClientIsolatesFailedItemRequestsAndOnlyThrowsWhenNoneAreValid() async throws {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let mixedTransport = StubRadarTransport(
            responses: [
                "/v0/topstories.json": jsonResponse([1, 2, 3, 4]),
                "/v0/item/1.json": jsonResponse(
                    storyFixture(id: 1, time: Int(now.timeIntervalSince1970) - 10)
                ),
                "/v0/item/2.json": RadarHTTPResponse(data: Data(), statusCode: 404),
                "/v0/item/3.json": RadarHTTPResponse(data: Data(), statusCode: 500)
            ]
        )

        let snapshot = try await HackerNewsRadarClient(transport: mixedTransport)
            .fetch(feed: .hot, at: now)

        XCTAssertEqual(snapshot.stories.map(\.id), [1])

        let allFailedTransport = StubRadarTransport(
            responses: [
                "/v0/showstories.json": jsonResponse([8, 9]),
                "/v0/item/8.json": RadarHTTPResponse(data: Data(), statusCode: 404),
                "/v0/item/9.json": RadarHTTPResponse(data: Data(), statusCode: 500)
            ]
        )
        do {
            _ = try await HackerNewsRadarClient(transport: allFailedTransport)
                .fetch(feed: .show, at: now)
            XCTFail("An entirely invalid item set must report no stories")
        } catch let error as RadarClientError {
            XCTAssertEqual(error, .noStories)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testClientPropagatesTaskCancellation() async {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let transport = StubRadarTransport(
            responses: [
                "/v0/askstories.json": jsonResponse([1]),
                "/v0/item/1.json": jsonResponse(
                    storyFixture(id: 1, time: Int(now.timeIntervalSince1970) - 10)
                )
            ],
            itemDelay: .seconds(5)
        )
        let client = HackerNewsRadarClient(transport: transport)
        let task = Task {
            try await client.fetch(feed: .ask, at: now)
        }

        try? await Task.sleep(for: .milliseconds(30))
        task.cancel()

        do {
            _ = try await task.value
            XCTFail("Cancellation must propagate to the caller")
        } catch is CancellationError {
            // Expected.
        } catch {
            XCTFail("Expected CancellationError, received \(error)")
        }
    }

    func testClientEnforcesSharedFeedDeadline() async {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let transport = StubRadarTransport(
            responses: [
                "/v0/topstories.json": jsonResponse([1, 2, 3, 4]),
                "/v0/item/1.json": jsonResponse(
                    storyFixture(id: 1, time: Int(now.timeIntervalSince1970) - 10)
                )
            ],
            itemDelay: .seconds(5)
        )
        let client = HackerNewsRadarClient(
            transport: transport,
            feedDeadline: .milliseconds(40)
        )

        do {
            _ = try await client.fetch(feed: .hot, at: now)
            XCTFail("A feed request must not outlive its shared deadline")
        } catch let error as RadarClientError {
            XCTAssertEqual(error, .requestTimedOut)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testClientRejectsOversizedAndNonSuccessResponses() async {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let oversizedTransport = StubRadarTransport(
            responses: [
                "/v0/topstories.json": RadarHTTPResponse(
                    data: Data(repeating: 0x31, count: 300 * 1_024),
                    statusCode: 200
                )
            ]
        )

        do {
            _ = try await HackerNewsRadarClient(transport: oversizedTransport)
                .fetch(feed: .hot, at: now)
            XCTFail("Oversized responses must be rejected")
        } catch let error as RadarClientError {
            XCTAssertEqual(error, .responseTooLarge)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        let unavailableTransport = StubRadarTransport(
            responses: [
                "/v0/showstories.json": RadarHTTPResponse(data: Data(), statusCode: 503)
            ]
        )
        do {
            _ = try await HackerNewsRadarClient(transport: unavailableTransport)
                .fetch(feed: .show, at: now)
            XCTFail("Non-success responses must be rejected")
        } catch let error as RadarClientError {
            XCTAssertEqual(error, .invalidResponse(statusCode: 503))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testDiskCacheRoundTripsSnapshotsAndRejectsWrongFeed() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("NotchCalendar-RadarTests-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let cache = RadarDiskCache(directoryURL: directory)
        let snapshot = makeSnapshot(feed: .hot, fetchedAt: Date(timeIntervalSince1970: 1_800_000_000))

        try await cache.save(snapshot)
        let loadedHot = await cache.snapshot(for: .hot)
        let loadedAsk = await cache.snapshot(for: .ask)

        XCTAssertEqual(loadedHot, snapshot)
        XCTAssertNil(loadedAsk)
    }

    func testFreshCacheAvoidsNetworkUntilManualRefresh() async {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let cached = makeSnapshot(feed: .hot, fetchedAt: now.addingTimeInterval(-60), firstID: 1)
        let refreshed = makeSnapshot(feed: .hot, fetchedAt: now, firstID: 2)
        let cache = InMemoryRadarCache(snapshots: [.hot: cached])
        let client = StubRadarClient(result: .success(refreshed))
        let store = RadarStore(client: client, cache: cache, now: { now })

        await store.load(.hot)
        let initialCallCount = await client.callCount

        XCTAssertEqual(store.stories.map(\.id), [1])
        XCTAssertEqual(initialCallCount, 0)
        XCTAssertNil(store.errorMessageKey)

        await store.load(.hot, forceRefresh: true)
        let refreshedCallCount = await client.callCount
        let savedSnapshots = await cache.savedSnapshots

        XCTAssertEqual(store.stories.map(\.id), [2])
        XCTAssertEqual(refreshedCallCount, 1)
        XCTAssertEqual(savedSnapshots.last, refreshed)
    }

    func testStaleCacheRemainsVisibleWhenRefreshFails() async {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let cached = makeSnapshot(
            feed: .show,
            fetchedAt: now.addingTimeInterval(-(RadarDiskCache.timeToLive + 1)),
            firstID: 8
        )
        let cache = InMemoryRadarCache(snapshots: [.show: cached])
        let client = StubRadarClient(result: .failure(.invalidResponse(statusCode: 503)))
        let store = RadarStore(client: client, cache: cache, now: { now })

        await store.load(.show)

        XCTAssertEqual(store.stories.map(\.id), [8])
        XCTAssertTrue(store.isShowingSavedData)
        XCTAssertEqual(
            store.errorMessageKey,
            "Could not refresh. Showing the last saved signal."
        )
        XCTAssertFalse(store.isLoading)
        XCTAssertFalse(store.isRefreshing)
    }

    func testFailureWithoutCacheProducesActionableNonBlankState() async {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let cache = InMemoryRadarCache()
        let client = StubRadarClient(result: .failure(.invalidResponse(statusCode: 500)))
        let store = RadarStore(client: client, cache: cache, now: { now })

        await store.load(.ask)

        XCTAssertTrue(store.stories.isEmpty)
        XCTAssertFalse(store.isShowingSavedData)
        XCTAssertEqual(store.errorMessageKey, "Radar could not load right now.")
        XCTAssertFalse(store.isLoading)
    }

    func testOlderSameFeedRequestCannotOverwriteNewerResult() async {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let older = makeSnapshot(feed: .hot, fetchedAt: now, firstID: 1)
        let newer = makeSnapshot(feed: .hot, fetchedAt: now, firstID: 2)
        let client = SequencedRadarClient(
            responses: [
                .init(snapshot: older, delay: .milliseconds(100)),
                .init(snapshot: newer, delay: .milliseconds(5))
            ]
        )
        let store = RadarStore(client: client, cache: InMemoryRadarCache(), now: { now })

        let first = Task { await store.load(.hot, forceRefresh: true) }
        try? await Task.sleep(for: .milliseconds(15))
        let second = Task { await store.load(.hot, forceRefresh: true) }
        await first.value
        await second.value

        XCTAssertEqual(store.stories.map(\.id), [2])
        XCTAssertFalse(store.isLoading)
        XCTAssertFalse(store.isRefreshing)
    }

    private func makeSnapshot(
        feed: RadarFeed,
        fetchedAt: Date,
        firstID: Int = 1
    ) -> RadarSnapshot {
        RadarSnapshot(
            feed: feed,
            stories: [
                RadarStory(
                    id: firstID,
                    title: "A useful signal",
                    destinationURL: URL(string: "https://example.com/story/\(firstID)")!,
                    author: "reader",
                    score: 42,
                    commentCount: 7,
                    publishedAt: fetchedAt.addingTimeInterval(-120)
                )
            ],
            fetchedAt: fetchedAt
        )
    }

    private func jsonResponse(_ object: Any, statusCode: Int = 200) -> RadarHTTPResponse {
        RadarHTTPResponse(
            data: try! JSONSerialization.data(withJSONObject: object, options: [.sortedKeys]),
            statusCode: statusCode
        )
    }

    private func storyFixture(
        id: Int,
        time: Int,
        dead: Bool = false,
        url: String? = "https://example.com/story"
    ) -> [String: Any] {
        var item: [String: Any] = [
            "id": id,
            "type": "story",
            "by": "author\(id)",
            "time": time,
            "title": "Story \(id)",
            "score": 100 - id,
            "descendants": id,
            "dead": dead
        ]
        if let url { item["url"] = url }
        return item
    }
}

private actor StubRadarTransport: RadarHTTPTransport {
    private let responses: [String: RadarHTTPResponse]
    private let itemDelay: Duration
    private var activeRequests = 0
    private(set) var maximumConcurrentRequests = 0

    init(
        responses: [String: RadarHTTPResponse],
        itemDelay: Duration = .zero
    ) {
        self.responses = responses
        self.itemDelay = itemDelay
    }

    func data(for request: URLRequest, maximumBytes: Int) async throws -> RadarHTTPResponse {
        guard let path = request.url?.path, let response = responses[path] else {
            throw RadarClientError.invalidEndpoint
        }

        activeRequests += 1
        maximumConcurrentRequests = max(maximumConcurrentRequests, activeRequests)
        defer { activeRequests -= 1 }

        if path.contains("/item/"), itemDelay > .zero {
            try await Task.sleep(for: itemDelay)
        }
        return response
    }
}

private actor StubRadarClient: RadarClient {
    enum Result: Sendable {
        case success(RadarSnapshot)
        case failure(RadarClientError)
    }

    private let result: Result
    private(set) var callCount = 0

    init(result: Result) {
        self.result = result
    }

    func fetch(feed: RadarFeed, at date: Date) async throws -> RadarSnapshot {
        callCount += 1
        switch result {
        case let .success(snapshot): return snapshot
        case let .failure(error): throw error
        }
    }
}

private actor SequencedRadarClient: RadarClient {
    struct Response: Sendable {
        let snapshot: RadarSnapshot
        let delay: Duration
    }

    private let responses: [Response]
    private var nextIndex = 0

    init(responses: [Response]) {
        self.responses = responses
    }

    func fetch(feed: RadarFeed, at date: Date) async throws -> RadarSnapshot {
        let index = min(nextIndex, responses.count - 1)
        nextIndex += 1
        let response = responses[index]
        try await Task.sleep(for: response.delay)
        return response.snapshot
    }
}

private actor InMemoryRadarCache: RadarCacheStore {
    private var snapshots: [RadarFeed: RadarSnapshot]
    private(set) var savedSnapshots: [RadarSnapshot] = []

    init(snapshots: [RadarFeed: RadarSnapshot] = [:]) {
        self.snapshots = snapshots
    }

    func snapshot(for feed: RadarFeed) async -> RadarSnapshot? {
        snapshots[feed]
    }

    func save(_ snapshot: RadarSnapshot) async throws {
        snapshots[snapshot.feed] = snapshot
        savedSnapshots.append(snapshot)
    }
}
