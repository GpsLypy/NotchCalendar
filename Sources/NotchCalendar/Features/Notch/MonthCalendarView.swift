import SwiftUI

struct MonthCalendarView: View {
    @Binding var selectedDate: Date
    let events: [CalendarEvent]
    var alcoveStyle = false
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)

    var body: some View {
        VStack(spacing: alcoveStyle ? 9 : 7) {
            Text(selectedDate.formatted(.dateTime.month(.wide).year()))
                .font(.system(size: alcoveStyle ? 11 : 12, weight: .bold, design: .rounded))
                .foregroundStyle(alcoveStyle ? AlcovePalette.accent : .primary)
                .frame(maxWidth: .infinity, alignment: alcoveStyle ? .trailing : .leading)
            LazyVGrid(columns: columns, spacing: alcoveStyle ? 7 : 5) {
                ForEach(calendar.weekdaySymbols, id: \.self) { symbol in
                    Text(alcoveStyle ? String(symbol.suffix(1)) : symbol)
                        .font(.system(size: alcoveStyle ? 10 : 9, weight: .bold, design: .rounded))
                        .foregroundStyle(AlcovePalette.secondaryText)
                }
                ForEach(Array(days.enumerated()), id: \.offset) { _, date in
                    if let date {
                        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                        Button { selectedDate = date } label: {
                            VStack(spacing: 1) {
                                Text("\(calendar.component(.day, from: date))")
                                    .font(.system(size: alcoveStyle ? 12 : 11, weight: isSelected ? .bold : .regular, design: .rounded))
                                    .frame(width: alcoveStyle ? 24 : 23, height: alcoveStyle ? 21 : 20)
                                    .background(isSelected ? AlcovePalette.accent : .clear, in: Circle())
                                    .foregroundStyle(isSelected ? .black : .white)
                                Circle().fill(hasEvent(date) ? AlcovePalette.accent : .clear).frame(width: 3, height: 3)
                            }
                        }
                        .buttonStyle(.plain)
                    } else {
                        Color.clear.frame(height: alcoveStyle ? 25 : 24)
                    }
                }
            }
        }
    }

    private var days: [Date?] {
        let month = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))!
        let count = calendar.range(of: .day, in: .month, for: month)!.count
        let offset = (calendar.component(.weekday, from: month) - calendar.firstWeekday + 7) % 7
        return Array(repeating: nil, count: offset) + (0..<count).map { calendar.date(byAdding: .day, value: $0, to: month) }
    }

    private func hasEvent(_ date: Date) -> Bool { events.contains { calendar.isDate($0.startDate, inSameDayAs: date) } }
}
