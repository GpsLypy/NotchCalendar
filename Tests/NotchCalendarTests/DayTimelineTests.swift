import XCTest
@testable import NotchCalendar

@MainActor final class DayTimelineTests: XCTestCase {
    private let origin = Date(timeIntervalSinceReferenceDate: 10_000)
    private func event(_ id: String, _ start: Double, _ end: Double) -> CalendarEvent {
        CalendarSelectionTestDataSource.event(id: id, start: origin.addingTimeInterval(start), end: origin.addingTimeInterval(end))
    }
    private var window: DayPlanInterval { DayPlanInterval(start: origin, end: origin.addingTimeInterval(100)) }

    func testClipsSpanningEventsAndUsesIndependentLanesForOverlaps() {
        let layout = DayTimelineLayout(events: [event("b", 20, 40), event("a", -50, 120), event("c", 40, 60)], window: window)
        XCTAssertEqual(layout.laneCount, 2)
        XCTAssertEqual(layout.segments.map(\.event.id), ["a", "b", "c"])
        XCTAssertEqual(layout.segments.map(\.lane), [0, 1, 1])
        XCTAssertEqual(layout.segments[0].startFraction, 0)
        XCTAssertEqual(layout.segments[0].endFraction, 1)
        XCTAssertEqual(layout.segments[1].startFraction, 0.2, accuracy: 0.0001)
    }

    func testRejectsInvalidCancelledAllDayAndOutsideWindowEvents() {
        var cancelled = event("cancelled", 10, 30); cancelled.isEligibleForMeeting = false
        let allDay = CalendarEvent(id: "all", title: "Holiday", startDate: origin, endDate: origin.addingTimeInterval(200), calendarName: "Work", calendarColor: nil, location: nil, meetingLink: nil, isAllDay: true)
        let layout = DayTimelineLayout(events: [cancelled, allDay, event("zero", 50, 50), event("reversed", 80, 70), event("before", -20, 0), event("after", 100, 120)], window: window)
        XCTAssertTrue(layout.segments.isEmpty)
        XCTAssertEqual(layout.laneCount, 0)
    }

    func testDuplicateOccurrencesDoNotCreateDuplicateViewIDs() {
        let appointment = event("same", 10, 20)
        XCTAssertEqual(DayTimelineLayout(events: [appointment, appointment], window: window).segments.count, 1)
        XCTAssertEqual(DayTimelineLayout(events: [appointment, event("same", 30, 40)], window: window).segments.count, 2)
    }

    func testDoesNotDropDenseOverlapLanes() {
        let events = (0..<30).map { event("event-\($0)", 10, 90) }
        let layout = DayTimelineLayout(events: events.reversed(), window: window)
        XCTAssertEqual(layout.segments.count, 30)
        XCTAssertEqual(layout.laneCount, 30)
        XCTAssertEqual(layout.segments.map(\.id), DayTimelineLayout(events: events, window: window).segments.map(\.id))
    }

    func testEmptyOrReversedWindowIsSafe() {
        for end in [origin, origin.addingTimeInterval(-1)] {
            XCTAssertTrue(DayTimelineLayout(events: [event("a", 0, 100)], window: DayPlanInterval(start: origin, end: end)).segments.isEmpty)
        }
    }

    func testDaylightSavingTrackUsesActualElapsedDuration() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try XCTUnwrap(TimeZone(identifier: "America/New_York"))
        for (month, day, hours) in [(3, 8, 23), (11, 1, 25)] {
            let start = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: month, day: day)))
            let end = try XCTUnwrap(calendar.date(byAdding: .day, value: 1, to: start))
            let event = CalendarSelectionTestDataSource.event(id: "dst", start: start, end: start.addingTimeInterval(3_600))
            let layout = DayTimelineLayout(events: [event], window: DayPlanInterval(start: start, end: end))
            XCTAssertEqual(layout.segments[0].endFraction, 1 / Double(hours), accuracy: 0.0001)
        }
    }
}
