import Foundation

struct FocusWeeklyReview: Equatable, Sendable {
    struct Day: Identifiable, Equatable, Sendable {
        var id: Date { date }
        let date: Date
        let minutes: Int
        let sessions: Int
    }
    struct TaskTotal: Identifiable, Equatable, Sendable {
        var id: String { label ?? "" }
        let label: String?
        let minutes: Int
        let sessions: Int
    }
    let interval: DateInterval
    let days: [Day]
    let tasks: [TaskTotal]
    var minutes: Int { days.reduce(0) { $0 + $1.minutes } }
    var sessions: Int { days.reduce(0) { $0 + $1.sessions } }

    init(records: [FocusHistoryRecord], weekContaining date: Date, now: Date = Date(), calendar: Calendar = .current) {
        let start = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 7, to: start) ?? start
        interval = DateInterval(start: start, end: end)
        let included = records.filter {
            $0.kind == .focus && $0.minutes > 0 && $0.completedAt >= start && $0.completedAt < end && $0.completedAt <= now
        }
        days = (0..<7).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: start),
                  let next = calendar.date(byAdding: .day, value: 1, to: date) else { return nil }
            let records = included.filter { $0.completedAt >= date && $0.completedAt < next }
            return Day(date: date, minutes: records.reduce(0) { $0 + $1.minutes }, sessions: records.count)
        }
        let grouped = Dictionary(grouping: included) { ($0.taskLabel ?? "").trimmingCharacters(in: .whitespacesAndNewlines) }
        tasks = grouped.map { label, records in
            TaskTotal(label: label.isEmpty ? nil : label, minutes: records.reduce(0) { $0 + $1.minutes }, sessions: records.count)
        }.sorted { $0.minutes == $1.minutes ? $0.id < $1.id : $0.minutes > $1.minutes }
    }

    func markdown(language: AppLanguage, calendar: Calendar = .current) -> String {
        func t(_ key: String, _ arguments: CVarArg...) -> String { L10n.string(key, language: language, arguments: arguments) }
        let formatter = DateFormatter()
        formatter.locale = language.locale
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = "yyyy-MM-dd"
        let lastDay = calendar.date(byAdding: .day, value: -1, to: interval.end) ?? interval.start
        var lines = ["# \(t("Weekly review"))", "", "\(formatter.string(from: interval.start)) – \(formatter.string(from: lastDay)) · \(calendar.timeZone.identifier)", "", t("%@ minutes across %@ focus sessions", "\(minutes)", "\(sessions)"), "", "## \(t("Daily focus"))", ""]
        for day in days { lines.append("- \(formatter.string(from: day.date)): \(t("%@ min", "\(day.minutes)"))") }
        lines += ["", "## \(t("Task labels"))", ""]
        for task in tasks {
            let label = (task.label ?? t("Unlabeled")).replacingOccurrences(of: "\n", with: " ").replacingOccurrences(of: "\r", with: " ")
            // User text stays plain inside the report, even when it includes Markdown syntax.
            let escaped = label.reduce("") { $0 + ("\\`*_{}[]<>#!|".contains($1) ? "\\\($1)" : String($1)) }
            lines.append("- \(escaped): \(t("%@ min", "\(task.minutes)")) (\(task.sessions))")
        }
        if tasks.isEmpty { lines.append(t("No completed focus sessions this week.")) }
        lines += ["", t("This review uses retained local completions only. Breaks and unfinished sessions are excluded."), ""]
        return lines.joined(separator: "\n")
    }
}
