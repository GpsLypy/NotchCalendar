import Foundation
import NotchCalendarShared
import WidgetKit

struct CalendarWidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetCalendarSnapshot?
}

struct FocusWidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetFocusSnapshot?
}

struct CalendarWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> CalendarWidgetEntry {
        CalendarWidgetEntry(
            date: WidgetPreviewData.referenceDate,
            snapshot: WidgetPreviewData.calendar
        )
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (CalendarWidgetEntry) -> Void
    ) {
        let date = Date()
        completion(
            CalendarWidgetEntry(
                date: date,
                snapshot: context.isPreview
                    ? WidgetPreviewData.calendar(at: date)
                    : WidgetSnapshotStore.readCalendar()
            )
        )
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<CalendarWidgetEntry>) -> Void
    ) {
        let date = Date()
        let snapshot = WidgetSnapshotStore.readCalendar()
        let entry = CalendarWidgetEntry(date: date, snapshot: snapshot)
        let refreshDate = nextRefresh(after: date, snapshot: snapshot)
        completion(Timeline(entries: [entry], policy: .after(refreshDate)))
    }

    private func nextRefresh(
        after date: Date,
        snapshot: WidgetCalendarSnapshot?
    ) -> Date {
        guard let snapshot else {
            return date.addingTimeInterval(15 * 60)
        }

        let calendar = WidgetCalendarContext(snapshot: snapshot).calendar
        let nextDay = calendar.date(
            byAdding: .day,
            value: 1,
            to: calendar.startOfDay(for: date)
        ) ?? date.addingTimeInterval(60 * 60)

        let nextBoundary = snapshot.events
            .flatMap { [$0.startDate, $0.endDate] }
            .filter { $0 > date }
            .min()

        return [nextDay, nextBoundary]
            .compactMap { $0 }
            .min() ?? nextDay
    }
}

struct FocusWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> FocusWidgetEntry {
        FocusWidgetEntry(
            date: WidgetPreviewData.referenceDate,
            snapshot: WidgetPreviewData.focus
        )
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (FocusWidgetEntry) -> Void
    ) {
        let date = Date()
        completion(
            FocusWidgetEntry(
                date: date,
                snapshot: context.isPreview
                    ? WidgetPreviewData.focus(at: date)
                    : WidgetSnapshotStore.readFocus()
            )
        )
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<FocusWidgetEntry>) -> Void
    ) {
        let date = Date()
        let snapshot = WidgetSnapshotStore.readFocus()
        var entries = [FocusWidgetEntry(date: date, snapshot: snapshot)]

        if let targetDate = snapshot?.targetDate,
           snapshot?.isRunning == true,
           targetDate > date {
            let completionDate = targetDate.addingTimeInterval(1)
            entries.append(FocusWidgetEntry(date: completionDate, snapshot: snapshot))
            completion(
                Timeline(
                    entries: entries,
                    policy: .after(completionDate.addingTimeInterval(15 * 60))
                )
            )
            return
        }

        completion(
            Timeline(
                entries: entries,
                policy: .after(date.addingTimeInterval(15 * 60))
            )
        )
    }
}

struct WidgetCalendarContext {
    let locale: Locale
    let calendar: Calendar
    let timeZone: TimeZone

    init(snapshot: WidgetCalendarSnapshot) {
        let locale = Locale(identifier: snapshot.localizationIdentifier)
        let timeZone = TimeZone(identifier: snapshot.timeZoneIdentifier) ?? .current
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = locale
        calendar.timeZone = timeZone

        self.locale = locale
        self.calendar = calendar
        self.timeZone = timeZone
    }
}

enum WidgetPreviewData {
    static let referenceDate = Date(timeIntervalSince1970: 1_788_485_400)

    static var calendar: WidgetCalendarSnapshot {
        calendar(at: referenceDate)
    }

    static func calendar(at date: Date) -> WidgetCalendarSnapshot {
        let calendar = Calendar(identifier: .gregorian)
        let dayStart = calendar.startOfDay(for: date)
        let firstStart = calendar.date(byAdding: .hour, value: 9, to: dayStart) ?? date
        let secondStart = calendar.date(byAdding: .hour, value: 14, to: dayStart) ?? date

        return WidgetCalendarSnapshot(
            authorization: .available,
            events: [
                WidgetEventSnapshot(
                    id: "preview-standup",
                    title: "Weekly sync",
                    startDate: firstStart,
                    endDate: firstStart.addingTimeInterval(45 * 60),
                    calendarName: "Work",
                    calendarColor: nil,
                    isAllDay: false
                ),
                WidgetEventSnapshot(
                    id: "preview-review",
                    title: "Design review",
                    startDate: secondStart,
                    endDate: secondStart.addingTimeInterval(60 * 60),
                    calendarName: "Work",
                    calendarColor: nil,
                    isAllDay: false
                )
            ],
            localizationIdentifier: "en",
            timeZoneIdentifier: TimeZone.current.identifier
        )
    }

    static var focus: WidgetFocusSnapshot {
        focus(at: referenceDate)
    }

    static func focus(at date: Date) -> WidgetFocusSnapshot {
        WidgetFocusSnapshot(
            selectedMinutes: 50,
            remainingSecondsAtWrite: 35 * 60,
            isRunning: true,
            targetDate: date.addingTimeInterval(35 * 60),
            completedSessions: 3,
            localizationIdentifier: "en"
        )
    }
}
