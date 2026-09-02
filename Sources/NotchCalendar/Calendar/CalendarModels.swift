import AppKit

struct CalendarEvent: Identifiable {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
    let calendarName: String
    let calendarColor: NSColor?
    let location: String?
    let isAllDay: Bool
}

enum EventStatus {
    case active(CalendarEvent, secondsRemaining: Int)
    case upcoming(CalendarEvent, secondsUntilStart: Int)
    case idle
}

enum UpcomingEventEngine {
    static func status(now: Date, events: [CalendarEvent]) -> EventStatus {
        let timedEvents = events.filter { !$0.isAllDay }

        if let active = timedEvents.first(where: { $0.startDate <= now && $0.endDate > now }) {
            return .active(
                active,
                secondsRemaining: max(1, Int(ceil(active.endDate.timeIntervalSince(now))))
            )
        }
        if let next = timedEvents.first(where: { $0.startDate > now }) {
            let seconds = Int(ceil(next.startDate.timeIntervalSince(now)))
            if seconds <= 60 * 60 {
                return .upcoming(next, secondsUntilStart: max(1, seconds))
            }
        }
        return .idle
    }

    static func countdown(_ seconds: Int) -> String {
        let clampedSeconds = max(0, seconds)
        let hours = clampedSeconds / 3_600
        let minutes = (clampedSeconds % 3_600) / 60
        let seconds = clampedSeconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
