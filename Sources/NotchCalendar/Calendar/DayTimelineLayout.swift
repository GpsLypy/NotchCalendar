import Foundation

/// Actual appointments, without planning buffers. Overlaps occupy separate
/// lanes; adjacent endpoints can reuse a lane. Fractions use elapsed time so
/// the geometry remains correct on daylight-saving days.
struct DayTimelineLayout {
    struct Segment: Identifiable {
        let event: CalendarEvent
        let lane: Int
        let startFraction: Double
        let endFraction: Double
        var id: String { event.occurrenceStableID }
    }

    let segments: [Segment]
    let laneCount: Int

    init(events: [CalendarEvent], window: DayPlanInterval) {
        let duration = window.end.timeIntervalSince(window.start)
        guard duration > 0 else { segments = []; laneCount = 0; return }
        let candidates = events.filter {
            !$0.isAllDay && $0.isEligibleForMeeting && $0.startDate < $0.endDate
                && $0.startDate < window.end && $0.endDate > window.start
        }.sorted {
            if $0.startDate != $1.startDate { return $0.startDate < $1.startDate }
            return $0.occurrenceStableID < $1.occurrenceStableID
        }
        var ends: [Date] = []
        var result: [Segment] = []
        var seen: Set<String> = []
        for event in candidates where seen.insert(event.occurrenceStableID).inserted {
            let start = max(event.startDate, window.start)
            let end = min(event.endDate, window.end)
            let lane = ends.firstIndex { $0 <= start } ?? ends.count
            if lane == ends.count { ends.append(end) } else { ends[lane] = end }
            result.append(Segment(event: event, lane: lane,
                                  startFraction: start.timeIntervalSince(window.start) / duration,
                                  endFraction: end.timeIntervalSince(window.start) / duration))
        }
        segments = result
        laneCount = ends.count
    }
}
