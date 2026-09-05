import XCTest
@testable import NotchCalendar

@MainActor
final class WorkspaceAutomationTests: XCTestCase {
    func testShortcutStartsSharedTimerAndRefusesToOverwriteActiveOrPausedWork() throws {
        try withRuntime { runtime, _, destinations in
            let now = Date(timeIntervalSince1970: 1_788_602_400)
            try runtime.startFocus(minutes: 37, taskLabel: "写周报", now: now)
            XCTAssertTrue(runtime.focusTimer.isRunning)
            XCTAssertEqual(runtime.focusTimer.selectedMinutes, 37)
            XCTAssertEqual(runtime.focusTimer.taskLabel, "写周报")
            XCTAssertEqual(destinations.values, [.focus])
            XCTAssertThrowsError(try runtime.startFocus(minutes: 25, taskLabel: "不要覆盖", now: now))
            runtime.focusTimer.toggle(now: now)
            XCTAssertThrowsError(try runtime.startFocus(minutes: 25, taskLabel: "不要覆盖", now: now))
            XCTAssertEqual(runtime.focusTimer.taskLabel, "写周报")
        }
    }

    func testShortcutValidatesBeforeMutationAndAppendsToLatestNote() throws {
        try withRuntime { runtime, defaults, destinations in
            XCTAssertThrowsError(try runtime.startFocus(minutes: 181, taskLabel: "invalid"))
            XCTAssertEqual(runtime.focusTimer.taskLabel, "")
            XCTAssertFalse(runtime.focusTimer.isRunning)
            defaults.set("最新便笺", forKey: MeetingNotesStore.scratchpadKey)
            try runtime.appendScratchpad(text: "补充内容")
            XCTAssertEqual(defaults.string(forKey: MeetingNotesStore.scratchpadKey), "最新便笺\n补充内容")
            XCTAssertEqual(runtime.notes.scratchpadText, "最新便笺\n补充内容")
            XCTAssertEqual(destinations.values, [.scratchpad])
            XCTAssertThrowsError(try runtime.appendScratchpad(text: " \n "))
        }
    }

    private final class Destinations { var values: [WorkspaceDestination] = [] }
    private func withRuntime(_ body: (WorkspaceAutomation, UserDefaults, Destinations) throws -> Void) throws {
        let suite = "NotchCalendarTests.Automation.\(UUID())"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let destinations = Destinations()
        let runtime = WorkspaceAutomation(focusTimer: FocusTimerModel(defaults: defaults), notes: MeetingNotesStore(defaults: defaults), navigate: { destinations.values.append($0) }, joinMeeting: {})
        try body(runtime, defaults, destinations)
    }
}
