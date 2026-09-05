import AppKit
import SwiftUI

struct TodayWorkspaceView: View {
    @ObservedObject var calendar: CalendarManager
    @ObservedObject var focusTimer: FocusTimerModel
    let isActive: Bool
    let navigate: (WorkspaceDestination) -> Void
    @Environment(\.appLanguage) private var appLanguage
    @Environment(\.openSettings) private var openSettings

    @State private var now = Date()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                pageHeader
                daySignal
                DayPlanningCard(
                    events: calendar.planningEvents,
                    now: now,
                    sourceAvailability: calendar.sourceAvailability,
                    focusTimer: focusTimer,
                    openFocus: { navigate(.focus) },
                    openCalendar: { navigate(.calendar) }
                )
                HStack(alignment: .top, spacing: 18) {
                    schedule
                        .frame(maxWidth: .infinity, alignment: .top)
                    quickTools
                        .frame(width: 228, alignment: .top)
                }
            }
            .padding(.horizontal, 30)
            .padding(.top, 52)
            .padding(.bottom, 30)
        }
        .background(WorkspacePalette.canvas)
        .onReceive(Timer.publish(every: 30, on: .main, in: .common).autoconnect()) { date in
            guard isActive else { return }
            now = date
            focusTimer.synchronize(now: date)
        }
        .onAppear {
            now = Date()
            focusTimer.synchronize(now: now)
        }
    }

    private var pageHeader: some View {
        HStack(alignment: .lastTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text(t("Today"))
                    .font(.system(size: 27, weight: .bold, design: .rounded))
                    .foregroundStyle(WorkspacePalette.primaryText)
                Text(
                    now.formatted(
                        .dateTime.weekday(.wide).month(.wide).day().locale(appLanguage.locale)
                    )
                )
                    .font(.system(size: 12.5, weight: .medium))
                    .foregroundStyle(WorkspacePalette.secondaryText)
            }
            Spacer()
            Text(now.shortTime(locale: appLanguage.locale))
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .monospacedDigit()
                .foregroundStyle(WorkspacePalette.secondaryText)
        }
    }

    private var daySignal: some View {
        WorkspaceCard {
            HStack(alignment: .top, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(signalEyebrow)
                        .font(.system(size: 9.5, weight: .bold))
                        .tracking(1.05)
                        .foregroundStyle(WorkspacePalette.accent)
                    Text(signalTitle)
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundStyle(WorkspacePalette.primaryText)
                        .lineLimit(2)
                    Text(signalDetail)
                        .font(.system(size: 12.5))
                        .foregroundStyle(WorkspacePalette.secondaryText)
                        .lineLimit(2)
                }
                Spacer(minLength: 16)
                signalAction
            }
            .padding(20)
        }
    }

    @ViewBuilder private var signalAction: some View {
        if calendar.authorizationMessage != nil {
            Button(t("Open System Settings")) { calendar.openPrivacySettings() }
                .buttonStyle(.borderedProminent)
                .tint(WorkspacePalette.accent)
        } else if calendar.sourceAvailability != .available {
            Button(t("Calendar Sources")) { openSettings() }
                .buttonStyle(.bordered)
        } else if let meetingLink = featuredEvent?.meetingLink {
            Button {
                NSWorkspace.shared.open(meetingLink.url)
            } label: {
                Label(
                    meetingLink.provider.actionTitle(language: appLanguage),
                    systemImage: meetingLink.provider.actionSystemImage
                )
            }
            .buttonStyle(.borderedProminent)
            .tint(WorkspacePalette.accent)
        } else {
            Button(t("Open Calendar")) { navigate(.calendar) }
                .buttonStyle(.bordered)
        }
    }

    private var schedule: some View {
        WorkspaceCard {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(t("TODAY'S SCHEDULE"))
                        .font(.system(size: 9.5, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(WorkspacePalette.secondaryText)
                    Spacer()
                    Button(t("View calendar")) { navigate(.calendar) }
                        .buttonStyle(.plain)
                        .font(.system(size: 10.5, weight: .semibold))
                        .foregroundStyle(WorkspacePalette.accent)
                }
                .padding(.bottom, 16)

                if let message = calendar.availabilityMessage {
                    Label(t(message), systemImage: "calendar.badge.exclamationmark")
                        .font(.system(size: 12))
                        .foregroundStyle(WorkspacePalette.secondaryText)
                        .padding(.vertical, 18)
                } else if calendar.todayEvents.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(t("Nothing is scheduled."))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(WorkspacePalette.primaryText)
                        Text(t("This is a good window for uninterrupted work."))
                            .font(.system(size: 12))
                            .foregroundStyle(WorkspacePalette.secondaryText)
                        Button(t("Start a focus session")) { navigate(.focus) }
                            .buttonStyle(.plain)
                            .font(.system(size: 11.5, weight: .semibold))
                            .foregroundStyle(WorkspacePalette.accent)
                            .padding(.top, 2)
                    }
                    .padding(.vertical, 18)
                } else {
                    VStack(spacing: 0) {
                        ForEach(Array(displayedScheduleEvents.enumerated()), id: \.element.id) { index, event in
                            TodayEventRow(event: event, now: now)
                            if index < displayedScheduleEvents.count - 1 {
                                Divider().overlay(WorkspacePalette.stroke)
                            }
                        }

                        if calendar.todayEvents.count > displayedScheduleEvents.count {
                            Button(
                                t(
                                    "+ %@ more in Calendar",
                                    "\(calendar.todayEvents.count - displayedScheduleEvents.count)"
                                )
                            ) {
                                navigate(.calendar)
                            }
                            .buttonStyle(.plain)
                            .font(.system(size: 10.5, weight: .semibold))
                            .foregroundStyle(WorkspacePalette.accent)
                            .padding(.top, 12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
            .padding(18)
        }
    }

    private var quickTools: some View {
        VStack(spacing: 12) {
            QuickToolCard(
                eyebrow: focusTimer.isRunning ? t("FOCUS RUNNING") : t("FOCUS"),
                title: focusTimer.isRunning ? focusTimer.timeLabel : t("Make some quiet"),
                detail: focusTimer.isRunning
                    ? t("Your timer keeps running here.")
                    : t("Start a 25-minute session."),
                systemImage: "timer",
                accent: WorkspacePalette.accent
            ) {
                navigate(.focus)
            }

            QuickToolCard(
                eyebrow: t("SCRATCHPAD"),
                title: t("Catch a thought"),
                detail: t("Notes save automatically on this Mac."),
                systemImage: "note.text",
                accent: Color(red: 0.48, green: 0.68, blue: 0.96)
            ) {
                navigate(.scratchpad)
            }
        }
    }

    private var featuredEvent: CalendarEvent? {
        calendar.todayEvents.first { !$0.isAllDay && $0.startDate <= now && $0.endDate > now }
            ?? calendar.todayEvents.first { !$0.isAllDay && $0.startDate > now }
    }

    private var displayedScheduleEvents: [CalendarEvent] {
        let upcoming = calendar.todayEvents.filter { $0.endDate > now }
        let upcomingLimit = Array(upcoming.prefix(5))
        let remainingSlots = max(0, 5 - upcomingLimit.count)
        let recentPast = calendar.todayEvents.filter { $0.endDate <= now }.suffix(remainingSlots)
        return (Array(recentPast) + upcomingLimit).sorted { $0.startDate < $1.startDate }
    }

    private var signalEyebrow: String {
        if calendar.availabilityMessage != nil { return t("CALENDAR") }
        guard let event = featuredEvent else { return t("CLEAR AHEAD") }
        return event.startDate <= now ? t("HAPPENING NOW") : t("UP NEXT")
    }

    private var signalTitle: String {
        if calendar.availabilityMessage != nil { return t("Connect your day") }
        return featuredEvent?.displayTitle(language: appLanguage) ?? t("A clear stretch ahead")
    }

    private var signalDetail: String {
        if let message = calendar.availabilityMessage { return t(message) }
        guard let event = featuredEvent else {
            return t("No timed events remain. Choose what deserves your attention.")
        }
        if event.startDate <= now {
            return event.isAllDay
                ? t("All day")
                : t("Ends at %@", event.endDate.shortTime(locale: appLanguage.locale))
        }
        return event.isAllDay
            ? t("All day")
            : t("Starts at %@", event.startDate.shortTime(locale: appLanguage.locale))
    }

    private func t(_ key: String, _ arguments: CVarArg...) -> String {
        L10n.string(key, language: appLanguage, arguments: arguments)
    }
}

private struct TodayEventRow: View {
    let event: CalendarEvent
    let now: Date
    @Environment(\.appLanguage) private var appLanguage

    var body: some View {
        HStack(spacing: 12) {
            Text(
                event.isAllDay
                    ? L10n.string("ALL", language: appLanguage)
                    : event.startDate.shortTime(locale: appLanguage.locale)
            )
                .font(.system(size: 10.5, weight: .semibold, design: .monospaced))
                .monospacedDigit()
                .foregroundStyle(WorkspacePalette.secondaryText)
                .frame(width: 58, alignment: .leading)

            Capsule()
                .fill(event.calendarColor.map { Color(nsColor: $0) } ?? WorkspacePalette.accent)
                .frame(width: 3, height: 31)

            VStack(alignment: .leading, spacing: 3) {
                Text(event.displayTitle(language: appLanguage))
                    .font(.system(size: 12.5, weight: .semibold))
                    .foregroundStyle(event.endDate <= now ? WorkspacePalette.secondaryText : WorkspacePalette.primaryText)
                    .lineLimit(1)
                Text(event.calendarName)
                    .font(.system(size: 10.5))
                    .foregroundStyle(WorkspacePalette.secondaryText)
                    .lineLimit(1)
            }

            Spacer(minLength: 4)

            if let meetingLink = event.meetingLink, event.endDate > now {
                Button {
                    NSWorkspace.shared.open(meetingLink.url)
                } label: {
                    Image(systemName: meetingLink.provider.actionSystemImage)
                        .font(.system(size: 10, weight: .bold))
                        .frame(width: 26, height: 26)
                        .background(WorkspacePalette.accent.opacity(0.16), in: Circle())
                        .foregroundStyle(WorkspacePalette.accent)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(meetingLink.provider.actionTitle(language: appLanguage))
                .help(meetingLink.provider.actionTitle(language: appLanguage))
            }
        }
        .padding(.vertical, 10)
    }
}

private struct QuickToolCard: View {
    let eyebrow: String
    let title: String
    let detail: String
    let systemImage: String
    let accent: Color
    let action: () -> Void
    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: systemImage)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(accent)
                        .frame(width: 28, height: 28)
                        .background(accent.opacity(0.13), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(WorkspacePalette.secondaryText)
                }
                Text(eyebrow)
                    .font(.system(size: 9, weight: .bold))
                    .tracking(0.9)
                    .foregroundStyle(accent)
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(WorkspacePalette.primaryText)
                Text(detail)
                    .font(.system(size: 10.5))
                    .foregroundStyle(WorkspacePalette.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                isHovering ? WorkspacePalette.elevated.opacity(1.35) : WorkspacePalette.elevated,
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isHovering ? accent.opacity(0.30) : WorkspacePalette.stroke, lineWidth: 1)
            }
            .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
    }
}
