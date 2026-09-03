import AppKit
import XCTest
@testable import NotchCalendar

final class CalendarEventTests: XCTestCase {
    func testMultiDayEventOccursOnEveryOverlappingDate() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try XCTUnwrap(TimeZone(secondsFromGMT: 0))
        let start = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 8, day: 31, hour: 18)))
        let end = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 9, day: 2, hour: 9)))
        let event = CalendarEvent(
            id: "multi-day",
            title: "Offsite",
            startDate: start,
            endDate: end,
            calendarName: "Work",
            calendarColor: nil,
            location: nil,
            meetingLink: nil,
            isAllDay: false
        )

        for day in [31, 1, 2] {
            let month = day == 31 ? 8 : 9
            let date = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: month, day: day)))
            XCTAssertTrue(event.occurs(on: date, calendar: calendar))
        }

        let september3 = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 9, day: 3)))
        XCTAssertFalse(event.occurs(on: september3, calendar: calendar))
    }
}
