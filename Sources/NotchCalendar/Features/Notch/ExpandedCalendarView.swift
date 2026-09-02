import SwiftUI

struct ExpandedCalendarView: View {
    @ObservedObject var state: AppState
    let contentTopInset: CGFloat
    @State private var now = Date()

    var body: some View {
        let dayEvents = state.calendar.events(for: state.selectedDate)
        HStack(alignment: .top, spacing: 28) {
            VStack(alignment: .leading, spacing: 0) {
                header
                if Calendar.current.isDateInToday(state.selectedDate) {
                    nextCard(status: UpcomingEventEngine.status(now: now, events: state.calendar.todayEvents))
                }
                AgendaView(events: Array(dayEvents.prefix(2)))
                if dayEvents.count > 2 {
                    Text("+ \(dayEvents.count - 2) more events")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(AlcovePalette.accent)
                        .padding(.leading, 22)
                        .padding(.top, 9)
                }
            }
            .frame(width: 292, alignment: .topLeading)

            MonthCalendarView(
                selectedDate: $state.selectedDate,
                events: state.calendar.events(inMonthContaining: state.selectedDate),
                alcoveStyle: true
            )
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .padding(.top, contentTopInset)
        .padding(.horizontal, 28)
        .padding(.bottom, 24)
        .foregroundStyle(.white)
        .background(.black.opacity(0.97), in: NotchAttachedCardShape(cornerRadius: 30))
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { now = $0 }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 3) {
                Text(state.selectedDate.formatted(.dateTime.weekday(.wide)))
                    .font(.system(size: 23, weight: .bold, design: .rounded))
                Text(state.selectedDate.formatted(.dateTime.year().month().day()))
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(AlcovePalette.secondaryText)
            }
            Spacer(minLength: 8)
            Button("Today") { state.selectedDate = Date() }
                .buttonStyle(.plain)
                .foregroundStyle(AlcovePalette.accent)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .padding(.top, 4)
            Button {
                state.isExpanded = false
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .frame(width: 24, height: 24)
                    .background(.white.opacity(0.12), in: Circle())
            }
            .buttonStyle(.plain)
            .padding(.leading, 8)
        }
        .padding(.horizontal, 22)
    }

    @ViewBuilder private func nextCard(status: EventStatus) -> some View {
        switch status {
        case let .active(event, secondsRemaining):
            eventCard(
                "NOW",
                event,
                "\(UpcomingEventEngine.countdown(secondsRemaining)) left",
                AlcovePalette.accent,
                showsProgress: true
            )
        case let .upcoming(event, secondsUntilStart):
            eventCard("NEXT", event, "in \(UpcomingEventEngine.countdown(secondsUntilStart))", AlcovePalette.accent)
        case .idle: EmptyView()
        }
    }

    private func eventCard(
        _ title: String,
        _ event: CalendarEvent,
        _ suffix: String,
        _ color: Color,
        showsProgress: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title).font(.system(size: 10, weight: .bold)).tracking(1.3).foregroundStyle(color)
            HStack {
                Text(event.title).font(.system(size: 15, weight: .semibold)).lineLimit(1)
                Spacer()
                if showsProgress {
                    MeetingProgressRing(event: event, now: now)
                }
                Text(suffix)
                    .font(.system(size: 12, design: .monospaced))
                    .monospacedDigit()
                    .foregroundStyle(AlcovePalette.secondaryText)
            }
        }
        .padding(12).background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 22).padding(.top, 17)
    }
}
