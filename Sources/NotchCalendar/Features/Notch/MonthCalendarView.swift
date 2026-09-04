import SwiftUI

struct MonthCalendarView: View {
    @Binding var selectedDate: Date
    let events: [CalendarEvent]
    var alcoveStyle = false
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)
    @Environment(\.appLanguage) private var appLanguage

    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.locale = appLanguage.locale
        return calendar
    }

    var body: some View {
        VStack(spacing: alcoveStyle ? 9 : 7) {
            monthHeader
            LazyVGrid(columns: columns, spacing: alcoveStyle ? 7 : 5) {
                ForEach(Array(monthGrid.orderedWeekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                    Text(symbol)
                        .font(.system(size: alcoveStyle ? 10 : 9, weight: .bold, design: .rounded))
                        .foregroundStyle(AlcovePalette.secondaryText)
                }
                ForEach(Array(monthGrid.days.enumerated()), id: \.offset) { _, date in
                    if let date {
                        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                        let dateHasEvent = hasEvent(date)
                        Button { selectedDate = date } label: {
                            VStack(spacing: 1) {
                                Text("\(calendar.component(.day, from: date))")
                                    .font(.system(size: alcoveStyle ? 12 : 11, weight: isSelected ? .bold : .regular, design: .rounded))
                                    .frame(width: alcoveStyle ? 24 : 23, height: alcoveStyle ? 21 : 20)
                                    .background(isSelected ? AlcovePalette.accent : .clear, in: Circle())
                                    .foregroundStyle(isSelected ? .black : .white)
                                Circle().fill(dateHasEvent ? AlcovePalette.accent : .clear).frame(width: 3, height: 3)
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(
                            date.formatted(
                                .dateTime
                                    .weekday(.wide)
                                    .month(.wide)
                                    .day()
                                    .year()
                                    .locale(appLanguage.locale)
                            )
                        )
                        .accessibilityValue(accessibilityValue(hasEvent: dateHasEvent, isSelected: isSelected))
                    } else {
                        Color.clear.frame(height: alcoveStyle ? 25 : 24)
                    }
                }
            }
        }
    }

    private var monthHeader: some View {
        HStack(spacing: 5) {
            Spacer(minLength: 0)
            monthButton(systemImage: "chevron.left", label: t("Previous month"), offset: -1)
            Text(selectedDate.formatted(.dateTime.month(.wide).year().locale(appLanguage.locale)))
                .font(.system(size: alcoveStyle ? 11 : 12, weight: .bold, design: .rounded))
                .foregroundStyle(alcoveStyle ? AlcovePalette.accent : .primary)
                .frame(minWidth: 112)
                .accessibilityAddTraits(.isHeader)
            monthButton(systemImage: "chevron.right", label: t("Next month"), offset: 1)
        }
    }

    private var monthGrid: MonthGrid {
        MonthGrid(monthContaining: selectedDate, calendar: calendar)
    }

    private func monthButton(systemImage: String, label: String, offset: Int) -> some View {
        Button {
            if let date = monthGrid.date(byAddingMonths: offset) {
                selectedDate = date
            }
        } label: {
            Image(systemName: systemImage)
                .font(.system(size: 9, weight: .bold))
                .frame(width: 20, height: 20)
                .background(
                    (alcoveStyle ? Color.white : Color.primary).opacity(0.08),
                    in: Circle()
                )
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(alcoveStyle ? AlcovePalette.secondaryText : .secondary)
        .accessibilityLabel(label)
        .help(label)
    }

    private func hasEvent(_ date: Date) -> Bool { events.contains { $0.occurs(on: date, calendar: calendar) } }

    private func accessibilityValue(hasEvent: Bool, isSelected: Bool) -> String {
        switch (hasEvent, isSelected) {
        case (true, true): t("Selected, has events")
        case (true, false): t("Has events")
        case (false, true): t("Selected, no events")
        case (false, false): t("No events")
        }
    }

    private func t(_ key: String, _ arguments: CVarArg...) -> String {
        L10n.string(key, language: appLanguage, arguments: arguments)
    }
}
