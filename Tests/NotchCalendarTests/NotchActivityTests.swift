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
    func testPausedTimerKeepsActivityButRestoredTimerWaitsForExplicitResume() throws {
        let suite = "NotchActivity.\(UUID())"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let now = Date()
        let timer = FocusTimerModel(defaults: defaults, now: now)
        XCTAssertFalse(timer.hasUnfinishedSession)
        XCTAssertFalse(timer.hasNotchActivity)
        timer.toggle(now: now)
        timer.toggle(now: now)
        XCTAssertTrue(timer.hasUnfinishedSession)
        XCTAssertTrue(timer.hasNotchActivity)
        let restored = FocusTimerModel(defaults: defaults, now: now)
        XCTAssertTrue(restored.hasUnfinishedSession)
        XCTAssertFalse(restored.hasNotchActivity)
        XCTAssertFalse(restored.isRunning)
        restored.toggle(now: now)
        XCTAssertTrue(restored.hasNotchActivity)
        restored.synchronize(now: now.addingTimeInterval(1_500))
        XCTAssertFalse(restored.hasUnfinishedSession)
        XCTAssertFalse(restored.hasNotchActivity)
        XCTAssertEqual(restored.history.count, 1)
        restored.synchronize(now: now.addingTimeInterval(2_000))
        XCTAssertEqual(restored.history.count, 1)
    }

    func testColdLaunchWithPausedFiftyMinuteTimerKeepsCompactCalendarAndSavedWork() throws {
        let suite = "NotchPausedLaunch.\(UUID())"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let now = Date(timeIntervalSinceReferenceDate: 10_000)
        let previousLaunch = FocusTimerModel(defaults: defaults, now: now)
        previousLaunch.select(minutes: 50)
        previousLaunch.setTaskLabel("Finish the proposal")
        previousLaunch.toggle(now: now)
        previousLaunch.toggle(now: now.addingTimeInterval(40))

        let restored = FocusTimerModel(defaults: defaults, now: now.addingTimeInterval(100))
        XCTAssertEqual(restored.timeLabel, "49:20")
        XCTAssertEqual(restored.selectedMinutes, 50)
        XCTAssertEqual(restored.taskLabel, "Finish the proposal")
        XCTAssertTrue(restored.hasUnfinishedSession)
        XCTAssertFalse(restored.isRunning)
        XCTAssertFalse(restored.hasNotchActivity)
        XCTAssertEqual(compactActivity(for: restored), .calendar)
        XCTAssertFalse(NotchActivityPolicy.showsShoulders(
            showsMeetings: false, meetingIsActive: false,
            showsFocus: true, hasFocusSession: restored.hasNotchActivity
        ))
        XCTAssertFalse(restored.prepareFocus(minutes: 25), "The saved session must remain protected")

        restored.toggle(now: now.addingTimeInterval(100))
        XCTAssertEqual(compactActivity(for: restored), .focus)
        XCTAssertEqual(restored.remainingSeconds, 2_960)
        restored.toggle(now: now.addingTimeInterval(120))
        XCTAssertEqual(compactActivity(for: restored), .focus, "Pausing this launch's activity must keep it recoverable in the notch")
        XCTAssertEqual(restored.remainingSeconds, 2_940)
        restored.reset()
        XCTAssertEqual(compactActivity(for: restored), .calendar)
        XCTAssertFalse(restored.hasNotchActivity)
    }

    func testRestoredRunningTimerCompletesInBackgroundWithoutClaimingNotch() throws {
        let suite = "NotchRunningLaunch.\(UUID())"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let now = Date(timeIntervalSinceReferenceDate: 20_000)
        let previousLaunch = FocusTimerModel(defaults: defaults, now: now)
        previousLaunch.toggle(now: now)

        let restored = FocusTimerModel(defaults: defaults, now: now.addingTimeInterval(40))
        XCTAssertTrue(restored.isRunning)
        XCTAssertEqual(restored.remainingSeconds, 1_460)
        XCTAssertEqual(compactActivity(for: restored), .calendar)
        restored.synchronize(now: now.addingTimeInterval(1_500))
        XCTAssertFalse(restored.hasNotchActivity)
        XCTAssertEqual(restored.history.count, 1)
        XCTAssertEqual(restored.history.first?.completedAt, now.addingTimeInterval(1_500))
        let secondRestore = FocusTimerModel(defaults: defaults, now: now.addingTimeInterval(1_600))
        XCTAssertEqual(secondRestore.history, restored.history)
        XCTAssertEqual(secondRestore.completedSessions, 1)
    }

    func testExplicitResumeAfterRunningRestoreHonorsMeetingPriority() throws {
        let suite = "NotchResumeLaunch.\(UUID())"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let now = Date(timeIntervalSinceReferenceDate: 30_000)
        let previousLaunch = FocusTimerModel(defaults: defaults, now: now)
        previousLaunch.toggle(now: now)
        let restored = FocusTimerModel(defaults: defaults, now: now.addingTimeInterval(40))
        restored.toggle(now: now.addingTimeInterval(40))
        XCTAssertEqual(compactActivity(for: restored), .calendar)
        restored.toggle(now: now.addingTimeInterval(60))
        XCTAssertEqual(compactActivity(for: restored), .focus)
        XCTAssertEqual(NotchActivityPolicy.compactActivity(
            showsMeetings: true, meetingIsActive: true,
            showsFocus: true, hasFocusSession: restored.hasNotchActivity
        ), .calendar)
        XCTAssertEqual(NotchActivityPolicy.compactActivity(
            showsMeetings: true, meetingIsActive: false,
            showsFocus: true, hasFocusSession: restored.hasNotchActivity
        ), .focus)
        XCTAssertEqual(NotchActivityPolicy.compactActivity(
            showsMeetings: false, meetingIsActive: false,
            showsFocus: false, hasFocusSession: restored.hasNotchActivity
        ), .calendar)
        restored.reload(now: now.addingTimeInterval(80))
        XCTAssertTrue(restored.isRunning)
        XCTAssertFalse(restored.hasNotchActivity, "Backup restoration must also restore data without claiming the notch")
    }

    private func compactActivity(for timer: FocusTimerModel) -> NotchActivity {
        NotchActivityPolicy.compactActivity(showsMeetings: false, meetingIsActive: false,
            showsFocus: true, hasFocusSession: timer.hasNotchActivity)
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
