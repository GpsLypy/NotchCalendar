import Foundation
import XCTest
@testable import NotchCalendar

final class MonthGridTests: XCTestCase {
    func testEnglishSundayFirstOrdersSymbolsAndStartsSundayMonthAtZero() throws {
        let calendar = englishGregorianCalendar(firstWeekday: 1)
        let date = try XCTUnwrap(calendar.date(from: DateComponents(year: 2024, month: 9, day: 15)))

        let grid = MonthGrid(monthContaining: date, calendar: calendar)

        XCTAssertEqual(grid.orderedWeekdaySymbols, ["S", "M", "T", "W", "T", "F", "S"])
        XCTAssertEqual(grid.leadingOffset, 0)
        XCTAssertEqual(grid.days.firstIndex(where: { $0 != nil }), 0)
    }

    func testEnglishMondayFirstRotatesSymbolsAndOffsetsSundayMonth() throws {
        let calendar = englishGregorianCalendar(firstWeekday: 2)
        let date = try XCTUnwrap(calendar.date(from: DateComponents(year: 2024, month: 9, day: 15)))

        let grid = MonthGrid(monthContaining: date, calendar: calendar)

        XCTAssertEqual(grid.orderedWeekdaySymbols, ["M", "T", "W", "T", "F", "S", "S"])
        XCTAssertEqual(grid.leadingOffset, 6)
        XCTAssertEqual(grid.days.firstIndex(where: { $0 != nil }), 6)
    }

    func testMovingFromLongMonthClampsSelectionToTargetMonthEnd() throws {
        let calendar = englishGregorianCalendar(firstWeekday: 1)
        let january31 = try XCTUnwrap(
            calendar.date(from: DateComponents(year: 2025, month: 1, day: 31))
        )

        let february = try XCTUnwrap(
            MonthGrid(monthContaining: january31, calendar: calendar).date(byAddingMonths: 1)
        )

        XCTAssertEqual(calendar.dateComponents([.year, .month, .day], from: february),
                       DateComponents(year: 2025, month: 2, day: 28))
    }

    private func englishGregorianCalendar(firstWeekday: Int) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US")
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.firstWeekday = firstWeekday
        return calendar
    }
}
