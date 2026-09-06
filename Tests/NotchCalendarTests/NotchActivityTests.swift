import XCTest
@testable import NotchCalendar

@MainActor final class NotchActivityTests: XCTestCase {
    func testCompactPriorityAcrossAllPreferenceAndActivityCombinations() {
        for meetings in [false, true] {
            for active in [false, true] {
                for focus in [false, true] {
                    for session in [false, true] {
                        let expected: NotchActivity = meetings && active ? .calendar : focus && session ? .focus : .calendar
                        XCTAssertEqual(NotchActivityPolicy.compactActivity(showsMeetings: meetings, meetingIsActive: active, showsFocus: focus, hasFocusSession: session), expected)
                        XCTAssertEqual(NotchActivityPolicy.showsShoulders(showsMeetings: meetings, meetingIsActive: active, showsFocus: focus, hasFocusSession: session), (meetings && active) || (focus && session))
                    }
                }
            }
        }
    }

    @MainActor
    func testPausedAndRestoredTimerKeepsActivityUntilCompletion() throws {
        let suite = "NotchActivity.\(UUID())"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let now = Date()
        let timer = FocusTimerModel(defaults: defaults, now: now)
        XCTAssertFalse(timer.hasUnfinishedSession)
        timer.toggle(now: now)
        timer.toggle(now: now)
        XCTAssertTrue(timer.hasUnfinishedSession)
        let restored = FocusTimerModel(defaults: defaults, now: now)
        XCTAssertTrue(restored.hasUnfinishedSession)
        XCTAssertFalse(restored.isRunning)
        restored.toggle(now: now)
        restored.synchronize(now: now.addingTimeInterval(1_500))
        XCTAssertFalse(restored.hasUnfinishedSession)
        XCTAssertEqual(restored.history.count, 1)
        restored.synchronize(now: now.addingTimeInterval(2_000))
        XCTAssertEqual(restored.history.count, 1)
    }

    @MainActor
    func testFocusVisibilityPreferencePersistsAndReloads() throws {
        let suite = "NotchPreference.\(UUID())"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let preferences = PresentationPreferences(defaults: defaults)
        XCTAssertTrue(preferences.showsFocusStatus)
        preferences.showsFocusStatus = false
        XCTAssertFalse(PresentationPreferences(defaults: defaults).showsFocusStatus)
        defaults.set(true, forKey: PresentationPreferences.focusStatusKey)
        preferences.reload()
        XCTAssertTrue(preferences.showsFocusStatus)
    }

    func testUpcomingSelectionIgnoresCancelledInvalidAndUnsortedEvents() {
        let now = Date()
        func event(_ id: String, _ offset: Double) -> CalendarEvent {
            CalendarSelectionTestDataSource.event(id: id, start: now.addingTimeInterval(offset), end: now.addingTimeInterval(offset + 600))
        }
        var cancelled = event("cancelled", -10); cancelled.isEligibleForMeeting = false
        let future = event("next", 20)
        switch UpcomingEventEngine.status(now: now, events: [event("later", 40), cancelled, future]) {
        case .upcoming(let selected, _): XCTAssertEqual(selected.id, "next")
        default: XCTFail("Cancelled events must not become live activities")
        }
    }
}
