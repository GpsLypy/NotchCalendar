import AppKit
import XCTest
@testable import NotchCalendar

final class MeetingReminderTests: XCTestCase {
    private let now = Date(timeIntervalSince1970: 1_800_000_000)

    private func meeting(_ key: String = "one", start: TimeInterval = 900, end: TimeInterval = 2_700) -> MeetingOccurrence {
        MeetingOccurrence(key: key, title: key, start: now.addingTimeInterval(start), end: now.addingTimeInterval(end),
                          url: URL(string: "https://meet.google.com/abc-defg-hij")!)
    }

    func testFutureReminderUsesLeadTimeAndStableIdentifier() throws {
        let original = meeting()
        let plan = try XCTUnwrap(MeetingReminderEngine.plans(meetings: [original], now: now, leadMinutes: 5, overrides: [:]).first)
        XCTAssertEqual(plan.fireAt, now.addingTimeInterval(600))
        let moved = meeting(start: 1_800, end: 3_600)
        let changed = try XCTUnwrap(MeetingReminderEngine.plans(meetings: [moved], now: now, leadMinutes: 5, overrides: [:]).first)
        XCTAssertEqual(plan.identifier, changed.identifier)
        XCTAssertNotEqual(plan.fingerprint, changed.fingerprint)
        let changes = MeetingReminderEngine.reconciliation(pending: [plan.identifier: plan.fingerprint], desired: [changed])
        XCTAssertEqual(changes.remove, [plan.identifier])
        XCTAssertEqual(changes.add, [changed])
    }

    func testRefreshDoesNotReplaceUnchangedRequestsOrOtherFeaturesNotifications() throws {
        let plan = try XCTUnwrap(MeetingReminderEngine.plans(meetings: [meeting()], now: now, leadMinutes: 5, overrides: [:]).first)
        let changes = MeetingReminderEngine.reconciliation(pending: [plan.identifier: plan.fingerprint, "focus.timer": "other"], desired: [plan])
        XCTAssertTrue(changes.remove.isEmpty)
        XCTAssertTrue(changes.add.isEmpty)
    }

    func testWakeDoesNotReplayExpiredLeadOrSnoozedReminders() {
        let missed = meeting(start: 120, end: 1_800)
        let expired = MeetingReminderOverride(kind: .snoozed, fireAt: now.addingTimeInterval(-1), expiresAt: missed.end)
        XCTAssertTrue(MeetingReminderEngine.plans(meetings: [missed], now: now, leadMinutes: 5, overrides: [:]).isEmpty)
        XCTAssertTrue(MeetingReminderEngine.plans(meetings: [missed], now: now, leadMinutes: 5, overrides: [missed.key: expired]).isEmpty)
    }

    func testSnoozeIsBoundedByMeetingEndAndCanRepeat() throws {
        let active = meeting(start: -300, end: 900)
        let first = try XCTUnwrap(MeetingReminderEngine.snooze(meeting: active, minutes: 5, now: now))
        XCTAssertEqual(first.fireAt, now.addingTimeInterval(300))
        let second = try XCTUnwrap(MeetingReminderEngine.snooze(meeting: active, minutes: 5, now: now.addingTimeInterval(300)))
        XCTAssertEqual(second.fireAt, now.addingTimeInterval(600))
        XCTAssertNil(MeetingReminderEngine.snooze(meeting: active, minutes: 10, now: now.addingTimeInterval(300)))
        XCTAssertNil(MeetingReminderEngine.snooze(meeting: active, minutes: 3, now: now))
    }

    func testDismissAppliesToOneOccurrenceAndFollowsReschedule() {
        let ignored = MeetingReminderOverride(kind: .dismissed, fireAt: nil, expiresAt: now.addingTimeInterval(9_000))
        let plans = MeetingReminderEngine.plans(meetings: [meeting("series:today", start: 2_700), meeting("series:tomorrow", start: 4_000, end: 6_000)],
                                               now: now, leadMinutes: 5, overrides: ["series:today": ignored])
        XCTAssertEqual(plans.map(\.meeting.key), ["series:tomorrow"])
    }

    func testDismissedDuplicateSourceRemainsDismissedWhenPrimarySourceChanges() {
        let duplicate = MeetingOccurrence(key: "personal-copy", title: "Meeting", start: now.addingTimeInterval(900),
                                          end: now.addingTimeInterval(2_700), url: URL(string: "https://meet.google.com/abc-defg-hij")!,
                                          relatedKeys: ["work-copy"])
        let ignored = MeetingReminderOverride(kind: .dismissed, fireAt: nil, expiresAt: duplicate.end)
        XCTAssertTrue(MeetingReminderEngine.plans(meetings: [duplicate], now: now, leadMinutes: 5,
                                                 overrides: ["work-copy": ignored]).isEmpty)
    }

    func testBoundedScheduleDeduplicatesOccurrences() {
        var meetings: [MeetingOccurrence] = []
        for index in 0..<60 {
            let startOffset: TimeInterval = Double(600 + index * 600)
            let endOffset: TimeInterval = Double(1_800 + index * 600)
            meetings.append(meeting(String(index), start: startOffset, end: endOffset))
        }
        let plans = MeetingReminderEngine.plans(meetings: meetings + meetings, now: now, leadMinutes: 5, overrides: [:])
        XCTAssertEqual(plans.count, 32)
        XCTAssertEqual(Set(plans.map(\.identifier)).count, 32)
        XCTAssertEqual(plans.first?.meeting.key, "0")
        XCTAssertEqual(plans.last?.meeting.key, "31")
    }

    func testBeyondHorizonAndEndedMeetingsAreNotScheduled() {
        let plans = MeetingReminderEngine.plans(meetings: [meeting("tomorrow", start: 86_500, end: 90_000), meeting("ended", start: -2_000, end: -1)],
                                               now: now, leadMinutes: 5, overrides: [:])
        XCTAssertTrue(plans.isEmpty)
    }

    func testNearestJoinSelectsMostRecentlyStartedAndHonorsFifteenMinutes() {
        let old = meeting("old", start: -900)
        let recent = meeting("recent", start: -30)
        let later = meeting("future", start: 300)
        XCTAssertEqual(MeetingReminderEngine.nextToJoin(meetings: [later, old, recent], now: now)?.key, "recent")
        XCTAssertEqual(MeetingReminderEngine.nextToJoin(meetings: [meeting(start: 900)], now: now)?.key, "one")
        XCTAssertNil(MeetingReminderEngine.nextToJoin(meetings: [meeting(start: 901)], now: now))
    }

    func testIneligibleAndAllDayExcludedButFreeOnlineMeetingIncluded() {
        var event = CalendarEvent(id: "meeting", title: "Meeting", startDate: now, endDate: now.addingTimeInterval(900),
                                  calendarName: "Work", calendarColor: nil, location: nil,
                                  meetingLink: MeetingLink(url: URL(string: "https://meet.google.com/abc-defg-hij")!, provider: .googleMeet),
                                  isAllDay: false, blocksTime: false)
        XCTAssertNotNil(MeetingOccurrence(event: event))
        event.isEligibleForMeeting = false
        XCTAssertNil(MeetingOccurrence(event: event))
    }
}

@MainActor
final class MeetingAssistantTests: XCTestCase {
    private func fixture() throws -> Fixture { try Fixture() }

    func testPassiveRefreshDoesNotRequestPermissionAndExplicitEnableDoes() async throws {
        let f = try fixture()
        defer { f.cleanUp() }
        f.notifications.permission = .notDetermined
        await f.assistant.refreshNow()
        XCTAssertEqual(f.notifications.permissionRequests, 0)
        XCTAssertTrue(f.notifications.requests.isEmpty)
        await f.assistant.setRemindersEnabled(true)
        XCTAssertEqual(f.notifications.permissionRequests, 1)
        XCTAssertEqual(f.notifications.requests.count, 1)
        XCTAssertTrue(f.openedURLs.isEmpty)
    }

    func testStableReconciliationAndHiddenCalendarCancelsPending() async throws {
        let f = try fixture()
        defer { f.cleanUp() }
        await f.assistant.setRemindersEnabled(true)
        await f.assistant.refreshNow()
        XCTAssertEqual(f.notifications.addCount, 1)
        f.calendar.setCalendarSelected("work", isSelected: false)
        await f.assistant.refreshNow()
        XCTAssertTrue(f.notifications.requests.isEmpty)
        XCTAssertNil(f.assistant.nextMeeting)
    }

    func testRevokedCalendarAndNotificationPermissionRemoveReminders() async throws {
        let f = try fixture()
        defer { f.cleanUp() }
        await f.assistant.setRemindersEnabled(true)
        f.notifications.permission = .denied
        await f.assistant.refreshNow()
        XCTAssertTrue(f.notifications.requests.isEmpty)
        XCTAssertNotNil(f.assistant.reminderMessageKey)
        f.notifications.permission = .allowed
        await f.assistant.refreshNow()
        XCTAssertEqual(f.notifications.requests.count, 1)
        f.source.authorizationStatus = .denied
        f.calendar.refresh()
        await f.assistant.refreshNow()
        XCTAssertTrue(f.notifications.requests.isEmpty)
    }

    func testDisablingRemindersCancelsOnlyMeetingNotifications() async throws {
        let f = try fixture()
        defer { f.cleanUp() }
        await f.assistant.setRemindersEnabled(true)
        f.notifications.otherRequests["another.feature"] = "keep"
        await f.assistant.setRemindersEnabled(false)
        XCTAssertTrue(f.notifications.requests.isEmpty)
        XCTAssertEqual(f.notifications.otherRequests["another.feature"], "keep")
    }

    func testJoinRequeriesAndOpeningFailureIsReported() async throws {
        let f = try fixture()
        defer { f.cleanUp() }
        let joined = try await f.assistant.joinNextMeeting()
        XCTAssertEqual(joined.title, "Planning")
        XCTAssertEqual(f.openedURLs.count, 1)
        f.openSucceeds = false
        do { _ = try await f.assistant.joinNextMeeting(); XCTFail("Expected a failed opening") }
        catch let error as MeetingJoinError { XCTAssertEqual(error.messageKey, MeetingJoinError.openingFailed.messageKey) }
        f.calendar.setCalendarSelected("work", isSelected: false)
        do { _ = try await f.assistant.joinNextMeeting(); XCTFail("Hidden calendars must not join") }
        catch let error as MeetingJoinError { XCTAssertEqual(error.messageKey, MeetingJoinError.noMeeting.messageKey) }
    }

    func testDeletedOccurrenceDoesNotLeavePendingNotification() async throws {
        let f = try fixture()
        defer { f.cleanUp() }
        await f.assistant.setRemindersEnabled(true)
        f.source.eventsByCalendarID = [:]
        f.calendar.refresh()
        await f.assistant.refreshNow()
        XCTAssertTrue(f.notifications.requests.isEmpty)
    }

    func testSnoozeSurvivesRestartAndExpiredDeadlineDoesNotReplay() async throws {
        let f = try fixture()
        defer { f.cleanUp() }
        await f.assistant.setRemindersEnabled(true)
        let meeting = try XCTUnwrap(f.assistant.nextMeeting)
        await f.assistant.snooze(meeting, minutes: 5)
        XCTAssertEqual(f.notifications.requests.values.first?.fireAt, f.date.addingTimeInterval(300))
        let restored = MeetingPreferences(defaults: f.defaults)
        XCTAssertEqual(restored.overrides[meeting.key]?.kind, .snoozed)
        f.date = f.date.addingTimeInterval(301)
        await f.assistant.refreshNow()
        XCTAssertTrue(f.notifications.requests.isEmpty)
    }

    func testSleepCancelsQueueAndWakeDoesNotCatchUpMissedReminders() async throws {
        let f = try fixture()
        defer { f.cleanUp() }
        await f.assistant.setRemindersEnabled(true)
        XCTAssertEqual(f.notifications.requests.count, 1)
        f.assistant.prepareForSleep()
        XCTAssertTrue(f.notifications.requests.isEmpty)
        f.date = f.date.addingTimeInterval(700)
        f.assistant.resumeAfterSleep()
        await f.assistant.refreshNow()
        XCTAssertTrue(f.notifications.requests.isEmpty)
        XCTAssertEqual(f.notifications.addCount, 1)
    }

    func testShortcutConflictIsVisibleAndStopUnregisters() throws {
        let f = try fixture()
        defer { f.cleanUp() }
        f.preferences.hotKeyEnabled = true
        f.hotKey.succeeds = false
        f.assistant.start()
        XCTAssertNotNil(f.assistant.shortcutMessageKey)
        XCTAssertEqual(f.hotKey.registrationCount, 1)
        f.assistant.stop()
        XCTAssertGreaterThan(f.hotKey.unregisterCount, 0)
        XCTAssertEqual(f.notifications.permissionRequests, 0)
    }

    @MainActor
    private final class Fixture {
        let suite = "MeetingAssistantTests.\(UUID().uuidString)"
        let defaults: UserDefaults
        let source: CalendarSelectionTestDataSource
        let calendar: CalendarManager
        let preferences: MeetingPreferences
        let notifications = TestMeetingNotifications()
        let hotKey = TestMeetingHotKey()
        var date = Date(timeIntervalSince1970: 1_800_000_000)
        var openedURLs: [URL] = []
        var openSucceeds = true
        lazy var assistant = MeetingAssistant(calendar: calendar, preferences: preferences, notifications: notifications,
                                              hotKey: hotKey, now: { [unowned self] in date },
                                              openURL: { [unowned self] url in openedURLs.append(url); return openSucceeds },
                                              showError: { _ in })
        init() throws {
            defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
            let event = CalendarEvent(id: "meeting", title: "Planning", startDate: date.addingTimeInterval(900),
                                      endDate: date.addingTimeInterval(2_700), calendarName: "Work", calendarColor: nil,
                                      location: nil, meetingLink: MeetingLink(url: URL(string: "https://meet.google.com/abc-defg-hij")!, provider: .googleMeet), isAllDay: false)
            source = CalendarSelectionTestDataSource(eventsByCalendarID: ["work": [event]])
            calendar = CalendarManager(dataSource: source, defaults: defaults)
            preferences = MeetingPreferences(defaults: defaults)
        }
        func cleanUp() { assistant.stop(); defaults.removePersistentDomain(forName: suite) }
    }
}

@MainActor
private final class TestMeetingNotifications: MeetingNotificationScheduling {
    var permission: MeetingNotificationAuthorization = .allowed
    var permissionRequests = 0
    var requests: [String: MeetingReminderPlan] = [:]
    var otherRequests: [String: String] = [:]
    var addCount = 0
    func authorization() async -> MeetingNotificationAuthorization { permission }
    func requestAuthorization() async throws -> Bool { permissionRequests += 1; permission = .allowed; return true }
    func prepare(language: AppLanguage) {}
    func pending() async -> [String: String] { requests.mapValues(\.fingerprint).merging(otherRequests) { _, new in new } }
    func delivered() async -> [MeetingDeliveredReminder] { [] }
    func removePending(_ identifiers: [String]) { for id in identifiers { requests[id] = nil; otherRequests[id] = nil } }
    func removeDelivered(_ identifiers: [String]) {}
    func add(_ plan: MeetingReminderPlan, language: AppLanguage) async throws { requests[plan.identifier] = plan; addCount += 1 }
}

@MainActor
private final class TestMeetingHotKey: MeetingHotKeyRegistering {
    var succeeds = true
    var registrationCount = 0
    var unregisterCount = 0
    func register(letter: String, modifiers: MeetingHotKeyModifiers, action: @escaping @MainActor () -> Void) -> Bool {
        registrationCount += 1; return succeeds
    }
    func unregister() { unregisterCount += 1 }
}
