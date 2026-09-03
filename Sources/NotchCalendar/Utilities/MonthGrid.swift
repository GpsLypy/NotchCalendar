import Foundation

/// Calendar calculations kept separate from the view so locale and first-weekday
/// behavior can be verified without rendering SwiftUI.
struct MonthGrid {
    let calendar: Calendar
    let referenceDate: Date

    init(monthContaining date: Date, calendar: Calendar = .current) {
        self.calendar = calendar
        referenceDate = date
    }

    var orderedWeekdaySymbols: [String] {
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        guard !symbols.isEmpty else { return [] }

        let firstIndex = positiveModulo(calendar.firstWeekday - 1, symbols.count)
        return Array(symbols[firstIndex...]) + Array(symbols[..<firstIndex])
    }

    var leadingOffset: Int {
        guard let monthStart else { return 0 }
        let weekdayCount = max(calendar.veryShortStandaloneWeekdaySymbols.count, 1)
        return positiveModulo(
            calendar.component(.weekday, from: monthStart) - calendar.firstWeekday,
            weekdayCount
        )
    }

    var days: [Date?] {
        guard let monthStart,
              let dayRange = calendar.range(of: .day, in: .month, for: monthStart) else {
            return []
        }

        let dates = (0..<dayRange.count).map {
            calendar.date(byAdding: .day, value: $0, to: monthStart)
        }
        return Array(repeating: nil, count: leadingOffset) + dates
    }

    func date(byAddingMonths offset: Int) -> Date? {
        guard let monthStart,
              let targetMonthStart = calendar.date(byAdding: .month, value: offset, to: monthStart),
              let targetDayRange = calendar.range(of: .day, in: .month, for: targetMonthStart) else {
            return nil
        }

        let currentDay = calendar.component(.day, from: referenceDate)
        let targetDay = min(max(currentDay, targetDayRange.lowerBound), targetDayRange.upperBound - 1)
        return calendar.date(
            byAdding: .day,
            value: targetDay - targetDayRange.lowerBound,
            to: targetMonthStart
        )
    }

    private var monthStart: Date? {
        calendar.dateInterval(of: .month, for: referenceDate)?.start
    }

    private func positiveModulo(_ value: Int, _ divisor: Int) -> Int {
        let remainder = value % divisor
        return remainder >= 0 ? remainder : remainder + divisor
    }
}
