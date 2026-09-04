import Foundation
import NotchCalendarShared
import SwiftUI
import WidgetKit

struct TodayAgendaWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: WidgetConstants.agendaKind,
            provider: CalendarWidgetProvider()
        ) { entry in
            TodayAgendaWidgetView(entry: entry)
        }
        .configurationDisplayName("今日日程 / Today")
        .description("查看今天接下来的日程 / See what is next today")
        .supportedFamilies([.systemSmall])
        .contentMarginsDisabled()
        .containerBackgroundRemovable(false)
    }
}

private struct TodayAgendaWidgetView: View {
    let entry: CalendarWidgetEntry

    var body: some View {
        NotchWidgetCanvas {
            if let snapshot = entry.snapshot {
                let copy = NotchWidgetCopy(
                    localizationIdentifier: snapshot.localizationIdentifier
                )

                switch snapshot.authorization {
                case .available:
                    TodayAgendaContent(
                        date: entry.date,
                        snapshot: snapshot,
                        copy: copy
                    )
                case .needsPermission:
                    NotchWidgetGuidance(
                        symbol: "calendar.badge.exclamationmark",
                        title: copy.calendarPermissionTitle,
                        detail: copy.calendarPermissionDetail,
                        destination: NotchWidgetDestination.today,
                        openLabel: copy.openApp
                    )
                }
            } else {
                let copy = NotchWidgetCopy(localizationIdentifier: nil)
                NotchWidgetGuidance(
                    symbol: "list.bullet.rectangle",
                    title: copy.calendarSetupTitle,
                    detail: copy.calendarSetupDetail,
                    destination: NotchWidgetDestination.today,
                    openLabel: copy.openApp
                )
            }
        }
    }
}

private struct TodayAgendaContent: View {
    let date: Date
    let snapshot: WidgetCalendarSnapshot
    let copy: NotchWidgetCopy

    private var context: WidgetCalendarContext {
        WidgetCalendarContext(snapshot: snapshot)
    }

    private var events: [WidgetEventSnapshot] {
        let calendar = context.calendar
        return snapshot.events
            .filter {
                $0.occurs(on: date, calendar: calendar) && $0.endDate > date
            }
            .sorted { left, right in
                if left.isAllDay != right.isAllDay {
                    return left.isAllDay
                }
                return left.startDate < right.startDate
            }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            NotchWidgetHeader(
                title: copy.agendaWidgetName,
                destination: NotchWidgetDestination.today,
                openLabel: copy.openApp
            ) {
                Text(dayLabel)
                    .font(.system(size: 9, weight: .medium, design: .rounded))
                    .foregroundStyle(NotchWidgetPalette.secondary)
            }

            if events.isEmpty {
                Spacer(minLength: 0)
                VStack(alignment: .leading, spacing: 6) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 21, weight: .medium))
                        .foregroundStyle(NotchWidgetPalette.coral)

                    Text(copy.noEventsTitle)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(NotchWidgetPalette.primary)

                    Text(copy.noEventsDetail)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(NotchWidgetPalette.secondary)
                }
                Spacer(minLength: 0)
            } else {
                VStack(alignment: .leading, spacing: 7) {
                    ForEach(Array(events.prefix(3).enumerated()), id: \.element.id) { index, event in
                        AgendaEventRow(
                            event: event,
                            isLast: index == min(events.count, 3) - 1,
                            copy: copy,
                            context: context
                        )
                    }
                }

                if events.count > 3 {
                    Text("+\(events.count - 3)")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(NotchWidgetPalette.coral)
                        .padding(.leading, 12)
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(copy.agendaWidgetName), \(dayLabel)")
    }

    private var dayLabel: String {
        let formatter = DateFormatter()
        formatter.locale = context.locale
        formatter.timeZone = context.timeZone
        formatter.dateFormat = copy.isChinese ? "M月d日 E" : "E · MMM d"
        return formatter.string(from: date)
    }
}

private struct AgendaEventRow: View {
    let event: WidgetEventSnapshot
    let isLast: Bool
    let copy: NotchWidgetCopy
    let context: WidgetCalendarContext

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(spacing: 0) {
                Circle()
                    .fill(NotchWidgetPalette.coral)
                    .frame(width: 7, height: 7)

                if !isLast {
                    Rectangle()
                        .fill(NotchWidgetPalette.coral.opacity(0.32))
                        .frame(width: 1.5)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 7)

            VStack(alignment: .leading, spacing: 2) {
                Text(displayTitle)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(NotchWidgetPalette.primary)
                    .lineLimit(1)

                Text(timeLabel)
                    .font(.system(size: 9, weight: .medium, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(NotchWidgetPalette.secondary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 27)
    }

    private var timeLabel: String {
        guard !event.isAllDay else { return copy.allDay }

        let formatter = DateFormatter()
        formatter.locale = context.locale
        formatter.timeZone = context.timeZone
        formatter.setLocalizedDateFormatFromTemplate("Hm")
        return "\(formatter.string(from: event.startDate))–\(formatter.string(from: event.endDate))"
    }

    private var displayTitle: String {
        let title = event.title.trimmingCharacters(in: .whitespacesAndNewlines)
        return title.isEmpty ? copy.untitledEvent : title
    }
}
