import AppKit
import SwiftUI

struct ExpandedCalendarView: View {
    @ObservedObject var state: AppState
    let contentTopInset: CGFloat

    var body: some View {
        NotchExpandedActivityView(
            calendar: state.calendar, focusTimer: state.focusTimer,
            preferences: state.presentationPreferences, selectedDate: $state.selectedDate,
            contentTopInset: contentTopInset,
            onClose: { state.isExpanded = false },
            openFocus: { state.openWorkspace?(.focus) }
        )
    }
}

struct NotchExpandedActivityView: View {
    @ObservedObject var calendar: CalendarManager
    @ObservedObject var focusTimer: FocusTimerModel
    @ObservedObject var preferences: PresentationPreferences
    @Binding var selectedDate: Date
    let contentTopInset: CGFloat
    let onClose: () -> Void
    let openFocus: () -> Void
    @State private var activity: NotchActivity = .calendar
    @Environment(\.appLanguage) private var appLanguage

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                activityButton(.calendar, title: "Calendar", symbol: "calendar")
                activityButton(.focus, title: "Focus", symbol: "timer")
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark").font(.system(size: 10, weight: .semibold))
                        .frame(width: 26, height: 26)
                        .background(.white.opacity(0.08), in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(L10n.string("Close", language: appLanguage))
                .keyboardShortcut(.cancelAction)
            }
            .padding(.horizontal, 28)
            .padding(.top, contentTopInset)
            if activity == .focus {
                FocusNotchView(timer: focusTimer, events: calendar.todayEvents,
                               openFocus: openFocus)
            } else {
                CalendarDashboardView(
                    calendar: calendar,
                    selectedDate: $selectedDate,
                    contentTopInset: 16,
                    surface: .notch,
                    isActive: true,
                    onClose: nil
                )
            }
        }
        .foregroundStyle(WorkspacePalette.primaryText)
        .background(.black.opacity(0.97), in: NotchAttachedCardShape(cornerRadius: 30))
        .clipShape(NotchAttachedCardShape(cornerRadius: 30))
        .onAppear {
            focusTimer.synchronize()
            activity = NotchActivityPolicy.compactActivity(
                showsMeetings: preferences.showsMeetingStatus,
                meetingIsActive: UpcomingEventEngine.status(now: Date(), events: calendar.todayEvents).isActive,
                showsFocus: preferences.showsFocusStatus,
                hasFocusSession: focusTimer.hasNotchActivity
            )
        }
    }

    private func activityButton(_ destination: NotchActivity, title: String, symbol: String) -> some View {
        Button { activity = destination } label: {
            Label(L10n.string(title, language: appLanguage), systemImage: symbol)
                .font(.system(size: 11, weight: .semibold))
                .padding(.horizontal, 12).padding(.vertical, 7)
                .background(activity == destination ? WorkspacePalette.accent.opacity(0.18) : .clear, in: Capsule())
                .foregroundStyle(activity == destination ? WorkspacePalette.accent : WorkspacePalette.secondaryText)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(activity == destination ? .isSelected : [])
        .keyboardShortcut(destination == .calendar ? "1" : "2", modifiers: .command)
    }
}

enum CalendarDashboardSurface {
    case notch
    case window
}

struct CalendarDashboardView: View {
    @ObservedObject var calendar: CalendarManager
    @Binding var selectedDate: Date
    let contentTopInset: CGFloat
    let surface: CalendarDashboardSurface
    let isActive: Bool
    let onClose: (() -> Void)?
    @State private var now = Date()
    @State private var dayEvents: [CalendarEvent] = []
    @State private var monthEvents: [CalendarEvent] = []
    @State private var reloadTask: Task<Void, Never>?
    @Environment(\.appLanguage) private var appLanguage
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        let status = UpcomingEventEngine.status(now: now, events: calendar.todayEvents)
        let featuredEventID = Calendar.current.isDateInToday(selectedDate)
            ? featuredEventID(in: status)
            : nil
        let agendaEvents = relevantAgendaEvents(featuredEventID: featuredEventID)
        HStack(alignment: .top, spacing: 28) {
            VStack(alignment: .leading, spacing: 0) {
                header
                if let authorizationMessage = calendar.authorizationMessage {
                    permissionCard(authorizationMessage)
                } else if let message = calendar.availabilityMessage {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(t(message))
                            .font(.system(size: 12))
                            .foregroundStyle(AlcovePalette.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                        Button(t("Calendar Sources")) { openSettings() }
                            .buttonStyle(.bordered)
                    }
                    .padding(22)
                } else {
                    if Calendar.current.isDateInToday(selectedDate) {
                        nextCard(status: status)
                    }
                    AgendaView(events: Array(agendaEvents.prefix(2)))
                    if agendaEvents.count > 2 {
                        Text(t("+ %@ later", "\(agendaEvents.count - 2)"))
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(AlcovePalette.accent)
                            .padding(.leading, 22)
                            .padding(.top, 9)
                    }
                }
            }
            .frame(width: 292, alignment: .topLeading)

            MonthCalendarView(
                selectedDate: $selectedDate,
                events: monthEvents,
                alcoveStyle: true
            )
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .padding(.top, contentTopInset)
        .padding(.horizontal, 28)
        .padding(.bottom, 24)
        .foregroundStyle(.white)
        .background { dashboardBackground }
        .onActivityClock(every: isActive ? ActivityClockPolicy.compactInterval(
            now: now, events: calendar.todayEvents, showsMeetings: true,
            displaysUpcoming: true, visibleFocusRunning: false
        ) : nil) { newNow in
            guard isActive else { return }
            advanceClock(to: newNow)
        }
        .onReceive(calendar.objectWillChange) { _ in
            guard isActive else { return }
            scheduleReloadEvents()
        }
        .onChange(of: selectedDate) { _, _ in
            guard isActive else { return }
            scheduleReloadEvents()
        }
        .onChange(of: isActive) { _, active in
            reloadTask?.cancel()
            guard active else { return }
            if !advanceClock(to: Date()) {
                scheduleReloadEvents()
            }
        }
        .onAppear {
            guard isActive else { return }
            if !advanceClock(to: Date()) {
                scheduleReloadEvents()
            }
        }
        .onDisappear { reloadTask?.cancel() }
    }

    @ViewBuilder private var dashboardBackground: some View {
        switch surface {
        case .notch:
            Color.black.opacity(0.97)
                .clipShape(NotchAttachedCardShape(cornerRadius: 30))
        case .window:
            WorkspacePalette.canvas
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 3) {
                Text(selectedDate.formatted(.dateTime.weekday(.wide).locale(appLanguage.locale)))
                    .font(.system(size: 23, weight: .bold, design: .rounded))
                Text(selectedDate.formatted(.dateTime.year().month().day().locale(appLanguage.locale)))
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(AlcovePalette.secondaryText)
            }
            Spacer(minLength: 8)
            Button(t("Today")) { selectedDate = Date() }
                .buttonStyle(.plain)
                .foregroundStyle(AlcovePalette.accent)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .padding(.top, 4)
            if let onClose {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .frame(width: 24, height: 24)
                        .background(.white.opacity(0.12), in: Circle())
                }
                .buttonStyle(.plain)
                .padding(.leading, 8)
                .accessibilityLabel(t("Close"))
                .help(t("Close"))
            }
        }
        .padding(.horizontal, 22)
    }

    @ViewBuilder private func nextCard(status: EventStatus) -> some View {
        switch status {
        case let .active(event, secondsRemaining):
            eventCard(
                t("NOW"),
                event,
                t("%@ left", UpcomingEventEngine.countdown(secondsRemaining)),
                AlcovePalette.accent,
                showsProgress: true
            )
        case let .upcoming(event, secondsUntilStart):
            eventCard(
                t("NEXT"),
                event,
                t("in %@", UpcomingEventEngine.countdown(secondsUntilStart)),
                AlcovePalette.accent
            )
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
                            meetingLink.provider.actionTitle(language: appLanguage),
                            systemImage: meetingLink.provider.actionSystemImage
                        )
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(color, in: Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint(t("Opens the meeting link"))
                    .help(
                        t(
                            "%@ in your default app",
                            meetingLink.provider.actionTitle(language: appLanguage)
                        )
                    )
                } else {
                    Button { openCalendar() } label: {
                        Label(t("Calendar"), systemImage: "calendar")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundStyle(AlcovePalette.secondaryText)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 5)
                            .background(.white.opacity(0.08), in: Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint(t("Opens the Calendar app"))
                    .help(t("Open Calendar"))
                }
            }
            HStack(spacing: 8) {
                Text(event.displayTitle(language: appLanguage))
                    .font(.system(size: 15, weight: .semibold))
                    .lineLimit(1)
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
        VStack(alignment: .leading, spacing: 9) {
            Label(t(message), systemImage: "calendar.badge.exclamationmark")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(AlcovePalette.secondaryText)
            Button(t("Open System Settings")) {
                calendar.openPrivacySettings()
            }
            .buttonStyle(.plain)
            .font(.system(size: 11, weight: .semibold, design: .rounded))
            .foregroundStyle(AlcovePalette.accent)
        }
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
            guard Calendar.current.isDateInToday(selectedDate) else { return true }
            return event.isAllDay || event.endDate > now
        }
    }

    private func reloadEvents() {
        dayEvents = calendar.events(for: selectedDate)
        monthEvents = calendar.events(inMonthContaining: selectedDate)
    }

    private func scheduleReloadEvents() {
        reloadTask?.cancel()
        reloadTask = Task { @MainActor in
            await Task.yield()
            guard !Task.isCancelled else { return }
            reloadEvents()
        }
    }

    @discardableResult
    private func advanceClock(to newNow: Date) -> Bool {
        let calendar = Calendar.current
        let wasFollowingToday = calendar.isDate(selectedDate, inSameDayAs: now)
        let crossedDayBoundary = !calendar.isDate(now, inSameDayAs: newNow)
        now = newNow
        if wasFollowingToday, crossedDayBoundary {
            selectedDate = newNow
            return true
        }
        return false
    }

    private func t(_ key: String, _ arguments: CVarArg...) -> String {
        L10n.string(key, language: appLanguage, arguments: arguments)
    }
}
