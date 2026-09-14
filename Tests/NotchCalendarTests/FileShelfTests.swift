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
