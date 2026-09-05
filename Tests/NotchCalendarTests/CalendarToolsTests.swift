import AppKit
import EventKit
import XCTest
@testable import NotchCalendar

final class CalendarToolsTests: XCTestCase {
    func testDedupCombinesOnlyExactCrossSourceCopiesAndRetainsAliases() {
        let first = event(id: "work-event", calendarID: "a", title: "Planning")
        let copy = event(id: "personal-event", calendarID: "b", title: "Planning")
        let merged = CalendarDuplicatePolicy.events([copy, first], enabled: true)
        XCTAssertEqual(merged.count, 1)
        XCTAssertEqual(merged[0].displayedSourceNames, ["Calendar a", "Calendar b"])
        XCTAssertEqual(Set(merged[0].allOccurrenceStableIDs), [first.occurrenceStableID, copy.occurrenceStableID])
        XCTAssertEqual(CalendarDuplicatePolicy.events([first, copy], enabled: false).count, 2)
        XCTAssertEqual(CalendarDuplicatePolicy.events([first, first], enabled: true).count, 2, "Do not merge distinct source records from the same calendar")
    }

    func testDedupPreservesDifferencesThatCouldRepresentDifferentMeetings() {
        let first = event(id: "first", calendarID: "a", title: "Planning")
        var variants: [CalendarEvent] = []
        var url = event(id: "url", calendarID: "b", title: "Planning")
        url = withLink(url, url: URL(string: "https://meet.google.com/abc-defg-hij")!)
        variants.append(url)
        variants.append(event(id: "location", calendarID: "b", title: "Planning", location: "Another room"))
        variants.append(event(id: "case", calendarID: "b", title: "planning"))
        variants.append(event(id: "time", calendarID: "b", title: "Planning", offset: 60))
        var eligibility = event(id: "declined", calendarID: "b", title: "Planning")
        eligibility.isEligibleForMeeting = false
        variants.append(eligibility)
        for variant in variants {
            XCTAssertEqual(CalendarDuplicatePolicy.events([first, variant], enabled: true).count, 2, variant.id)
        }
        var unknown = event(id: "unknown", calendarID: "", title: "Planning")
        unknown.calendarID = ""
        XCTAssertEqual(CalendarDuplicatePolicy.events([first, unknown], enabled: true).count, 2)
    }

    func testRecurrenceIdentitySurvivesMovedOccurrenceButSeparatesDates() {
        var first = event(id: "series-instance", calendarID: "a", title: "Weekly")
        first.seriesIdentifier = "series"
        first.isRecurring = true
        first.originalOccurrenceDate = first.startDate
        var moved = event(id: "changed-provider-id", calendarID: "a", title: "Weekly", offset: 3_600)
        moved.seriesIdentifier = "series"
        moved.isRecurring = true
        moved.originalOccurrenceDate = first.startDate
        XCTAssertEqual(first.occurrenceStableID, moved.occurrenceStableID)
        moved.originalOccurrenceDate = first.startDate.addingTimeInterval(7 * 86_400)
        XCTAssertNotEqual(first.occurrenceStableID, moved.occurrenceStableID)
        XCTAssertEqual(CalendarDuplicatePolicy.events([first, moved], enabled: true).count, 2)
    }

    func testAllDayOccurrenceIdentitySurvivesSystemTimeZoneChangesAndKeepsDatesSeparate() throws {
        let shanghai = try XCTUnwrap(TimeZone(identifier: "Asia/Shanghai"))
        let newYork = try XCTUnwrap(TimeZone(identifier: "America/New_York"))
        func snapshot(day: Int, zone: TimeZone) throws -> CalendarEvent {
            var localCalendar = Calendar(identifier: .gregorian)
            localCalendar.timeZone = zone
            let original = try XCTUnwrap(localCalendar.date(from: DateComponents(year: 2026, month: 9, day: day)))
            let end = try XCTUnwrap(localCalendar.date(byAdding: .day, value: 1, to: original))
            return CalendarEvent(id: "server-instance", title: "Annual leave", startDate: original, endDate: end,
                                 calendarName: "Work", calendarColor: nil, location: nil, meetingLink: nil,
                                 isAllDay: true, calendarID: "work", originalOccurrenceDate: original,
                                 originalOccurrenceDay: CalendarEvent.occurrenceDay(for: original, timeZone: zone),
                                 seriesIdentifier: "server-series", isRecurring: true)
        }
        let beforeTravel = try snapshot(day: 5, zone: shanghai)
        let afterTravel = try snapshot(day: 5, zone: newYork)
        XCTAssertNotEqual(beforeTravel.originalOccurrenceDate, afterTravel.originalOccurrenceDate,
                          "EventKit represents the same all-day occurrence as local midnight in each zone")
        XCTAssertEqual(beforeTravel.originalOccurrenceDay, "2026-09-05")
        XCTAssertEqual(beforeTravel.occurrenceStableID, afterTravel.occurrenceStableID)
        XCTAssertNotEqual(beforeTravel.occurrenceStableID, try snapshot(day: 6, zone: newYork).occurrenceStableID)
        // The captured identity cannot be recomputed from startDate after this
        // occurrence moves or a retained snapshot outlives a timezone change.
        var moved = try snapshot(day: 7, zone: newYork)
        moved.originalOccurrenceDate = afterTravel.originalOccurrenceDate
        moved.originalOccurrenceDay = afterTravel.originalOccurrenceDay
        XCTAssertEqual(beforeTravel.occurrenceStableID, moved.occurrenceStableID)
    }

    func testSearchMatchesAllWordsAcrossFieldsAndReportsLimit() {
        let first = event(id: "one", calendarID: "a", title: "Café design", location: "Room 12")
        let second = event(id: "two", calendarID: "b", title: "Design review", location: "Room 12")
        XCTAssertEqual(CalendarSearchEngine.search([first, second], query: "cafe room").events.map(\.id), ["one"])
        XCTAssertEqual(CalendarSearchEngine.search([first, second], query: "Calendar b").events.map(\.id), ["two"])
        let result = CalendarSearchEngine.search([first, second], query: "design", limit: 1)
        XCTAssertEqual(result.totalCount, 2)
        XCTAssertTrue(result.isTruncated)
        XCTAssertEqual(result.events.count, 1)
        XCTAssertTrue(CalendarSearchEngine.search([first], query: "unmatched").events.isEmpty)
    }

    func testSearchRangeCountsCalendarDaysAcrossDST() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try XCTUnwrap(TimeZone(identifier: "America/New_York"))
        let day = iso("2026-03-08T12:00:00Z")
        let interval = try XCTUnwrap(CalendarSearchEngine.interval(from: day, through: day, calendar: calendar))
        XCTAssertEqual(interval.duration, 23 * 3_600)
        let maximum = try XCTUnwrap(calendar.date(byAdding: .day, value: 365, to: day))
        XCTAssertNotNil(CalendarSearchEngine.interval(from: day, through: maximum, calendar: calendar))
        let tooLong = try XCTUnwrap(calendar.date(byAdding: .day, value: 366, to: day))
        XCTAssertNil(CalendarSearchEngine.interval(from: day, through: tooLong, calendar: calendar))
        XCTAssertNil(CalendarSearchEngine.interval(from: maximum, through: day, calendar: calendar))
    }

    func testAllDayDraftConvertsInclusiveEndUsingDSTCalendarArithmetic() throws {
        var draft = CalendarEventDraft(startDate: iso("2026-03-08T12:00:00Z"), calendarID: "work")
        draft.title = "A day away"
        draft.timeZoneIdentifier = "America/New_York"
        draft.isAllDay = true
        draft.endDate = draft.startDate
        let interval = try draft.datesForSaving()
        XCTAssertEqual(interval.start, iso("2026-03-08T05:00:00Z"))
        XCTAssertEqual(interval.end, iso("2026-03-09T04:00:00Z"))
        XCTAssertEqual(interval.duration, 23 * 3_600)
        XCTAssertNoThrow(try draft.validate(writableCalendarIDs: ["work"]))
        draft.startDate = iso("2026-11-01T12:00:00Z")
        draft.endDate = draft.startDate
        XCTAssertEqual(try draft.datesForSaving().duration, 25 * 3_600)
    }

    func testDraftValidationRejectsReadOnlyBadLinkAndInvalidRecurrenceWithoutMutation() {
        var draft = CalendarEventDraft(calendarID: "work")
        XCTAssertThrowsError(try draft.validate(writableCalendarIDs: ["work"])) { XCTAssertEqual($0 as? CalendarDraftError, .missingTitle) }
        draft.title = "Review"
        XCTAssertThrowsError(try draft.validate(writableCalendarIDs: [])) { XCTAssertEqual($0 as? CalendarDraftError, .calendarUnavailable) }
        draft.link = "file:///tmp/unsafe"
        XCTAssertThrowsError(try draft.validate(writableCalendarIDs: ["work"])) { XCTAssertEqual($0 as? CalendarDraftError, .invalidLink) }
        draft.link = "https://meet.google.com/abc-defg-hij"
        draft.repeatRule = .weekly
        draft.repeatThrough = draft.startDate.addingTimeInterval(-86_400)
        XCTAssertThrowsError(try draft.validate(writableCalendarIDs: ["work"])) { XCTAssertEqual($0 as? CalendarDraftError, .invalidRepeatEnd) }
        XCTAssertEqual(draft.title, "Review")
        draft.repeatThrough = draft.startDate
        XCTAssertNoThrow(try draft.validate(writableCalendarIDs: ["work"]))
    }

    func testTimeZoneOffsetFollowsEventDateAndCrossesDayBoundary() {
        let before = iso("2026-03-08T06:30:00Z")
        let after = iso("2026-03-08T07:30:00Z")
        XCTAssertTrue(CalendarTimeZoneTools.label("America/New_York", at: before, locale: Locale(identifier: "en_US")).contains("−05:00"))
        XCTAssertTrue(CalendarTimeZoneTools.label("America/New_York", at: after, locale: Locale(identifier: "en_US")).contains("−04:00"))
        let shanghai = CalendarTimeZoneTools.time(iso("2026-09-05T18:00:00Z"), in: "Asia/Shanghai", locale: Locale(identifier: "en_US"))
        XCTAssertTrue(shanghai.contains("Sep 6, 2026"), shanghai)
        XCTAssertTrue(CalendarTimeZoneTools.search("New York", locale: Locale(identifier: "en_US")).contains("America/New_York"))
    }

    @MainActor
    func testManagerAppliesDedupToEveryReadAndPersistsToggle() throws {
        let suite = "CalendarToolsTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let now = Date()
        let first = event(id: "a", calendarID: "a", title: "Same", date: now)
        let second = event(id: "b", calendarID: "b", title: "Same", date: now)
        let fixture = CalendarSelectionTestDataSource(eventsByCalendarID: ["a": [first], "b": [second]])
        let manager = CalendarManager(dataSource: fixture, defaults: defaults)
        XCTAssertEqual(manager.todayEvents.count, 1)
        XCTAssertEqual(manager.planningEvents.count, 1)
        XCTAssertEqual(manager.events(for: now).count, 1)
        XCTAssertEqual(manager.events(inMonthContaining: now).count, 1)
        XCTAssertEqual(manager.events(from: now.addingTimeInterval(-1), to: now.addingTimeInterval(7_200)).count, 1)
        manager.setDeduplicatesEvents(false)
        XCTAssertEqual(manager.todayEvents.count, 2)
        XCTAssertEqual(manager.events(for: now).count, 2)
        XCTAssertFalse(defaults.bool(forKey: CalendarDuplicatePolicy.storageKey))
        defaults.set(["a"], forKey: CalendarSelectionPolicy.storageKey)
        defaults.set(true, forKey: CalendarDuplicatePolicy.storageKey)
        manager.reloadPreferences()
        XCTAssertTrue(manager.deduplicatesEvents)
        XCTAssertFalse(manager.isCalendarSelected("a"))
        XCTAssertEqual(manager.todayEvents.map(\.id), ["b"])
    }

    @MainActor
    func testManagerValidatesBeforeWritingAndKeepsDraftOnProviderFailure() throws {
        let suite = "CalendarDraftWriteTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let fixture = CalendarDraftWriteFixture()
        let manager = CalendarManager(dataSource: fixture, defaults: defaults)
        var draft = CalendarEventDraft(calendarID: "work")
        XCTAssertThrowsError(try manager.createEvent(draft))
        XCTAssertEqual(fixture.createdDrafts.count, 0)
        draft.title = "Keep my draft"
        fixture.shouldFail = true
        XCTAssertThrowsError(try manager.createEvent(draft))
        XCTAssertEqual(draft.title, "Keep my draft")
        XCTAssertEqual(fixture.createdDrafts.count, 1)
        fixture.shouldFail = false
        let saved = try manager.createEvent(draft)
        XCTAssertEqual(saved.title, draft.title)
        XCTAssertEqual(fixture.createdDrafts.count, 2)
        fixture.authorizationStatus = .denied
        XCTAssertThrowsError(try manager.createEvent(draft)) { XCTAssertEqual($0 as? CalendarDraftError, .accessDenied) }
        XCTAssertEqual(fixture.createdDrafts.count, 2)
    }

    private func iso(_ string: String) -> Date { ISO8601DateFormatter().date(from: string)! }

    private func event(id: String, calendarID: String, title: String, location: String? = nil,
                       offset: TimeInterval = 0, date: Date? = nil) -> CalendarEvent {
        let start = (date ?? iso("2026-09-05T09:00:00Z")).addingTimeInterval(offset)
        return CalendarEvent(id: id, title: title, startDate: start, endDate: start.addingTimeInterval(1_800),
                             calendarName: "Calendar \(calendarID)", calendarColor: .systemBlue,
                             location: location, meetingLink: nil, isAllDay: false, calendarID: calendarID)
    }

    private func withLink(_ event: CalendarEvent, url: URL) -> CalendarEvent {
        CalendarEvent(id: event.id, title: event.title, startDate: event.startDate, endDate: event.endDate,
                      calendarName: event.calendarName, calendarColor: event.calendarColor, location: event.location,
                      meetingLink: MeetingLink(url: url, provider: .googleMeet), isAllDay: false, calendarID: event.calendarID)
    }
}

@MainActor
private final class CalendarDraftWriteFixture: CalendarDataSource {
    var authorizationStatus: EKAuthorizationStatus = .fullAccess
    var changeNotificationObject: AnyObject? { self }
    var createdDrafts: [CalendarEventDraft] = []
    var shouldFail = false
    func availableCalendars() -> [CalendarSource] {
        [CalendarSource(id: "work", title: "Work", sourceTitle: "Offline", allowsContentModifications: true)]
    }
    func events(from start: Date, to end: Date, calendarIDs: Set<String>) -> [CalendarEvent] { [] }
    func requestAccess(completion: @escaping @Sendable (Bool, Error?) -> Void) { completion(true, nil) }
    func createEvent(_ draft: CalendarEventDraft) throws -> CalendarEvent {
        createdDrafts.append(draft)
        if shouldFail { throw CalendarDraftError.creationUnavailable }
        return CalendarEvent(id: "saved", title: draft.title, startDate: draft.startDate, endDate: draft.endDate,
                             calendarName: "Work", calendarColor: nil, location: nil, meetingLink: nil,
                             isAllDay: draft.isAllDay, calendarID: draft.calendarID)
    }
}
