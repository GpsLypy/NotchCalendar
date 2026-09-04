import Foundation

extension Date {
    var startOfDay: Date { Calendar.current.startOfDay(for: self) }
    var endOfDay: Date { Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)! }
    var shortTime: String { formatted(date: .omitted, time: .shortened) }

    func shortTime(locale: Locale) -> String {
        formatted(.dateTime.hour().minute().locale(locale))
    }
}
