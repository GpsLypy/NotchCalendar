import AppKit
import SwiftUI
import XCTest
@testable import NotchCalendar

/// Opt-in production-view rendering and live-source smoke run. Ordinary tests stay offline.
final class MarketingCaptureTests: XCTestCase {
    @MainActor
    func testRenderPublicFeatureViews() async throws {
        guard let path = ProcessInfo.processInfo.environment["NOTCH_CAPTURE_PATH"] else {
            throw XCTSkip("Set NOTCH_CAPTURE_PATH to render public-source marketing assets.")
        }
        let destination = URL(fileURLWithPath: path, isDirectory: true)
        try FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true)
        let suite = "MarketingCapture.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }

        let market = MarketStore(defaults: defaults, keyStorage: CaptureEmptyKey())
        try await render(MarketWorkspaceView(store: market), name: "markets", to: destination)
        try await render(MarketWorkspaceView(store: market), name: "markets-small", to: destination, width: 647, height: 520)

        let briefing = BriefingStore(cache: BriefingDiskCache(directoryURL: destination.appendingPathComponent("public-cache/briefing")), defaults: defaults)
        await briefing.load()
        for source in briefing.failedSources {
            do { _ = try await BriefingFeedClient().fetch(source: source, at: Date()) }
            catch { print("LIVE FEED FAILURE \(source.rawValue): \(error)") }
        }
        XCTAssertEqual(briefing.snapshots.count, 3, "All configured primary sources must parse live.")
        XCTAssertFalse(briefing.visibleArticles.isEmpty)
        // Save one article per source so the saved shelf shows the real source variety.
        for source in BriefingSource.allCases {
            if let article = briefing.snapshots[source]?.articles.first { briefing.toggleSaved(article) }
        }
        if let article = briefing.visibleArticles.first { briefing.markRead(article) }
        try await render(BriefingWorkspaceView(store: briefing), name: "briefing", to: destination)
        try await render(BriefingWorkspaceView(store: briefing), name: "briefing-small", to: destination, width: 647, height: 520)
        briefing.filter = .saved
        try await render(BriefingWorkspaceView(store: briefing), name: "briefing-saved", to: destination)

        let topics = RadarStore(cache: RadarDiskCache(directoryURL: destination.appendingPathComponent("public-cache/radar")))
        await topics.load(.ask)
        let selected = try XCTUnwrap(topics.stories.sorted { $0.commentCount > $1.commentCount }.first)
        let discussion = DiscussionStore(cache: DiscussionDiskCache(fileURL: destination.appendingPathComponent("public-cache/threads.json")))
        await discussion.load(storyID: selected.id)
        XCTAssertFalse(discussion.loadFailed)
        XCTAssertFalse(discussion.snapshot?.comments.isEmpty ?? true)
        let notebook = DiscussionNotebook(defaults: defaults)
        notebook.save(story: selected, note: "演示笔记：先读原文，再看看不同观点的依据。", stance: .exploring, isSaved: true)
        try await render(DiscussionWorkspaceView(topics: topics, thread: discussion, notebook: notebook, selected: selected), name: "discussion", to: destination)
        try await render(DiscussionWorkspaceView(topics: topics, thread: discussion, notebook: notebook, selected: selected), name: "discussion-detail", to: destination, width: 700, height: 980)
        try await render(DiscussionWorkspaceView(topics: topics, thread: discussion, notebook: notebook, selected: selected), name: "discussion-small", to: destination, width: 647, height: 520)
        let manifest = "Native SwiftUI views rendered offscreen from v0.6.0 code. Public feeds fetched at \(Date().ISO8601Format()). No market key or invented prices. Private-note text explicitly marked as a demonstration, stored in an isolated disposable preferences suite. No actual desktop interaction is claimed."
        try manifest.write(to: destination.appendingPathComponent("capture-provenance.txt"), atomically: true, encoding: .utf8)
    }

    @MainActor
    private func render<V: View>(_ view: V, name: String, to destination: URL, width: CGFloat = 980, height: CGFloat = 760) async throws {
        let content = view.environment(\.appLanguage, .simplifiedChinese)
            .environment(\.locale, Locale(identifier: "zh_CN"))
            .preferredColorScheme(.dark)
            .environment(\.colorScheme, .dark)
            .frame(width: width, height: height)
        let hosting = NSHostingView(rootView: content)
        let rect = NSRect(x: 0, y: 0, width: width, height: height)
        let window = NSWindow(contentRect: rect, styleMask: [.borderless], backing: .buffered, defer: false)
        window.appearance = NSAppearance(named: .darkAqua)
        window.contentView = hosting
        hosting.frame = rect
        try await Task.sleep(for: .milliseconds(500))
        hosting.layoutSubtreeIfNeeded()
        let bitmap = try XCTUnwrap(hosting.bitmapImageRepForCachingDisplay(in: rect))
        hosting.cacheDisplay(in: rect, to: bitmap)
        let png = try XCTUnwrap(bitmap.representation(using: .png, properties: [:]))
        try png.write(to: destination.appendingPathComponent(name + ".png"), options: .atomic)
    }
}

@MainActor private struct CaptureEmptyKey: MarketKeyStorage {
    func read() throws -> String? { nil }
    func save(_ key: String) throws {}
    func remove() throws {}
}
