import Foundation
import XCTest
@testable import NotchCalendar

@MainActor
final class BriefingTests: XCTestCase {
    private let now = Date(timeIntervalSince1970: 1_800_000_000)

    func testRSSParsesCDATAEntitiesSortsAndDeduplicatesCanonicalLinks() throws {
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?><rss version="2.0"><channel>
        <item><title>Older &amp; useful</title><link>https://github.blog/older/</link><pubDate>Thu, 03 Sep 2026 10:00:00 +0000</pubDate></item>
        <item><title><![CDATA[New &#8217; tools]]></title><link>https://github.blog/new/#section</link><pubDate>Fri, 04 Sep 2026 10:00:00 +0000</pubDate></item>
        <item><title>Duplicate</title><link>https://github.blog/new/</link><pubDate>Thu, 03 Sep 2026 10:00:00 +0000</pubDate></item>
        </channel></rss>
        """
        let articles = try BriefingXMLParser.parse(Data(xml.utf8), source: .github, at: now)
        XCTAssertEqual(articles.map(\.title), ["New ’ tools", "Older & useful"])
        XCTAssertEqual(articles.first?.url.absoluteString, "https://github.blog/new/")
        XCTAssertEqual(articles.first?.dateKind, .published)
    }

    func testAtomSelectsAlternateLinkAndDistinguishesUpdatedDate() throws {
        let xml = """
        <feed xmlns="http://www.w3.org/2005/Atom"><entry>
        <title>Swift 6.4</title><link rel="self" href="https://swift.org/atom.xml"/>
        <link rel="alternate" href="https://swift.org/blog/swift-6-4/"/>
        <updated>2026-09-04T12:30:00-04:00</updated>
        </entry><entry><title>Published article</title><link href="https://swift.org/blog/published/"/>
        <published>2026-09-03T12:30:00.000Z</published><updated>2026-09-04T12:30:00Z</updated>
        </entry></feed>
        """
        let articles = try BriefingXMLParser.parse(Data(xml.utf8), source: .swift, at: now)
        XCTAssertEqual(articles.count, 2)
        XCTAssertEqual(articles.first?.url.absoluteString, "https://swift.org/blog/swift-6-4/")
        XCTAssertEqual(articles.first?.dateKind, .updated)
        XCTAssertEqual(articles.last?.dateKind, .published)
    }

    func testParserRejectsMalformedOversizedDTDAndUnrelatedXML() {
        for xml in ["<rss><channel>", "<html><title>not a feed</title></html>"] {
            XCTAssertThrowsError(try BriefingXMLParser.parse(Data(xml.utf8), source: .github, at: now)) { error in
                XCTAssertEqual(error as? BriefingError, .malformed)
            }
        }
        let unsafe = "<!DOCTYPE rss [<!ENTITY x SYSTEM 'file:///etc/passwd'>]><rss><channel>&x;</channel></rss>"
        XCTAssertThrowsError(try BriefingXMLParser.parse(Data(unsafe.utf8), source: .github, at: now)) { error in
            XCTAssertEqual(error as? BriefingError, .unsafeXML)
        }
        XCTAssertThrowsError(try BriefingXMLParser.parse(Data(repeating: 32, count: BriefingFeedClient.maximumBytes + 1), source: .github, at: now)) { error in
            XCTAssertEqual(error as? BriefingError, .oversized)
        }
    }

    func testGitHubHTMLDoctypeInsideCDATAIsTextButRealDeclarationsStillFail() throws {
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss xmlns:content="http://purl.org/rss/1.0/modules/content/"><channel><item>
        <title>GitHub update</title><link>https://github.blog/update/</link>
        <pubDate>Fri, 04 Sep 2026 10:00:00 +0000</pubDate>
        <content:encoded><![CDATA[<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd"><html><body>Original HTML</body></html>]]></content:encoded>
        </item></channel></rss>
        """
        let articles = try BriefingXMLParser.parse(Data(xml.utf8), source: .github, at: now)
        XCTAssertEqual(articles.map(\.title), ["GitHub update"])
        for suffix in ["<!DOCTYPE rss SYSTEM 'file:///tmp/source'>", "<!ENTITY exploit SYSTEM 'file:///tmp/source'>"] {
            let attack = xml + suffix
            XCTAssertThrowsError(try BriefingXMLParser.parse(Data(attack.utf8), source: .github, at: now)) { error in
                XCTAssertEqual(error as? BriefingError, .unsafeXML)
            }
        }
        XCTAssertThrowsError(try BriefingXMLParser.parse(Data("<rss><![CDATA[unterminated".utf8), source: .github, at: now)) { error in
            XCTAssertEqual(error as? BriefingError, .malformed)
        }
    }

    func testLivePrimaryFeedsWhenExplicitlyEnabled() async throws {
        guard ProcessInfo.processInfo.environment["NOTCH_LIVE_BRIEFING"] == "1" else {
            throw XCTSkip("Set NOTCH_LIVE_BRIEFING=1 to check public feed availability.")
        }
        for source in BriefingSource.allCases {
            do {
                let snapshot = try await BriefingFeedClient().fetch(source: source, at: Date())
                print("LIVE BRIEFING \(source.rawValue): \(snapshot.articles.count) articles")
                XCTAssertFalse(snapshot.articles.isEmpty)
                XCTAssertTrue(snapshot.isValid(at: Date()))
            } catch {
                XCTFail("Live source \(source.rawValue) failed: \(error)")
            }
        }
    }

    func testInvalidDatesAndUnsafeLinksAreSkippedWithoutBreakingOtherArticles() throws {
        let xml = rss([
            item(title: "Good", link: "https://github.blog/good/"),
            item(title: "No date", link: "https://github.blog/no-date/", date: "bad-date"),
            item(title: "Future", link: "https://github.blog/future/", date: "Fri, 04 Sep 2099 10:00:00 +0000"),
            item(title: "Unsafe", link: "javascript:alert(1)"),
            item(title: "File", link: "file:///tmp/readme"),
            item(title: "Credentials", link: "https://user:pass@github.blog/secret/"),
            item(title: "", link: "https://github.blog/blank/")
        ])
        let articles = try BriefingXMLParser.parse(xml, source: .github, at: now)
        XCTAssertEqual(articles.map(\.title), ["Good"])
        XCTAssertNil(BriefingArticle.safeURL("https://"))
        XCTAssertNil(BriefingArticle.safeURL("data:text/html,test"))
    }

    func testFeedLimitsNewestTwentyAndRejectsExcessiveXMLDepth() throws {
        let xml = rss((0..<35).map { item(title: "Headline \($0)", link: "https://github.blog/\($0)/") })
        let articles = try BriefingXMLParser.parse(xml, source: .github, at: now)
        XCTAssertEqual(articles.count, 20)
        let deep = "<rss>" + String(repeating: "<a>", count: 50) + String(repeating: "</a>", count: 50) + "</rss>"
        XCTAssertThrowsError(try BriefingXMLParser.parse(Data(deep.utf8), source: .github, at: now))
    }

    func testHTTPStatusByteLimitDeadlineAndCancellation() async throws {
        let badStatus = BriefingFeedClient(transport: BriefingStubTransport(response: RadarHTTPResponse(data: Data(), statusCode: 503)))
        do { _ = try await badStatus.fetch(source: .github, at: now); XCTFail("Expected HTTP failure") }
        catch { XCTAssertEqual(error as? BriefingError, .invalidResponse(503)) }

        let oversized = BriefingFeedClient(transport: BriefingStubTransport(response: RadarHTTPResponse(data: Data(repeating: 32, count: BriefingFeedClient.maximumBytes + 1), statusCode: 200)))
        do { _ = try await oversized.fetch(source: .github, at: now); XCTFail("Expected byte limit") }
        catch { XCTAssertEqual(error as? BriefingError, .oversized) }

        let transport = BriefingStubTransport(response: RadarHTTPResponse(data: rss([item(title: "Good", link: "https://github.blog/good/")]), statusCode: 200), delay: .seconds(5))
        let deadline = BriefingFeedClient(transport: transport, deadline: .milliseconds(20))
        do { _ = try await deadline.fetch(source: .github, at: now); XCTFail("Expected deadline") }
        catch { XCTAssertEqual(error as? BriefingError, .timedOut) }

        let client = BriefingFeedClient(transport: transport)
        let task = Task { try await client.fetch(source: .github, at: now) }
        try await Task.sleep(for: .milliseconds(20))
        task.cancel()
        do { _ = try await task.value; XCTFail("Expected cancellation") }
        catch { XCTAssertTrue(error is CancellationError) }
    }

    func testDiskCacheRoundTripsStaleAndRejectsCorruptFutureOrWrongSource() async throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("BriefingTests-\(UUID())")
        defer { try? FileManager.default.removeItem(at: directory) }
        let cache = BriefingDiskCache(directoryURL: directory)
        let snapshot = snapshot(.github, fetchedAt: now.addingTimeInterval(-1_801))
        try await cache.save(snapshot)
        let loaded = await cache.snapshot(for: .github, at: now)
        XCTAssertEqual(loaded, snapshot)
        XCTAssertFalse(try XCTUnwrap(loaded).isFresh(at: now))
        let fresh = self.snapshot(.github, fetchedAt: now)
        XCTAssertTrue(fresh.isFresh(at: now))
        XCTAssertFalse(fresh.isFresh(at: now.addingTimeInterval(1_800)))

        let path = directory.appendingPathComponent("github.json")
        try Data("bad-json".utf8).write(to: path)
        let corrupted = await cache.snapshot(for: .github, at: now)
        XCTAssertNil(corrupted)
        let future = self.snapshot(.github, fetchedAt: now.addingTimeInterval(600))
        try JSONEncoder().encode(future).write(to: path)
        let futureLoaded = await cache.snapshot(for: .github, at: now)
        XCTAssertNil(futureLoaded)
        try JSONEncoder().encode(self.snapshot(.swift, fetchedAt: now)).write(to: path)
        let wrongSource = await cache.snapshot(for: .github, at: now)
        XCTAssertNil(wrongSource)
    }

    func testPartialOfflineLoadKeepsStaleCacheAndSuccessfulSources() async {
        let defaults = makeDefaults()
        defer { defaults.removePersistentDomain(forName: defaultsName(defaults)) }
        let stale = snapshot(.github, fetchedAt: now.addingTimeInterval(-4_000))
        let swift = snapshot(.swift, fetchedAt: now)
        let cache = BriefingMemoryCache(snapshots: [.github: stale])
        let store = BriefingStore(client: BriefingStubClient(snapshots: [.swift: swift]), cache: cache, defaults: defaults, now: { self.now })
        await store.load()
        XCTAssertEqual(store.snapshots[.github], stale)
        XCTAssertEqual(store.snapshots[.swift], swift)
        XCTAssertEqual(store.failedSources, [.github, .nasa])
        XCTAssertTrue(store.isStale(.github))
        XCTAssertFalse(store.isLoading)
        XCTAssertEqual(store.visibleArticles.count, 2)
    }

    func testFreshCacheReentrySkipsNetworkAndForceRefreshReplacesIt() async {
        let defaults = makeDefaults()
        defer { defaults.removePersistentDomain(forName: defaultsName(defaults)) }
        let cached = Dictionary(uniqueKeysWithValues: BriefingSource.allCases.map { ($0, snapshot($0, fetchedAt: now)) })
        let client = BriefingCountingClient(snapshots: cached)
        let cache = BriefingMemoryCache(snapshots: cached)
        let store = BriefingStore(client: client, cache: cache, defaults: defaults, now: { self.now })
        await store.load()
        let initialCalls = await client.calls
        XCTAssertEqual(initialCalls, 0)
        XCTAssertEqual(store.cachedSources.count, 3)
        await store.load(forceRefresh: true)
        let refreshedCalls = await client.calls
        XCTAssertEqual(refreshedCalls, 3)
        XCTAssertTrue(store.cachedSources.isEmpty)
    }

    func testBookmarkReadSearchAndSavedHeadlineSurviveReentryAndFeedRotation() async {
        let defaults = makeDefaults()
        defer { defaults.removePersistentDomain(forName: defaultsName(defaults)) }
        let old = article(.github, title: "Copilot agent update")
        let store = BriefingStore(client: BriefingStubClient(snapshots: [:]), cache: BriefingMemoryCache(), defaults: defaults, now: { self.now })
        store.toggleSaved(old)
        store.markRead(old)
        let reopened = BriefingStore(client: BriefingStubClient(snapshots: [:]), cache: BriefingMemoryCache(), defaults: defaults, now: { self.now })
        reopened.filter = .saved
        XCTAssertTrue(reopened.isSaved(old))
        XCTAssertTrue(reopened.isRead(old))
        XCTAssertEqual(reopened.visibleArticles, [old])
        reopened.search = "COPILOT"
        XCTAssertEqual(reopened.visibleArticles.count, 1)
        reopened.selectedSource = .nasa
        XCTAssertTrue(reopened.visibleArticles.isEmpty)
        reopened.selectedSource = nil
        reopened.toggleRead(old)
        XCTAssertFalse(reopened.isRead(old))
        reopened.toggleSaved(old)
        XCTAssertTrue(reopened.visibleArticles.isEmpty)
    }

    func testCorruptLibraryRecoversAndSaveCapacityDoesNotEvictExistingBookmarks() {
        let defaults = makeDefaults()
        defer { defaults.removePersistentDomain(forName: defaultsName(defaults)) }
        defaults.set(Data("invalid".utf8), forKey: BriefingLibrary.storageKey)
        XCTAssertEqual(BriefingLibrary.load(from: defaults), BriefingLibrary())
        var library = BriefingLibrary()
        for index in 0..<100 { XCTAssertTrue(library.toggleSaved(article(.github, title: "Item \(index)", suffix: "\(index)"))) }
        XCTAssertFalse(library.toggleSaved(article(.github, suffix: "overflow")))
        XCTAssertEqual(library.saved.count, 100)
        XCTAssertTrue(library.saved.contains { $0.id.hasSuffix("/0/") })
    }

    func testTopicRulesUseWordsAndSourcesWithoutInventingSummaries() {
        XCTAssertEqual(BriefingTopic.infer(title: "Email maintenance", source: .github), .update)
        XCTAssertEqual(BriefingTopic.infer(title: "Copilot agents", source: .github), .ai)
        XCTAssertEqual(BriefingTopic.infer(title: "Security release", source: .github), .security)
        XCTAssertEqual(BriefingTopic.infer(title: "New telescope", source: .nasa), .space)
    }

    private func article(_ source: BriefingSource, title: String = "Original headline", suffix: String = "article") -> BriefingArticle {
        BriefingArticle(source: source, title: title, url: URL(string: "https://\(source.rawValue).example/\(suffix)/")!, publishedAt: now.addingTimeInterval(-86_400), dateKind: .published)
    }

    private func snapshot(_ source: BriefingSource, fetchedAt: Date) -> BriefingSnapshot {
        BriefingSnapshot(source: source, articles: [article(source)], fetchedAt: fetchedAt)
    }

    private func item(title: String, link: String, date: String = "Fri, 04 Sep 2026 10:00:00 +0000") -> String {
        "<item><title>\(title)</title><link>\(link)</link><pubDate>\(date)</pubDate></item>"
    }

    private func rss(_ items: [String]) -> Data { Data(("<rss><channel>" + items.joined() + "</channel></rss>").utf8) }

    private func makeDefaults() -> UserDefaults {
        let name = "BriefingTests.\(UUID())"
        let defaults = UserDefaults(suiteName: name)!
        defaults.set(name, forKey: "test.suiteName")
        return defaults
    }
    private func defaultsName(_ defaults: UserDefaults) -> String { defaults.string(forKey: "test.suiteName")! }
}

private struct BriefingStubTransport: RadarHTTPTransport {
    let response: RadarHTTPResponse
    var delay: Duration = .zero
    func data(for request: URLRequest, maximumBytes: Int) async throws -> RadarHTTPResponse {
        try await Task.sleep(for: delay)
        return response
    }
}

private struct BriefingStubClient: BriefingClient {
    let snapshots: [BriefingSource: BriefingSnapshot]
    func fetch(source: BriefingSource, at date: Date) async throws -> BriefingSnapshot {
        guard let snapshot = snapshots[source] else { throw URLError(.notConnectedToInternet) }
        return snapshot
    }
}

private actor BriefingCountingClient: BriefingClient {
    let snapshots: [BriefingSource: BriefingSnapshot]
    var calls = 0
    init(snapshots: [BriefingSource: BriefingSnapshot]) { self.snapshots = snapshots }
    func fetch(source: BriefingSource, at date: Date) async throws -> BriefingSnapshot {
        calls += 1
        guard let snapshot = snapshots[source] else { throw BriefingError.noArticles }
        return snapshot
    }
}

private actor BriefingMemoryCache: BriefingCache {
    var snapshots: [BriefingSource: BriefingSnapshot]
    init(snapshots: [BriefingSource: BriefingSnapshot] = [:]) { self.snapshots = snapshots }
    func snapshot(for source: BriefingSource, at now: Date) -> BriefingSnapshot? { snapshots[source] }
    func save(_ snapshot: BriefingSnapshot) { snapshots[snapshot.source] = snapshot }
}
