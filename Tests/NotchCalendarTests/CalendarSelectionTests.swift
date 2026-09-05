import AppKit
import EventKit
import XCTest
@testable import NotchCalendar

final class CalendarSelectionTests: XCTestCase {
    func testNewCalendarIsIncludedWhileHiddenCalendarKeepsItsChoice() {
        var selection = CalendarSelectionPolicy()
        selection.setSelected("work", isSelected: false)
        XCTAssertEqual(selection.selectedIDs(availableCalendarIDs: ["work", "personal", "new"]), ["personal", "new"])
        XCTAssertEqual(selection.selectedIDs(availableCalendarIDs: ["personal"]), ["personal"])
        XCTAssertEqual(selection.selectedIDs(availableCalendarIDs: ["work", "personal"]), ["personal"])
    }

    func testEmptySelectionProducesNoQueryAndShowAllRestoresIt() {
        var selection = CalendarSelectionPolicy(excludedCalendarIDs: ["work", "personal"])
        XCTAssertNil(selection.queryCalendarIDs(hasAccess: true, availableCalendarIDs: ["work", "personal"]))
        XCTAssertEqual(selection.availability(hasAccess: true, availableCalendarIDs: ["work", "personal"]), .noneSelected)
        selection.selectAll()
        XCTAssertEqual(selection.queryCalendarIDs(hasAccess: true, availableCalendarIDs: ["work", "personal"]), ["work", "personal"])
    }

    func testMissingPermissionAndMissingCalendarsRemainDistinct() {
        let selection = CalendarSelectionPolicy()
        XCTAssertEqual(selection.availability(hasAccess: false, availableCalendarIDs: []), .needsPermission)
        XCTAssertEqual(selection.availability(hasAccess: true, availableCalendarIDs: []), .noCalendars)
        XCTAssertNil(selection.queryCalendarIDs(hasAccess: false, availableCalendarIDs: ["work"]))
        XCTAssertNil(selection.queryCalendarIDs(hasAccess: true, availableCalendarIDs: []))
    }

    func testExclusionsPersistAcrossInstances() throws {
        let suite = "CalendarSelectionTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        var selection = CalendarSelectionPolicy()
        selection.setSelected("work", isSelected: false)
        selection.save(to: defaults)
        XCTAssertFalse(CalendarSelectionPolicy(defaults: defaults).isSelected("work"))
        XCTAssertTrue(CalendarSelectionPolicy(defaults: defaults).isSelected("new"))
    }

    @MainActor
    func testEveryQueryUsesSelectionAndAllHiddenDoesNotQueryProvider() throws {
        let suite = "CalendarManagerTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let now = Date()
        let work = CalendarSelectionTestDataSource.event(id: "work-event", start: now, end: now.addingTimeInterval(1_800))
        let personal = CalendarSelectionTestDataSource.event(id: "personal-event", start: now, end: now.addingTimeInterval(1_800))
        let source = CalendarSelectionTestDataSource(eventsByCalendarID: ["work": [work], "personal": [personal]])
        let manager = CalendarManager(dataSource: source, defaults: defaults)
        manager.setCalendarSelected("work", isSelected: false)
        XCTAssertEqual(manager.todayEvents.map(\.id), ["personal-event"])
        XCTAssertEqual(manager.planningEvents.map(\.id), ["personal-event"])
        XCTAssertEqual(manager.events(for: now).map(\.id), ["personal-event"])
        XCTAssertEqual(manager.events(inMonthContaining: now).map(\.id), ["personal-event"])
        XCTAssertEqual(source.queries.last?.calendarIDs, ["personal"])
        let queryCount = source.queries.count
        manager.setCalendarSelected("personal", isSelected: false)
        XCTAssertTrue(manager.todayEvents.isEmpty)
        XCTAssertTrue(manager.planningEvents.isEmpty)
        XCTAssertTrue(manager.events(for: now).isEmpty)
        XCTAssertTrue(manager.events(inMonthContaining: now).isEmpty)
        XCTAssertEqual(source.queries.count, queryCount)
        XCTAssertEqual(manager.sourceAvailability, .noneSelected)
        manager.selectAllCalendars()
        XCTAssertEqual(manager.selectedCalendarCount, 2)
        XCTAssertEqual(Set(manager.todayEvents.map(\.id)), ["work-event", "personal-event"])
        XCTAssertEqual(source.accessRequestCount, 0)
    }

    @MainActor
    func testPlanningQueryIncludesAdjacentDayBuffersWithoutAddingThemToToday() throws {
        let suite = "CalendarPlanningBufferTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let now = Date()
        let dayStart = Calendar.current.startOfDay(for: now)
        let nextDay = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: 1, to: dayStart))
        let before = CalendarSelectionTestDataSource.event(id: "previous", start: dayStart.addingTimeInterval(-1_200), end: dayStart.addingTimeInterval(-600))
        let after = CalendarSelectionTestDataSource.event(id: "next", start: nextDay.addingTimeInterval(600), end: nextDay.addingTimeInterval(1_200))
        let today = CalendarSelectionTestDataSource.event(id: "today", start: dayStart.addingTimeInterval(3_600), end: dayStart.addingTimeInterval(5_400))
        let source = CalendarSelectionTestDataSource(eventsByCalendarID: ["work": [before, today, after]])
        let manager = CalendarManager(dataSource: source, defaults: defaults)
        manager.refresh(now: now)
        XCTAssertEqual(manager.todayEvents.map(\.id), ["today"])
        XCTAssertEqual(manager.planningEvents.map(\.id), ["previous", "today", "next"])
        XCTAssertEqual(source.queries.last?.start, dayStart.addingTimeInterval(-1_800))
        XCTAssertEqual(source.queries.last?.end, nextDay.addingTimeInterval(1_800))
    }

    @MainActor
    func testSourceChangesAndPermissionRevocationRefreshState() throws {
        let suite = "CalendarSourceRefreshTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let source = CalendarSelectionTestDataSource(eventsByCalendarID: ["work": []])
        let manager = CalendarManager(dataSource: source, defaults: defaults)
        manager.setCalendarSelected("work", isSelected: false)
        source.calendars.append(CalendarSource(id: "new", title: "Work", sourceTitle: "Other account"))
        manager.refresh()
        XCTAssertEqual(manager.sourceAvailability, .available)
        XCTAssertEqual(manager.selectedCalendarCount, 1)
        XCTAssertTrue(manager.isCalendarSelected("new"))
        let previousRevision = manager.contentRevision
        manager.refresh()
        XCTAssertGreaterThan(manager.contentRevision, previousRevision, "Changes outside today must still invalidate month and widget snapshots")
        source.authorizationStatus = .denied
        manager.refresh()
        XCTAssertEqual(manager.sourceAvailability, .needsPermission)
        XCTAssertTrue(manager.availableCalendars.isEmpty)
        XCTAssertTrue(manager.todayEvents.isEmpty)
        XCTAssertTrue(manager.planningEvents.isEmpty)
        XCTAssertNotNil(manager.authorizationMessage)
    }

    func testFreeCanceledAndDeclinedEventsDoNotBlockTime() {
        XCTAssertFalse(CalendarEventAvailabilityPolicy.blocksTime(availability: .free, status: .confirmed, currentUserParticipationStatus: .accepted))
        XCTAssertFalse(CalendarEventAvailabilityPolicy.blocksTime(availability: .busy, status: .canceled, currentUserParticipationStatus: .accepted))
        XCTAssertFalse(CalendarEventAvailabilityPolicy.blocksTime(availability: .busy, status: .confirmed, currentUserParticipationStatus: .declined))
        XCTAssertTrue(CalendarEventAvailabilityPolicy.blocksTime(availability: .notSupported, status: .none, currentUserParticipationStatus: nil))
        XCTAssertTrue(CalendarEventAvailabilityPolicy.blocksTime(availability: .tentative, status: .tentative, currentUserParticipationStatus: .tentative))
    }
}

/// Shared offline fixture for source-selection tests and native view captures.
/// Constructing it never creates an EKEventStore or requests macOS permissions.
@MainActor
final class CalendarSelectionTestDataSource: CalendarDataSource {
    struct Query {
        let start: Date
        let end: Date
        let calendarIDs: Set<String>
    }
    var authorizationStatus: EKAuthorizationStatus = .fullAccess
    var changeNotificationObject: AnyObject? { self }
    var calendars: [CalendarSource]
    var eventsByCalendarID: [String: [CalendarEvent]]
    private(set) var queries: [Query] = []
    private(set) var accessRequestCount = 0

    init(eventsByCalendarID: [String: [CalendarEvent]], calendars: [CalendarSource]? = nil) {
        self.eventsByCalendarID = eventsByCalendarID
        self.calendars = calendars ?? eventsByCalendarID.keys.sorted().map {
            CalendarSource(id: $0, title: $0.capitalized, sourceTitle: "Test account")
        }
    }

    func availableCalendars() -> [CalendarSource] { calendars }
    func events(from start: Date, to end: Date, calendarIDs: Set<String>) -> [CalendarEvent] {
        queries.append(Query(start: start, end: end, calendarIDs: calendarIDs))
        return calendarIDs.flatMap { eventsByCalendarID[$0] ?? [] }.filter {
            $0.startDate < end && $0.endDate > start
        }
    }
    func requestAccess(completion: @escaping @Sendable (Bool, Error?) -> Void) {
        accessRequestCount += 1
        completion(authorizationStatus == .fullAccess, nil)
    }
    static func event(id: String, start: Date, end: Date) -> CalendarEvent {
        CalendarEvent(id: id, title: id, startDate: start, endDate: end,
                      calendarName: "Work", calendarColor: .systemBlue,
                      location: nil, meetingLink: nil, isAllDay: false)
    }
}
