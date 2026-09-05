import Foundation

/// A break is retained in the journal, but never contributes to focus minutes.
enum FocusSessionKind: String, Codable, Sendable {
    case focus
    case breakTime = "break"
}

struct FocusHistoryRecord: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    let completedAt: Date
    let minutes: Int
    let kind: FocusSessionKind
}

struct FocusHistorySummary: Equatable, Sendable {
    let todayMinutes: Int
    let weekMinutes: Int

    init(records: [FocusHistoryRecord], now: Date, calendar: Calendar = .current) {
        let today = calendar.dateInterval(of: .day, for: now)
        let week = calendar.dateInterval(of: .weekOfYear, for: now)
        let focus = records.filter { $0.kind == .focus && $0.completedAt <= now }
        todayMinutes = focus.reduce(0) { total, record in
            total + (Self.contains(record.completedAt, in: today) ? record.minutes : 0)
        }
        weekMinutes = focus.reduce(0) { total, record in
            total + (Self.contains(record.completedAt, in: week) ? record.minutes : 0)
        }
    }

    // DateInterval.contains includes its end; a midnight completion belongs only to the new day.
    private static func contains(_ date: Date, in interval: DateInterval?) -> Bool {
        guard let interval else { return false }
        return date >= interval.start && date < interval.end
    }
}

enum FocusHistoryCSV {
    /// ISO 8601 dates are explicitly UTC (Z); machine-readable column names stay stable across languages.
    static func string(records: [FocusHistoryRecord]) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let rows = records.sorted {
            $0.completedAt == $1.completedAt
                ? $0.id.uuidString < $1.id.uuidString
                : $0.completedAt < $1.completedAt
        }.map { record in
            [record.id.uuidString, formatter.string(from: record.completedAt), "\(record.minutes)", record.kind.rawValue]
                .joined(separator: ",")
        }
        return (["session_id,completed_at_utc,duration_minutes,kind"] + rows).joined(separator: "\r\n") + "\r\n"
    }

    static func write(records: [FocusHistoryRecord], to url: URL) throws {
        try string(records: records).write(to: url, atomically: true, encoding: .utf8)
    }
}
