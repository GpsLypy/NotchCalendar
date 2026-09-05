import AppKit

struct CalendarEvent: Identifiable, Equatable {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
    let calendarName: String
    let calendarColor: NSColor?
    let location: String?
    let meetingLink: MeetingLink?
    let isAllDay: Bool
    var blocksTime: Bool = true

    func displayTitle(language: AppLanguage) -> String {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return L10n.string("Untitled event", language: language)
        }
        return title
    }

    func occurs(on date: Date, calendar: Calendar = .current) -> Bool {
        let dayStart = calendar.startOfDay(for: date)
        guard let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else { return false }
        return startDate < dayEnd && endDate > dayStart
    }
}

enum EventStatus {
    case active(CalendarEvent, secondsRemaining: Int)
    case upcoming(CalendarEvent, secondsUntilStart: Int)
    case idle

    var isActive: Bool {
        if case .active = self { return true }
        return false
    }
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

    static func progress(now: Date, event: CalendarEvent) -> Double {
        let duration = event.endDate.timeIntervalSince(event.startDate)
        guard duration > 0 else { return 0 }
        let elapsed = now.timeIntervalSince(event.startDate)
        return min(max(elapsed / duration, 0), 1)
    }
}
