import Foundation
import XCTest
@testable import NotchCalendar

final class FileShelfTests: XCTestCase {
    func testDirectoryReaderHidesDotFilesAndKeepsFoldersFirst() throws {
        try withDirectory { directory in
            let folder = directory.appendingPathComponent("Folder")
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: false)
            try Data("visible".utf8).write(to: directory.appendingPathComponent("Visible.txt"))
            try Data("hidden".utf8).write(to: directory.appendingPathComponent(".Hidden.txt"))

            let visible = try FileShelfDirectoryReader.items(
                at: directory,
                showsHiddenFiles: false,
                sort: .name
            )
            XCTAssertEqual(visible.map(\.name), ["Folder", "Visible.txt"])
            XCTAssertTrue(visible[0].isDirectory)

            let all = try FileShelfDirectoryReader.items(
                at: directory,
                showsHiddenFiles: true,
                sort: .name
            )
            XCTAssertEqual(Set(all.map(\.name)), ["Folder", "Visible.txt", ".Hidden.txt"])
        }
    }

    func testModifiedSortIsNewestFirstWithinEachKind() throws {
        try withDirectory { directory in
            let old = directory.appendingPathComponent("Old.txt")
            let new = directory.appendingPathComponent("New.txt")
            try Data().write(to: old)
            try Data().write(to: new)
            try FileManager.default.setAttributes(
                [.modificationDate: Date(timeIntervalSince1970: 100)],
                ofItemAtPath: old.path
            )
            try FileManager.default.setAttributes(
                [.modificationDate: Date(timeIntervalSince1970: 200)],
                ofItemAtPath: new.path
            )

            let items = try FileShelfDirectoryReader.items(
                at: directory,
                showsHiddenFiles: false,
                sort: .modified
            )
            XCTAssertEqual(items.map(\.name), ["New.txt", "Old.txt"])
        }
    }

    func testRootBoundaryRejectsSiblingAndEscapingSymbolicLink() throws {
        try withDirectory { parent in
            let root = parent.appendingPathComponent("root")
            let child = root.appendingPathComponent("child")
            let sibling = parent.appendingPathComponent("root-copy")
            try FileManager.default.createDirectory(at: child, withIntermediateDirectories: true)
            try FileManager.default.createDirectory(at: sibling, withIntermediateDirectories: false)
            let link = root.appendingPathComponent("outside")
            try FileManager.default.createSymbolicLink(at: link, withDestinationURL: sibling)

            XCTAssertTrue(FileShelfDirectoryReader.contains(child, inside: root))
            XCTAssertFalse(FileShelfDirectoryReader.contains(sibling, inside: root))
            XCTAssertFalse(FileShelfDirectoryReader.contains(link, inside: root))
        }
    }

    @MainActor
    func testPreferencesAndRootBookmarkPersistAcrossInstances() throws {
        try withDirectory { directory in
            let suite = "FileShelfTests.\(UUID().uuidString)"
            let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
            defer { defaults.removePersistentDomain(forName: suite) }

            let store = FileShelfStore(defaults: defaults)
            store.isEnabled = true
            store.showsHiddenFiles = true
            store.sort = .modified
            store.setRootDirectory(directory)

            let restored = FileShelfStore(defaults: defaults)
            XCTAssertTrue(restored.isEnabled)
            XCTAssertTrue(restored.showsHiddenFiles)
            XCTAssertEqual(restored.sort, .modified)
            XCTAssertEqual(restored.rootURL, directory.resolvingSymlinksInPath().standardizedFileURL)
        }
    }

    @MainActor
    func testMultipleFavoritesPreserveOrderAndSelection() throws {
        try withDirectory { parent in
            let first = parent.appendingPathComponent("Downloads")
            let second = parent.appendingPathComponent("Projects")
            try FileManager.default.createDirectory(at: first, withIntermediateDirectories: false)
            try FileManager.default.createDirectory(at: second, withIntermediateDirectories: false)
            let suite = "FileShelfFavoritesTests.\(UUID().uuidString)"
            let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
            defer { defaults.removePersistentDomain(forName: suite) }

            let store = FileShelfStore(defaults: defaults)
            store.addRootDirectories([first, second])
            XCTAssertEqual(store.locations.map(\.name), ["Downloads", "Projects"])
            XCTAssertEqual(store.selectedLocation?.name, "Downloads")
            let projectsID = try XCTUnwrap(store.locations.last?.id)
            store.moveLocation(projectsID, by: -1)
            store.selectLocation(projectsID)

            let restored = FileShelfStore(defaults: defaults)
            XCTAssertEqual(restored.locations.map(\.name), ["Projects", "Downloads"])
            XCTAssertEqual(restored.selectedLocationID, projectsID)
            restored.removeLocation(projectsID)
            XCTAssertEqual(restored.locations.map(\.name), ["Downloads"])
            XCTAssertEqual(restored.selectedLocation?.name, "Downloads")
        }
    }

    @MainActor
    func testLegacySingleBookmarkMigratesIntoFavorites() throws {
        try withDirectory { directory in
            let suite = "FileShelfMigrationTests.\(UUID().uuidString)"
            let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
            defer { defaults.removePersistentDomain(forName: suite) }
            let bookmark = try directory.bookmarkData(
                options: [],
                includingResourceValuesForKeys: [.isDirectoryKey],
                relativeTo: nil
            )
            defaults.set(bookmark, forKey: FileShelfStore.bookmarkKey)

            let store = FileShelfStore(defaults: defaults)
            XCTAssertEqual(store.locations.count, 1)
            XCTAssertEqual(store.rootURL, directory.resolvingSymlinksInPath().standardizedFileURL)
            XCTAssertNotNil(defaults.data(forKey: FileShelfStore.locationsKey))
        }
    }

    @MainActor
    func testDisclosureTreeAndNavigationHistoryStayInsideFavorite() async throws {
        try await withAsyncDirectory { root in
            let child = root.appendingPathComponent("Child")
            try FileManager.default.createDirectory(at: child, withIntermediateDirectories: false)
            try Data("nested".utf8).write(to: child.appendingPathComponent("Nested.txt"))
            let suite = "FileShelfTreeTests.\(UUID().uuidString)"
            let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
            defer { defaults.removePersistentDomain(forName: suite) }

            let store = FileShelfStore(defaults: defaults)
            store.isEnabled = true
            store.setRootDirectory(root)
            try await waitUntil { !store.isLoading && store.items.count == 1 }
            let folder = try XCTUnwrap(store.items.first)
            store.toggleDirectoryExpansion(folder)
            try await waitUntil { store.childrenByDirectory[folder.url]?.count == 1 }
            XCTAssertEqual(store.visibleItems.map(\.depth), [0, 1])
            XCTAssertEqual(store.visibleItems.last?.item.name, "Nested.txt")

            store.open(folder)
            try await waitUntil { store.currentURL == child.standardizedFileURL && !store.isLoading }
            XCTAssertTrue(store.canNavigateBack)
            store.navigateBack()
            try await waitUntil { store.currentURL == root.standardizedFileURL && !store.isLoading }
            XCTAssertTrue(store.canNavigateForward)
            store.navigateForward()
            try await waitUntil { store.currentURL == child.standardizedFileURL && !store.isLoading }
        }
    }

    @MainActor
    func testDropPanelStaysNarrowAndTracksExpansion() async throws {
        let suite = "FileShelfPanelTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        defaults.set(true, forKey: FileShelfStore.enabledKey)
        let calendar = CalendarManager(
            dataSource: CalendarSelectionTestDataSource(eventsByCalendarID: [:]),
            defaults: defaults
        )
        let meetingAssistant = MeetingAssistant(
            calendar: calendar,
            preferences: MeetingPreferences(defaults: defaults),
            notifications: FileShelfTestNotifications(),
            hotKey: FileShelfTestHotKey()
        )
        let state = AppState(
            calendar: calendar,
            defaults: defaults,
            recoveryDirectory: FileManager.default.temporaryDirectory
                .appendingPathComponent("NotchCalendar-FileShelfPanel-\(UUID())"),
            meetingAssistant: meetingAssistant,
            reloadWidgetTimelines: { _ in }
        )
        let controller = NotchWindowController(state: state)
        controller.show()
        let notchPanel = try XCTUnwrap(NSApp.windows.first { $0 is NotchPanel })
        let dropPanel = try XCTUnwrap(NSApp.windows.first { $0 is FileDropPanel })
        defer {
            notchPanel.orderOut(nil)
            dropPanel.orderOut(nil)
        }

        XCTAssertTrue(dropPanel.isVisible)
        XCTAssertLessThanOrEqual(dropPanel.frame.width, notchPanel.frame.width)
        XCTAssertTrue(notchPanel.ignoresMouseEvents)

        state.isExpanded = true
        try await Task.sleep(for: .milliseconds(80))
        XCTAssertFalse(dropPanel.isVisible)

        state.isExpanded = false
        try await Task.sleep(for: .milliseconds(80))
        XCTAssertTrue(dropPanel.isVisible)
        withExtendedLifetime(controller) {}
    }

    private func withDirectory(_ body: (URL) throws -> Void) throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("NotchCalendar-FileShelfTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        try body(directory)
    }

    @MainActor
    private func withAsyncDirectory(_ body: (URL) async throws -> Void) async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("NotchCalendar-FileShelfTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        try await body(directory)
    }

    @MainActor
    private func waitUntil(
        timeout: Duration = .seconds(2),
        condition: @escaping @MainActor () -> Bool
    ) async throws {
        let clock = ContinuousClock()
        let deadline = clock.now.advanced(by: timeout)
        while !condition() {
            guard clock.now < deadline else {
                XCTFail("Timed out waiting for file shelf state")
                return
            }
            try await Task.sleep(for: .milliseconds(20))
        }
    }
}

@MainActor
private final class FileShelfTestNotifications: MeetingNotificationScheduling {
    func authorization() async -> MeetingNotificationAuthorization { .denied }
    func requestAuthorization() async throws -> Bool { false }
    func prepare(language: AppLanguage) {}
    func pending() async -> [String: String] { [:] }
    func delivered() async -> [MeetingDeliveredReminder] { [] }
    func removePending(_ identifiers: [String]) {}
    func removeDelivered(_ identifiers: [String]) {}
    func add(_ plan: MeetingReminderPlan, language: AppLanguage) async throws {}
}

@MainActor
private final class FileShelfTestHotKey: MeetingHotKeyRegistering {
    func register(
        letter: String,
        modifiers: MeetingHotKeyModifiers,
        action: @escaping @MainActor () -> Void
    ) -> Bool { true }

    func unregister() {}
}
