import SwiftUI

struct MonthCalendarView: View {
    @Binding var selectedDate: Date
    let events: [CalendarEvent]
    var alcoveStyle = false
    var workspaceStyle = false
    var workspaceDayHeight: CGFloat = 54
    private var columns: [GridItem] { Array(repeating: GridItem(.flexible(), spacing: workspaceStyle ? 6 : 2), count: 7) }
    @Environment(\.appLanguage) private var appLanguage

    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.locale = appLanguage.locale
        return calendar
    }

    private var dayHeight: CGFloat { workspaceStyle ? workspaceDayHeight : alcoveStyle ? 25 : 24 }

    var body: some View {
        VStack(spacing: workspaceStyle ? 18 : alcoveStyle ? 9 : 7) {
            monthHeader
            LazyVGrid(columns: columns, spacing: workspaceStyle ? 6 : alcoveStyle ? 7 : 5) {
                ForEach(Array(monthGrid.orderedWeekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                    Text(symbol)
                        .font(.system(size: workspaceStyle ? 11 : alcoveStyle ? 10 : 9, weight: .medium))
                        .foregroundStyle(AlcovePalette.secondaryText)
                        .frame(height: workspaceStyle ? 20 : 14)
                }
                ForEach(Array(monthGrid.days.enumerated()), id: \.offset) { _, date in
                    if let date {
                        dayButton(date)
                    } else {
                        Color.clear.frame(height: dayHeight).accessibilityHidden(true)
                    }
                }
            }
        }
        .foregroundStyle(AlcovePalette.primaryText)
    }

    private func dayButton(_ date: Date) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)
        let dateHasEvent = events.contains { $0.occurs(on: date, calendar: calendar) }
        return Button { selectedDate = date } label: {
            VStack(spacing: workspaceStyle ? 4 : 1) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: workspaceStyle ? 16 : alcoveStyle ? 12 : 11,
                                  weight: isSelected || isToday ? .semibold : .regular, design: .rounded))
                    .frame(width: workspaceStyle ? 34 : alcoveStyle ? 24 : 23,
                           height: workspaceStyle ? 34 : alcoveStyle ? 21 : 20)
                    .background(isSelected ? AlcovePalette.accent : .clear, in: Circle())
                    .overlay {
                        Circle().stroke(isToday && !isSelected ? AlcovePalette.accent : .clear, lineWidth: 1)
                    }
                    .foregroundStyle(isSelected ? Color.black : isToday ? AlcovePalette.accent : AlcovePalette.primaryText)
                Circle().fill(dateHasEvent ? AlcovePalette.accent : .clear)
                    .frame(width: workspaceStyle ? 4 : 3, height: workspaceStyle ? 4 : 3)
            }
            .frame(maxWidth: .infinity)
            .frame(height: dayHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(date.formatted(.dateTime.weekday(.wide).month(.wide).day().year().locale(appLanguage.locale)))
        .accessibilityValue(accessibilityValue(hasEvent: dateHasEvent, isSelected: isSelected) + (isToday ? ", " + t("Today") : ""))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var monthTitle: String {
        selectedDate.formatted(.dateTime.month(.wide).year().locale(appLanguage.locale))
    }

    @ViewBuilder private var monthHeader: some View {
        if workspaceStyle {
            HStack(spacing: 8) {
                Text(monthTitle)
                    .font(.system(size: 21, weight: .semibold, design: .rounded))
                    .accessibilityAddTraits(.isHeader)
                Spacer(minLength: 4)
                Button(t("Today")) { selectedDate = Date() }
                    .font(.system(size: 11, weight: .medium))
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                monthButton(systemImage: "chevron.left", label: t("Previous month"), offset: -1)
                monthButton(systemImage: "chevron.right", label: t("Next month"), offset: 1)
            }
        } else {
            HStack(spacing: 5) {
                Spacer(minLength: 0)
                monthButton(systemImage: "chevron.left", label: t("Previous month"), offset: -1)
                Text(monthTitle)
                    .font(.system(size: alcoveStyle ? 11 : 12, weight: .bold, design: .rounded))
                    .foregroundStyle(alcoveStyle ? AlcovePalette.accent : AlcovePalette.primaryText)
                    .frame(minWidth: 112)
                    .accessibilityAddTraits(.isHeader)
                monthButton(systemImage: "chevron.right", label: t("Next month"), offset: 1)
            }
        }
    }

    private var monthGrid: MonthGrid { MonthGrid(monthContaining: selectedDate, calendar: calendar) }

    private func monthButton(systemImage: String, label: String, offset: Int) -> some View {
        Button {
            if let date = monthGrid.date(byAddingMonths: offset) { selectedDate = date }
        } label: {
            Image(systemName: systemImage)
                .font(.system(size: workspaceStyle ? 11 : 9, weight: .semibold))
                .frame(width: workspaceStyle ? 30 : 20, height: workspaceStyle ? 30 : 20)
                .background(Color.white.opacity(0.06), in: Circle())
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(AlcovePalette.secondaryText)
        .accessibilityLabel(label)
        .help(label)
    }

    private func accessibilityValue(hasEvent: Bool, isSelected: Bool) -> String {
        switch (hasEvent, isSelected) {
        case (true, true): t("Selected, has events")
        case (true, false): t("Has events")
        case (false, true): t("Selected, no events")
        case (false, false): t("No events")
        }
    }

    private func t(_ key: String, _ arguments: CVarArg...) -> String { L10n.string(key, language: appLanguage, arguments: arguments) }
}
