import Foundation
import XCTest
@testable import NotchCalendar

@MainActor
final class DiscussionTests: XCTestCase {
    private let now = Date(timeIntervalSince1970: 1_800_000_000)

    func testHTMLBecomesPlainTextWithoutExecutingOrLosingParagraphs() {
        let input = "<script>alert('bad')</script><style>a { color:red; }</style><p>A &amp; B</p><p>&#x4E2D;&#25991; &#39;quote&#39; <a href=\"javascript:bad()\">link</a><br>last &lt;tag&gt;</p>"
        let result = DiscussionText.plain(input)
        XCTAssertTrue(result.contains("A & B"))
        XCTAssertTrue(result.contains("中文 'quote' link\nlast <tag>"))
        XCTAssertFalse(result.contains("alert"))
        XCTAssertFalse(result.contains("javascript"))
        XCTAssertFalse(result.contains("color:red"))
        XCTAssertTrue(result.contains("\n"))
    }

    func testSanitizerCapsOversizedInputAndHandlesMalformedEntitiesAndControls() {
        XCTAssertEqual(DiscussionText.plain(String(repeating: "x", count: 200_000)).count, DiscussionText.maximumTextLength)
        XCTAssertEqual(DiscussionText.plain("&#xD800;&#0;A\u{0000} &madeup; &#x1F600;"), "A &madeup; 😀")
        XCTAssertEqual(DiscussionText.plain("<i>open without closing"), "open without closing")
        XCTAssertEqual(DiscussionText.plain("&lt;script&gt;hello&lt;/script&gt;"), "<script>hello</script>")
    }

    func testExternalURLsRejectExecutableSchemesCredentialsAndOversizedValues() {
        XCTAssertNil(DiscussionText.webURL("javascript:alert(1)"))
        XCTAssertNil(DiscussionText.webURL("file:///tmp/test"))
        XCTAssertNil(DiscussionText.webURL("https://user:secret@example.com/test"))
        XCTAssertNil(DiscussionText.webURL("https://example.com/" + String(repeating: "a", count: 2_050)))
        XCTAssertEqual(DiscussionText.webURL("https://example.com/article")?.host, "example.com")
    }

    func testClientPreservesHNOrderCapsCommentsAndFourConcurrentRequests() async throws {
        var responses: [String: RadarHTTPResponse] = ["/v0/item/100.json": response(["id": 100, "type": "story", "kids": Array(1...50), "text": "<p>Question</p>"])]
        for id in 1...50 { responses["/v0/item/\(id).json"] = response(commentFixture(id: id)) }
        let transport = DiscussionStubTransport(responses: responses, delay: .milliseconds(5))
        let snapshot = try await HackerNewsDiscussionClient(transport: transport).fetch(storyID: 100, at: now)
        let concurrent = await transport.maximumConcurrent
        let requests = await transport.paths
        XCTAssertEqual(snapshot.comments.map(\.id), Array(1...12))
        XCTAssertEqual(snapshot.topLevelCount, 50)
        XCTAssertEqual(snapshot.storyText, "Question")
        XCTAssertEqual(concurrent, 4)
        XCTAssertEqual(requests.count, 13)
        XCTAssertTrue(snapshot.isValid)
    }

    func testDeletedDeadWrongParentAndFutureCommentsAreExcluded() async throws {
        var deleted = commentFixture(id: 1); deleted["deleted"] = true
        var dead = commentFixture(id: 2); dead["dead"] = true
        var wrongParent = commentFixture(id: 3); wrongParent["parent"] = 99
        var future = commentFixture(id: 4); future["time"] = now.addingTimeInterval(100_000).timeIntervalSince1970
        var empty = commentFixture(id: 5); empty["text"] = "<p></p>"
        let transport = DiscussionStubTransport(responses: [
            "/v0/item/100.json": response(["id": 100, "type": "story", "kids": [1, 2, 3, 4, 5, 6]]),
            "/v0/item/1.json": response(deleted), "/v0/item/2.json": response(dead),
            "/v0/item/3.json": response(wrongParent), "/v0/item/4.json": response(future),
            "/v0/item/5.json": response(empty), "/v0/item/6.json": response(commentFixture(id: 6))
        ])
        let snapshot = try await HackerNewsDiscussionClient(transport: transport).fetch(storyID: 100, at: now)
        XCTAssertEqual(snapshot.comments.map(\.id), [6])
        XCTAssertEqual(snapshot.failedCount, 3, "Malformed parent, future date, and empty text make a partial refresh; deleted/dead comments do not")
        XCTAssertEqual(snapshot.comments[0].sourceURL.absoluteString, "https://news.ycombinator.com/item?id=6")
        XCTAssertEqual(snapshot.comments[0].authorURL.host, "news.ycombinator.com")
    }

    func testPartialFailureStillReturnsAvailableCommentsAndCountsFailures() async throws {
        let transport = DiscussionStubTransport(responses: [
            "/v0/item/100.json": response(["id": 100, "type": "story", "kids": [1, 2, 3]]),
            "/v0/item/1.json": response(commentFixture(id: 1)),
            "/v0/item/2.json": RadarHTTPResponse(data: Data("broken".utf8), statusCode: 200),
            "/v0/item/3.json": RadarHTTPResponse(data: Data(), statusCode: 503)
        ])
        let snapshot = try await HackerNewsDiscussionClient(transport: transport).fetch(storyID: 100, at: now)
        XCTAssertEqual(snapshot.comments.map(\.id), [1])
        XCTAssertEqual(snapshot.failedCount, 2)
    }

    func testMalformedCommentFieldsMarkSnapshotIncompleteWhileRemovedCommentsDoNot() async throws {
        var missingAuthor = commentFixture(id: 2); missingAuthor.removeValue(forKey: "by")
        var missingText = commentFixture(id: 3); missingText.removeValue(forKey: "text")
        var missingTime = commentFixture(id: 4); missingTime.removeValue(forKey: "time")
        var wrongType = commentFixture(id: 5); wrongType["type"] = "story"
        var wrongID = commentFixture(id: 6); wrongID["id"] = 600
        let transport = DiscussionStubTransport(responses: [
            "/v0/item/100.json": response(["id": 100, "type": "story", "kids": Array(1...8)]),
            "/v0/item/1.json": response(commentFixture(id: 1)),
            "/v0/item/2.json": response(missingAuthor),
            "/v0/item/3.json": response(missingText),
            "/v0/item/4.json": response(missingTime),
            "/v0/item/5.json": response(wrongType),
            "/v0/item/6.json": response(wrongID),
            "/v0/item/7.json": response(["id": 7, "deleted": true]),
            "/v0/item/8.json": response(["id": 8, "dead": true])
        ])
        let snapshot = try await HackerNewsDiscussionClient(transport: transport).fetch(storyID: 100, at: now)
        XCTAssertEqual(snapshot.comments.map(\.id), [1])
        XCTAssertEqual(snapshot.failedCount, 5)
    }

    func testCandidateLimitPreventsUnboundedRequestsWhenCommentsAreDeleted() async throws {
        var responses = ["/v0/item/1000.json": response(["id": 1000, "type": "story", "kids": [-1, 1, 1] + Array(2...100)])]
        for id in 1...100 { responses["/v0/item/\(id).json"] = response(["id": id, "deleted": true]) }
        let transport = DiscussionStubTransport(responses: responses)
        let result = try await HackerNewsDiscussionClient(transport: transport).fetch(storyID: 1000, at: now)
        let count = await transport.paths.count
        XCTAssertTrue(result.comments.isEmpty)
        XCTAssertEqual(count, HackerNewsDiscussionClient.candidateLimit + 1)
        XCTAssertEqual(result.topLevelCount, 100)
    }

    func testOversizedResponseAndInvalidStoryIDAreRejected() async {
        let transport = DiscussionStubTransport(responses: ["/v0/item/100.json": RadarHTTPResponse(data: Data(repeating: 32, count: HackerNewsDiscussionClient.maximumItemBytes + 1), statusCode: 200)])
        do {
            _ = try await HackerNewsDiscussionClient(transport: transport).fetch(storyID: 100, at: now)
            XCTFail("Oversized payload must fail")
        } catch { XCTAssertEqual(error as? RadarClientError, .responseTooLarge) }
        do {
            _ = try await HackerNewsDiscussionClient(transport: transport).fetch(storyID: -1, at: now)
            XCTFail("Invalid ID must fail")
        } catch { XCTAssertEqual(error as? RadarClientError, .invalidEndpoint) }
    }

    func testClientDeadlineAndCancellationStopRequests() async {
        let transport = DiscussionStubTransport(responses: [:], delay: .seconds(10))
        do {
            _ = try await HackerNewsDiscussionClient(transport: transport, deadline: .milliseconds(15)).fetch(storyID: 100, at: now)
            XCTFail("Deadline must fail")
        } catch { XCTAssertEqual(error as? RadarClientError, .requestTimedOut) }
        let task = Task { try await HackerNewsDiscussionClient(transport: transport).fetch(storyID: 100, at: now) }
        await Task.yield()
        task.cancel()
        do { _ = try await task.value; XCTFail("Cancelled requests must fail") }
        catch { XCTAssertTrue(error is CancellationError) }
    }

    func testDiskCacheRoundTripRejectsMalformedDataAndBoundsSnapshots() async throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let file = directory.appendingPathComponent("cache.json")
        let cache = DiscussionDiskCache(fileURL: file)
        for id in 1...25 { try await cache.save(snapshot(id: id, date: now.addingTimeInterval(Double(id)))) }
        let oldest = await cache.snapshot(storyID: 1)
        let newest = await DiscussionDiskCache(fileURL: file).snapshot(storyID: 25)
        XCTAssertNil(oldest)
        XCTAssertEqual(newest?.storyID, 25)
        try Data("{bad".utf8).write(to: file)
        let malformed = await cache.snapshot(storyID: 25)
        XCTAssertNil(malformed)
        try Data(repeating: 32, count: DiscussionDiskCache.maximumBytes + 1).write(to: file)
        let oversized = await cache.snapshot(storyID: 25)
        XCTAssertNil(oversized)
    }

    func testNotebookPersistsNotesStanceAndBookmarksWithLengthCap() {
        let suite = "DiscussionTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let notebook = DiscussionNotebook(defaults: defaults)
        let item = story(id: 100)
        XCTAssertTrue(notebook.save(story: item, note: String(repeating: "中", count: 2_100), stance: .skeptical, isSaved: true))
        let reloaded = DiscussionNotebook(defaults: defaults)
        XCTAssertEqual(reloaded.take(for: item).note.count, 2_000)
        XCTAssertEqual(reloaded.take(for: item).stance, .skeptical)
        XCTAssertEqual(reloaded.savedStories.map(\.id), [100])
        reloaded.save(story: item, note: "A private idea", stance: .exploring, isSaved: false)
        XCTAssertEqual(DiscussionNotebook(defaults: defaults).savedStories.map(\.id), [100], "An unbookmarked note must remain discoverable")
        reloaded.save(story: item, note: "", stance: .exploring, isSaved: false)
        XCTAssertTrue(DiscussionNotebook(defaults: defaults).takes.isEmpty)
    }

    func testFailedRefreshRetainsCacheAndExplainsFailure() async throws {
        let cached = snapshot(id: 100, date: now.addingTimeInterval(-1_000))
        let cache = DiscussionMemoryCache(values: [100: cached])
        let store = DiscussionStore(client: DiscussionStubClient(result: .failure(.malformedData)), cache: cache, now: { self.now })
        await store.load(storyID: 100, force: true)
        XCTAssertEqual(store.snapshot, cached)
        XCTAssertTrue(store.loadFailed)
        XCTAssertTrue(store.isStale)
        XCTAssertFalse(store.isLoading)
    }

    func testPartialRefreshRetainsOldCommentsWithoutOverwritingCompleteDiskCopy() async {
        let oldComment = DiscussionComment(id: 1, storyID: 100, author: "first", text: "Earlier context", publishedAt: now, replyCount: 0)
        let newComment = DiscussionComment(id: 2, storyID: 100, author: "second", text: "Fresh perspective", publishedAt: now, replyCount: 0)
        let complete = DiscussionSnapshot(storyID: 100, storyText: "Question", comments: [oldComment], topLevelCount: 2, failedCount: 0, fetchedAt: now.addingTimeInterval(-100))
        let partial = DiscussionSnapshot(storyID: 100, storyText: "Question", comments: [newComment], topLevelCount: 2, failedCount: 1, fetchedAt: now)
        let cache = DiscussionMemoryCache(values: [100: complete])
        let store = DiscussionStore(client: DiscussionStubClient(result: .success(partial)), cache: cache, now: { self.now })
        await store.load(storyID: 100, force: true)
        XCTAssertEqual(store.snapshot?.comments.map(\.id), [2, 1])
        XCTAssertTrue(store.isStale)
        let retainedCache = await cache.snapshot(storyID: 100)
        XCTAssertEqual(retainedCache, complete)
    }

    func testCompleteRefreshClearsStaleBadgeAndReplacesOutdatedCache() async {
        let oldComment = DiscussionComment(id: 1, storyID: 100, author: "first", text: "Earlier context", publishedAt: now, replyCount: 0)
        let old = DiscussionSnapshot(storyID: 100, storyText: "Before", comments: [oldComment], topLevelCount: 1, failedCount: 0, fetchedAt: now.addingTimeInterval(-1_000))
        let fresh = snapshot(id: 100, date: now)
        let cache = DiscussionMemoryCache(values: [100: old])
        let store = DiscussionStore(client: DiscussionStubClient(result: .success(fresh)), cache: cache, now: { self.now })
        await store.load(storyID: 100)
        XCTAssertEqual(store.snapshot, fresh)
        XCTAssertFalse(store.isStale, "A complete live response must clear the cached-data label")
        XCTAssertFalse(store.loadFailed)
        let saved = await cache.snapshot(storyID: 100)
        XCTAssertEqual(saved, fresh)
    }

    func testManualRefreshBypassesCacheOnlyForTheRequestedLoad() async {
        let cache = DiscussionMemoryCache(values: [100: snapshot(id: 100, date: now), 200: snapshot(id: 200, date: now)])
        let client = DiscussionCountingClient()
        let store = DiscussionStore(client: client, cache: cache, now: { self.now })
        var refresh = DiscussionRefreshGate()
        await store.load(storyID: 100, force: refresh.consume())
        let initialCalls = await client.calls
        XCTAssertEqual(initialCalls, [])

        refresh.request()
        await store.load(storyID: 100, force: refresh.consume())
        await store.load(storyID: 200, force: refresh.consume())
        await store.load(storyID: 100, force: refresh.consume())
        let afterSelectionChanges = await client.calls
        XCTAssertEqual(afterSelectionChanges, [100], "Switching threads after a manual refresh must use their fresh caches")

        refresh.request()
        await store.load(storyID: 100, force: refresh.consume())
        let afterSecondRefresh = await client.calls
        XCTAssertEqual(afterSecondRefresh, [100, 100], "Another explicit refresh must still fetch")
    }

    func testMalformedOrWrongThreadSnapshotsCannotEnterStore() async {
        let invalid = DiscussionSnapshot(storyID: 200, storyText: "", comments: [], topLevelCount: 0, failedCount: 0, fetchedAt: now)
        let store = DiscussionStore(client: DiscussionStubClient(result: .success(invalid)), cache: DiscussionMemoryCache(), now: { self.now })
        await store.load(storyID: 100)
        XCTAssertNil(store.snapshot)
        XCTAssertTrue(store.loadFailed)
    }

    func testSupersededAndCancelledLoadsCannotOverwriteCurrentThread() async {
        let client = DiscussionDelayedClient(date: now)
        let store = DiscussionStore(client: client, cache: DiscussionMemoryCache(), now: { self.now })
        let old = Task { await store.load(storyID: 1) }
        try? await Task.sleep(for: .milliseconds(5))
        await store.load(storyID: 2)
        await old.value
        XCTAssertEqual(store.selectedID, 2)
        XCTAssertEqual(store.snapshot?.storyID, 2)
        let cancelled = Task { await store.load(storyID: 1, force: true) }
        try? await Task.sleep(for: .milliseconds(5))
        cancelled.cancel()
        await cancelled.value
        XCTAssertNil(store.snapshot)
        XCTAssertFalse(store.loadFailed)
        XCTAssertFalse(store.isLoading)
    }

    private func commentFixture(id: Int) -> [String: Any] {
        ["id": id, "type": "comment", "parent": 100, "by": "reader\(id)", "text": "<p>A useful thought \(id)</p>", "time": now.timeIntervalSince1970 - 100, "kids": [1000, 1001]]
    }
    private func response(_ value: Any) -> RadarHTTPResponse {
        RadarHTTPResponse(data: try! JSONSerialization.data(withJSONObject: value), statusCode: 200)
    }
    private func snapshot(id: Int, date: Date) -> DiscussionSnapshot {
        DiscussionSnapshot(storyID: id, storyText: "Question", comments: [], topLevelCount: 0, failedCount: 0, fetchedAt: date)
    }
    private func story(id: Int) -> RadarStory {
        RadarStory(id: id, title: "Ask HN: What changed your mind?", destinationURL: URL(string: "https://news.ycombinator.com/item?id=\(id)")!, author: "reader", score: 20, commentCount: 8, publishedAt: now)
    }
}

private actor DiscussionStubTransport: RadarHTTPTransport {
    let responses: [String: RadarHTTPResponse]
    let delay: Duration
    private(set) var maximumConcurrent = 0
    private(set) var paths: [String] = []
    private var active = 0
    init(responses: [String: RadarHTTPResponse], delay: Duration = .zero) { self.responses = responses; self.delay = delay }
    func data(for request: URLRequest, maximumBytes: Int) async throws -> RadarHTTPResponse {
        active += 1
        maximumConcurrent = max(maximumConcurrent, active)
        defer { active -= 1 }
        let path = request.url!.path
        paths.append(path)
        if delay > .zero { try await Task.sleep(for: delay) }
        return responses[path] ?? RadarHTTPResponse(data: Data(), statusCode: 404)
    }
}

private actor DiscussionMemoryCache: DiscussionCaching {
    var values: [Int: DiscussionSnapshot]
    init(values: [Int: DiscussionSnapshot] = [:]) { self.values = values }
    func snapshot(storyID: Int) -> DiscussionSnapshot? { values[storyID] }
    func save(_ snapshot: DiscussionSnapshot) { values[snapshot.storyID] = snapshot }
}

private struct DiscussionStubClient: DiscussionClient {
    let result: Result<DiscussionSnapshot, RadarClientError>
    func fetch(storyID: Int, at date: Date) async throws -> DiscussionSnapshot { try result.get() }
}

private struct DiscussionDelayedClient: DiscussionClient {
    let date: Date
    func fetch(storyID: Int, at: Date) async throws -> DiscussionSnapshot {
        // Deliberately ignores cancellation to exercise the store generation fence.
        try? await Task.sleep(for: storyID == 1 ? .milliseconds(70) : .milliseconds(1))
        return DiscussionSnapshot(storyID: storyID, storyText: "", comments: [], topLevelCount: 0, failedCount: 0, fetchedAt: date)
    }
}

private actor DiscussionCountingClient: DiscussionClient {
    private(set) var calls: [Int] = []
    func fetch(storyID: Int, at date: Date) -> DiscussionSnapshot {
        calls.append(storyID)
        return DiscussionSnapshot(storyID: storyID, storyText: "", comments: [], topLevelCount: 0, failedCount: 0, fetchedAt: date)
    }
}
