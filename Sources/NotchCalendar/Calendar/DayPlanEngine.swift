import Foundation

/// Local clock hours describe the planning window, so daylight-saving days do
/// not assume that midnight plus 24 hours is the next midnight.
struct DayPlanSettings: Equatable {
    static let startHourKey = "workspace.planning.startHour"
    static let endHourKey = "workspace.planning.endHour"
    static let bufferMinutesKey = "workspace.planning.bufferMinutes"

    let startHour: Int
    let endHour: Int
    let bufferMinutes: Int

    init(startHour: Int = 9, endHour: Int = 18, bufferMinutes: Int = 5) {
        self.startHour = min(23, max(0, startHour))
        self.endHour = min(24, max(self.startHour + 1, endHour))
        self.bufferMinutes = min(30, max(0, bufferMinutes))
    }
}

struct DayPlanInterval: Equatable, Identifiable {
    let start: Date
    let end: Date
    var id: Date { start }
    var minutes: Int { max(0, Int(end.timeIntervalSince(start) / 60)) }
}

struct DayPlanConflict: Identifiable {
    let events: [CalendarEvent]
    var id: String { events.map { "\($0.id)|\($0.startDate.timeIntervalSince1970)" }.joined(separator: ";") }
}

struct DayPlan {
    let window: DayPlanInterval
    let busyIntervals: [DayPlanInterval]
    let freeIntervals: [DayPlanInterval]
    let conflicts: [DayPlanConflict]
    let allDayEventCount: Int

    var availableMinutes: Int { freeIntervals.reduce(0) { $0 + $1.minutes } }

    /// A suggestion only prepares a timer. Recompute at the moment of the click
    /// so a stale view can never propose time that has already elapsed.
    func recommendedFocusMinutes(at now: Date) -> Int? {
        guard let current = freeIntervals.first(where: { $0.start <= now && $0.end > now }) else { return nil }
        let minutes = min(50, Int(current.end.timeIntervalSince(now) / 60))
        return minutes >= 5 ? minutes : nil
    }
}

enum DayPlanEngine {
    static func makePlan(
        events: [CalendarEvent],
        now: Date,
        settings: DayPlanSettings = DayPlanSettings(),
        calendar: Calendar = .current
    ) -> DayPlan {
        let dayStart = calendar.startOfDay(for: now)
        let nextDay = calendar.date(byAdding: .day, value: 1, to: dayStart)!
        func localHour(_ hour: Int) -> Date {
            if hour == 24 { return nextDay }
            return calendar.date(bySettingHour: hour, minute: 0, second: 0, of: dayStart) ?? dayStart
        }
        let window = DayPlanInterval(start: localHour(settings.startHour), end: localHour(settings.endHour))
        // Retain informational all-day events in the agenda, but explicitly
        // exclude them from timed availability (the UI states this limitation).
        let timed = events.filter { !$0.isAllDay && $0.blocksTime && $0.startDate < $0.endDate }
        let buffer = TimeInterval(settings.bufferMinutes * 60)
        let busy = merge(timed.compactMap { event in
            clipped(
                start: event.startDate.addingTimeInterval(-buffer),
                end: event.endDate.addingTimeInterval(buffer),
                lower: window.start,
                upper: window.end
            )
        })
        var free: [DayPlanInterval] = []
        var cursor = max(now, window.start)
        for interval in busy where interval.end > cursor {
            if interval.start > cursor {
                free.append(DayPlanInterval(start: cursor, end: interval.start))
            }
            cursor = max(cursor, interval.end)
        }
        if cursor < window.end { free.append(DayPlanInterval(start: cursor, end: window.end)) }

        return DayPlan(
            window: window,
            busyIntervals: busy,
            freeIntervals: free,
            conflicts: conflictGroups(events: timed, from: max(dayStart, now), to: nextDay),
            allDayEventCount: events.filter { $0.isAllDay && $0.startDate < nextDay && $0.endDate > dayStart }.count
        )
    }

    private static func clipped(start: Date, end: Date, lower: Date, upper: Date) -> DayPlanInterval? {
        let start = max(start, lower)
        let end = min(end, upper)
        return start < end ? DayPlanInterval(start: start, end: end) : nil
    }

    private static func merge(_ intervals: [DayPlanInterval]) -> [DayPlanInterval] {
        var result: [DayPlanInterval] = []
        for interval in intervals.sorted(by: { $0.start < $1.start }) {
            if let last = result.last, interval.start <= last.end {
                result[result.count - 1] = DayPlanInterval(start: last.start, end: max(last.end, interval.end))
            } else {
                result.append(interval)
            }
        }
        return result
    }

    private static func conflictGroups(events: [CalendarEvent], from start: Date, to end: Date) -> [DayPlanConflict] {
        let events = events.filter { $0.startDate < end && $0.endDate > start }
            .sorted { $0.startDate == $1.startDate ? $0.id < $1.id : $0.startDate < $1.startDate }
        var groups: [DayPlanConflict] = []
        var current: [CalendarEvent] = []
        var occupiedUntil = start
        for event in events {
            // Touching endpoints are not conflicts. Buffers affect free time,
            // never whether the original events actually overlap.
            if !current.isEmpty && event.startDate >= occupiedUntil {
                if current.count > 1 { groups.append(DayPlanConflict(events: current)) }
                current = []
            }
            current.append(event)
            occupiedUntil = max(current.count == 1 ? start : occupiedUntil, event.endDate)
        }
        if current.count > 1 { groups.append(DayPlanConflict(events: current)) }
        return groups
    }
}
