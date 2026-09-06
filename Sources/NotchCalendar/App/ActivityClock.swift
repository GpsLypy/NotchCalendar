import AppKit
import Combine
import SwiftUI

/// Visible second-level information needs a second tick; otherwise wake only for
/// the clock's minute display or the next eligible meeting boundary.
enum ActivityClockPolicy {
    static func compactInterval(now: Date, events: [CalendarEvent], showsMeetings: Bool,
                                displaysUpcoming: Bool, visibleFocusRunning: Bool) -> TimeInterval {
        if visibleFocusRunning { return 1 }
        let minuteRemainder = now.timeIntervalSince1970.truncatingRemainder(dividingBy: 60)
        let nextMinute = 60 - (minuteRemainder < 0 ? minuteRemainder + 60 : minuteRemainder)
        guard showsMeetings else { return max(0.05, nextMinute) }
        switch UpcomingEventEngine.status(now: now, events: events) {
        case .active: return 1
        case .upcoming where displaysUpcoming: return 1
        default:
            let boundary = events.lazy.filter {
                !$0.isAllDay && $0.isEligibleForMeeting && $0.endDate > $0.startDate && $0.startDate > now
            }.map { $0.startDate.timeIntervalSince(now) }.min() ?? nextMinute
            return max(0.05, min(nextMinute, boundary))
        }
    }
}

private struct ActivityClockModifier: ViewModifier {
    let interval: TimeInterval?
    let tick: @MainActor (Date) -> Void

    func body(content: Content) -> some View {
        content
            .task(id: interval) {
                guard let interval, interval > 0, interval.isFinite else { return }
                do {
                    while !Task.isCancelled {
                        try await Task.sleep(for: .seconds(interval))
                        try Task.checkCancellation()
                        tick(Date())
                    }
                } catch { /* View removal or a changed cadence cancels the clock. */ }
            }
            .onReceive(Publishers.MergeMany([
                NotificationCenter.default.publisher(for: .NSSystemClockDidChange),
                NotificationCenter.default.publisher(for: .NSSystemTimeZoneDidChange),
                NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.didWakeNotification)
            ]).receive(on: RunLoop.main)) { _ in tick(Date()) }
    }
}

extension View {
    /// nil suspends periodic work. Changing cadence or removing the view cancels
    /// its pending wakeup instead of leaving a connected timer behind.
    func onActivityClock(every interval: TimeInterval?, perform tick: @escaping @MainActor (Date) -> Void) -> some View {
        modifier(ActivityClockModifier(interval: interval, tick: tick))
    }
}
