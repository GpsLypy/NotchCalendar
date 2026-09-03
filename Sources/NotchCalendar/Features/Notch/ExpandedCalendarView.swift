import AppKit
import SwiftUI

struct ExpandedCalendarView: View {
    @ObservedObject var state: AppState
    let contentTopInset: CGFloat
    @State private var now = Date()
    @State private var dayEvents: [CalendarEvent] = []
    @State private var monthEvents: [CalendarEvent] = []

    var body: some View {
        let status = UpcomingEventEngine.status(now: now, events: state.calendar.todayEvents)
        let featuredEventID = Calendar.current.isDateInToday(state.selectedDate)
            ? featuredEventID(in: status)
            : nil
        let agendaEvents = relevantAgendaEvents(featuredEventID: featuredEventID)
        HStack(alignment: .top, spacing: 28) {
            VStack(alignment: .leading, spacing: 0) {
                header
                if let authorizationMessage = state.calendar.authorizationMessage {
                    permissionCard(authorizationMessage)
                } else {
                    if Calendar.current.isDateInToday(state.selectedDate) {
                        nextCard(status: status)
                    }
                    AgendaView(events: Array(agendaEvents.prefix(2)))
                    if agendaEvents.count > 2 {
                        Text("+ \(agendaEvents.count - 2) later")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(AlcovePalette.accent)
                            .padding(.leading, 22)
                            .padding(.top, 9)
                    }
                }
            }
            .frame(width: 292, alignment: .topLeading)

            MonthCalendarView(
                selectedDate: $state.selectedDate,
                events: monthEvents,
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
        .onReceive(state.calendar.objectWillChange) { _ in
            DispatchQueue.main.async { reloadEvents() }
        }
        .onChange(of: state.selectedDate) { _, _ in reloadEvents() }
        .onAppear(perform: reloadEvents)
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
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.3)
                    .foregroundStyle(color)
                Spacer(minLength: 8)
                if let meetingLink = event.meetingLink {
                    Button { openMeeting(meetingLink) } label: {
                        Label(
                            meetingLink.provider.actionTitle,
                            systemImage: meetingLink.provider.actionSystemImage
                        )
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(color, in: Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Opens the meeting link")
                    .help("\(meetingLink.provider.actionTitle) in your default app")
                } else {
                    Button { openCalendar() } label: {
                        Label("Calendar", systemImage: "calendar")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundStyle(AlcovePalette.secondaryText)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 5)
                            .background(.white.opacity(0.08), in: Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Opens the Calendar app")
                    .help("Open Calendar")
                }
            }
            HStack(spacing: 8) {
                Text(event.title).font(.system(size: 15, weight: .semibold)).lineLimit(1)
                Spacer(minLength: 0)
                if showsProgress {
                    MeetingProgressRing(event: event, now: now)
                }
                Text(suffix)
                    .font(.system(size: 12, design: .monospaced))
                    .monospacedDigit()
                    .foregroundStyle(AlcovePalette.secondaryText)
            }
            if let location = physicalLocation(for: event) {
                Label(location, systemImage: "mappin.and.ellipse")
                    .font(.system(size: 10.5, weight: .medium, design: .rounded))
                    .foregroundStyle(AlcovePalette.secondaryText)
                    .lineLimit(1)
            }
        }
        .padding(12).background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 22).padding(.top, 17)
    }

    private func permissionCard(_ message: String) -> some View {
        Label(message, systemImage: "calendar.badge.exclamationmark")
            .font(.system(size: 12, weight: .medium, design: .rounded))
            .foregroundStyle(AlcovePalette.secondaryText)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 22)
            .padding(.top, 17)
    }

    private func openMeeting(_ meetingLink: MeetingLink) {
        NSWorkspace.shared.open(meetingLink.url)
    }

    private func openCalendar() {
        NSWorkspace.shared.open(URL(string: "ical://")!)
    }

    private func physicalLocation(for event: CalendarEvent) -> String? {
        MeetingLinkResolver.physicalLocation(from: event.location)
    }

    private func featuredEventID(in status: EventStatus) -> String? {
        switch status {
        case let .active(event, _), let .upcoming(event, _): event.id
        case .idle: nil
        }
    }

    private func relevantAgendaEvents(featuredEventID: String?) -> [CalendarEvent] {
        dayEvents.filter { event in
            guard event.id != featuredEventID else { return false }
            guard Calendar.current.isDateInToday(state.selectedDate) else { return true }
            return event.isAllDay || event.endDate > now
        }
    }

    private func reloadEvents() {
        dayEvents = state.calendar.events(for: state.selectedDate)
        monthEvents = state.calendar.events(inMonthContaining: state.selectedDate)
    }
}
