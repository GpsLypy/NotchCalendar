import AppKit
import XCTest
@testable import NotchCalendar

@MainActor
final class ActivityQualityTests: XCTestCase {
    func testIdleAndPausedContentDoNotNeedSecondTicks() {
        XCTAssertEqual(ActivityClockPolicy.compactInterval(now: Date(timeIntervalSince1970: 1_800_000_000), events: [], showsMeetings: true, displaysUpcoming: false, visibleFocusRunning: false), 60)
        XCTAssertEqual(ActivityClockPolicy.compactInterval(now: Date(timeIntervalSince1970: 1_800_000_000), events: [], showsMeetings: false, displaysUpcoming: false, visibleFocusRunning: true), 1)
    }

    func testIdleClockRefreshesAtTheMinuteBoundary() {
        let now = Date(timeIntervalSince1970: 1_800_000_025)
        XCTAssertEqual(ActivityClockPolicy.compactInterval(now: now, events: [], showsMeetings: true, displaysUpcoming: true, visibleFocusRunning: false), 35)
        XCTAssertEqual(ActivityClockPolicy.compactInterval(now: now, events: [], showsMeetings: false, displaysUpcoming: true, visibleFocusRunning: false), 35)
    }

    func testMeetingBoundaryIsNotDelayedByMinuteRefresh() {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let event = CalendarSelectionTestDataSource.event(id: "start", start: now.addingTimeInterval(4), end: now.addingTimeInterval(8))
        XCTAssertEqual(ActivityClockPolicy.compactInterval(now: now, events: [event], showsMeetings: true, displaysUpcoming: false, visibleFocusRunning: false), 4)
        XCTAssertEqual(ActivityClockPolicy.compactInterval(now: now.addingTimeInterval(4), events: [event], showsMeetings: true, displaysUpcoming: false, visibleFocusRunning: false), 1)
        XCTAssertEqual(ActivityClockPolicy.compactInterval(now: now.addingTimeInterval(8), events: [event], showsMeetings: true, displaysUpcoming: false, visibleFocusRunning: false), 52)
    }

    func testIneligibleEventsCannotScheduleFastRefresh() {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        var event = CalendarSelectionTestDataSource.event(id: "cancelled", start: now.addingTimeInterval(1), end: now.addingTimeInterval(8))
        event.isEligibleForMeeting = false
        XCTAssertEqual(ActivityClockPolicy.compactInterval(now: now, events: [event], showsMeetings: true, displaysUpcoming: false, visibleFocusRunning: false), 60)
        event.isEligibleForMeeting = true
        XCTAssertEqual(ActivityClockPolicy.compactInterval(now: now, events: [event], showsMeetings: false, displaysUpcoming: true, visibleFocusRunning: false), 60)
    }

    func testBackgroundFocusCompletesWithoutAnyViewClock() async throws {
        let suite = "FocusDeadline.\(UUID())"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        defaults.set(2, forKey: "workspace.focus.remainingSeconds")
        defaults.set(true, forKey: "workspace.focus.isRunning")
        defaults.set(Date().addingTimeInterval(0.3).timeIntervalSinceReferenceDate, forKey: "workspace.focus.targetDate")
        let state = makeState(defaults: defaults)
        XCTAssertTrue(state.focusTimer.isRunning)
        try await Task.sleep(for: .milliseconds(750))
        XCTAssertEqual(state.focusTimer.remainingSeconds, 0)
        XCTAssertFalse(state.focusTimer.isRunning)
        XCTAssertEqual(state.focusTimer.history.count, 1)
        state.focusTimer.synchronize()
        XCTAssertEqual(state.focusTimer.history.count, 1)
    }

    func testPausingCancelsBackgroundCompletion() async throws {
        let suite = "FocusPauseDeadline.\(UUID())"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        defaults.set(2, forKey: "workspace.focus.remainingSeconds")
        defaults.set(true, forKey: "workspace.focus.isRunning")
        defaults.set(Date().addingTimeInterval(0.3).timeIntervalSinceReferenceDate, forKey: "workspace.focus.targetDate")
        let state = makeState(defaults: defaults)
        state.focusTimer.toggle()
        try await Task.sleep(for: .milliseconds(750))
        XCTAssertFalse(state.focusTimer.isRunning)
        XCTAssertTrue(state.focusTimer.hasUnfinishedSession)
        XCTAssertTrue(state.focusTimer.history.isEmpty)
    }

    func testNativeNotchKeyboardAndSyntheticWakeReset() async throws {
        guard ProcessInfo.processInfo.environment["NOTCH_DESK_INTERACTION"] == "1" else {
            throw XCTSkip("Opt in for a temporary native notch panel with NOTCH_DESK_INTERACTION=1")
        }
        let suite = "NotchKeys.\(UUID())"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let state = makeState(defaults: defaults)
        let controller = NotchWindowController(state: state)
        controller.show()
        let panel = try XCTUnwrap(NSApplication.shared.windows.first { $0 is NotchPanel })
        defer { panel.orderOut(nil) }
        state.isExpanded = true
        try await Task.sleep(for: .milliseconds(450))
        panel.makeKey()
        func key(_ text: String, _ code: UInt16, _ modifiers: NSEvent.ModifierFlags = []) throws {
            let event = try XCTUnwrap(NSEvent.keyEvent(with: .keyDown, location: .zero,
                modifierFlags: modifiers, timestamp: 0, windowNumber: panel.windowNumber,
                context: nil, characters: text, charactersIgnoringModifiers: text, isARepeat: false, keyCode: code))
            XCTAssertTrue(panel.performKeyEquivalent(with: event), "Shortcut was not handled: \(text)")
        }
        try key("2", 19, .command)
        try await Task.sleep(for: .milliseconds(150))
        try key(" ", 49)
        XCTAssertTrue(state.focusTimer.isRunning)
        try key(" ", 49)
        XCTAssertFalse(state.focusTimer.isRunning)
        try key("1", 18, .command)
        try key("\u{1b}", 53)
        try await Task.sleep(for: .milliseconds(350))
        XCTAssertFalse(state.isExpanded)
        XCTAssertFalse(panel.isKeyWindow)
        state.isExpanded = true
        try await Task.sleep(for: .milliseconds(400))
        NSWorkspace.shared.notificationCenter.post(name: NSWorkspace.didWakeNotification, object: nil)
        try await Task.sleep(for: .milliseconds(150))
        XCTAssertFalse(state.isExpanded)
        XCTAssertFalse(state.isPresentationExpanded)
        XCTAssertFalse(panel.isKeyWindow)
        XCTAssertTrue(panel.ignoresMouseEvents)
        withExtendedLifetime(controller) {}
    }

    private func makeState(defaults: UserDefaults) -> AppState {
        let calendar = CalendarManager(dataSource: CalendarSelectionTestDataSource(eventsByCalendarID: [:]), defaults: defaults)
        let assistant = MeetingAssistant(calendar: calendar, preferences: MeetingPreferences(defaults: defaults),
            notifications: QualityTestNotifications(), hotKey: QualityTestHotKey())
        return AppState(calendar: calendar, defaults: defaults,
            recoveryDirectory: FileManager.default.temporaryDirectory.appendingPathComponent("NotchQualityRecovery-\(UUID())"),
            meetingAssistant: assistant, reloadWidgetTimelines: { _ in })
    }
}

@MainActor private final class QualityTestNotifications: MeetingNotificationScheduling {
    func authorization() async -> MeetingNotificationAuthorization { .denied }
    func requestAuthorization() async throws -> Bool { false }
    func prepare(language: AppLanguage) {}
    func pending() async -> [String: String] { [:] }
    func delivered() async -> [MeetingDeliveredReminder] { [] }
    func removePending(_ identifiers: [String]) {}
    func removeDelivered(_ identifiers: [String]) {}
    func add(_ plan: MeetingReminderPlan, language: AppLanguage) async throws {}
}
@MainActor private final class QualityTestHotKey: MeetingHotKeyRegistering {
    func register(letter: String, modifiers: MeetingHotKeyModifiers, action: @escaping @MainActor () -> Void) -> Bool { true }
    func unregister() {}
}
