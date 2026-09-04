import Foundation
import NotchCalendarShared
import SwiftUI
import WidgetKit

struct MonthCalendarWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: WidgetConstants.monthKind,
            provider: CalendarWidgetProvider()
        ) { entry in
            MonthCalendarWidgetView(entry: entry)
        }
        .configurationDisplayName("月历 / Month")
        .description("查看本月日期与日程标记 / See this month and event markers")
        .supportedFamilies([.systemSmall])
        .contentMarginsDisabled()
        .containerBackgroundRemovable(false)
    }
}

private struct MonthCalendarWidgetView: View {
    let entry: CalendarWidgetEntry

    var body: some View {
        NotchWidgetCanvas {
            if let snapshot = entry.snapshot {
                let copy = NotchWidgetCopy(
                    localizationIdentifier: snapshot.localizationIdentifier
                )

                switch snapshot.authorization {
                case .available:
                    MonthGrid(
                        date: entry.date,
                        snapshot: snapshot,
                        copy: copy
                    )
                case .needsPermission:
                    NotchWidgetGuidance(
                        symbol: "calendar.badge.exclamationmark",
                        title: copy.calendarPermissionTitle,
                        detail: copy.calendarPermissionDetail,
                        destination: NotchWidgetDestination.calendar,
                        openLabel: copy.openApp
                    )
                }
            } else {
                let copy = NotchWidgetCopy(localizationIdentifier: nil)
                NotchWidgetGuidance(
                    symbol: "calendar.badge.clock",
                    title: copy.calendarSetupTitle,
                    detail: copy.calendarSetupDetail,
                    destination: NotchWidgetDestination.calendar,
                    openLabel: copy.openApp
                )
            }
        }
    }
}

private struct MonthGrid: View {
    let date: Date
    let snapshot: WidgetCalendarSnapshot
    let copy: NotchWidgetCopy

    private var model: MonthGridModel {
        MonthGridModel(date: date, snapshot: snapshot)
    }

    var body: some View {
        let model = model

        VStack(alignment: .leading, spacing: 7) {
            NotchWidgetHeader(
                title: model.monthTitle,
                destination: NotchWidgetDestination.calendar,
                openLabel: copy.openApp
            ) {
                Text("\(model.todayDay)")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(NotchWidgetPalette.coral)
            }

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 1), count: 7),
                spacing: 3
            ) {
                ForEach(Array(model.weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                    Text(symbol)
                        .font(.system(size: 8, weight: .semibold, design: .rounded))
                        .foregroundStyle(NotchWidgetPalette.secondary)
                        .frame(maxWidth: .infinity)
                }

                ForEach(model.cells) { cell in
                    MonthDayCell(cell: cell)
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(copy.monthWidgetName), \(model.monthTitle)")
    }
}

private struct MonthDayCell: View {
    let cell: MonthGridModel.Cell

    var body: some View {
        ZStack(alignment: .bottom) {
            if let day = cell.day {
                if cell.isToday {
                    Circle()
                        .fill(NotchWidgetPalette.coral)
                        .frame(width: 16, height: 16)
                }

                Text("\(day)")
                    .font(.system(size: 8.5, weight: cell.isToday ? .bold : .medium, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(
                        cell.isToday
                            ? NotchWidgetPalette.primary
                            : NotchWidgetPalette.primary.opacity(0.86)
                    )

                if cell.hasEvent && !cell.isToday {
                    Circle()
                        .fill(NotchWidgetPalette.coral)
                        .frame(width: 2.5, height: 2.5)
                        .offset(y: 1)
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 15)
    }
}

private struct MonthGridModel {
    struct Cell: Identifiable {
        let id: String
        let day: Int?
        let isToday: Bool
        let hasEvent: Bool
    }

    let monthTitle: String
    let todayDay: Int
    let weekdaySymbols: [String]
    let cells: [Cell]

    init(date: Date, snapshot: WidgetCalendarSnapshot) {
        let context = WidgetCalendarContext(snapshot: snapshot)
        let calendar = context.calendar
        let monthComponents = calendar.dateComponents([.year, .month], from: date)
        let firstDay = calendar.date(from: monthComponents) ?? date
        let dayRange = calendar.range(of: .day, in: .month, for: firstDay) ?? 1..<2
        let weekday = calendar.component(.weekday, from: firstDay)
        let leadingCount = (weekday - calendar.firstWeekday + 7) % 7

        monthTitle = Self.monthTitle(
            for: date,
            locale: context.locale,
            timeZone: context.timeZone,
            isChinese: NotchWidgetCopy(
                localizationIdentifier: snapshot.localizationIdentifier
            ).isChinese
        )
        todayDay = calendar.component(.day, from: date)
        weekdaySymbols = Self.weekdaySymbols(calendar: calendar)

        var generatedCells = (0..<leadingCount).map {
            Cell(id: "day-\($0)", day: nil, isToday: false, hasEvent: false)
        }

        for day in dayRange {
            var components = monthComponents
            components.day = day
            let dayDate = calendar.date(from: components) ?? firstDay
            generatedCells.append(
                Cell(
                    id: "day-\(leadingCount + day - 1)",
                    day: day,
                    isToday: calendar.isDate(dayDate, inSameDayAs: date),
                    hasEvent: snapshot.events.contains {
                        $0.occurs(on: dayDate, calendar: calendar)
                    }
                )
            )
        }

        while generatedCells.count < 42 {
            generatedCells.append(
                Cell(
                    id: "day-\(generatedCells.count)",
                    day: nil,
                    isToday: false,
                    hasEvent: false
                )
            )
        }
        cells = generatedCells
    }

    private static func weekdaySymbols(calendar: Calendar) -> [String] {
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        let firstIndex = max(0, min(symbols.count - 1, calendar.firstWeekday - 1))
        return Array(symbols[firstIndex...] + symbols[..<firstIndex])
    }

    private static func monthTitle(
        for date: Date,
        locale: Locale,
        timeZone: TimeZone,
        isChinese: Bool
    ) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.timeZone = timeZone
        formatter.dateFormat = isChinese ? "yyyy年M月" : "MMM yyyy"
        return formatter.string(from: date)
    }
}
