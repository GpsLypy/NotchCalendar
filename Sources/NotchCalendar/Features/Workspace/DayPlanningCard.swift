import SwiftUI

/// The daily timeline is the visual anchor: coral is occupied time, green is
/// available time. Actions remain explicit and never start a timer on their own.
struct DayPlanningCard: View {
    let events: [CalendarEvent]
    let now: Date
    let sourceAvailability: CalendarSourceAvailability
    @ObservedObject var focusTimer: FocusTimerModel
    let openFocus: () -> Void
    let openCalendar: () -> Void
    @Environment(\.appLanguage) private var appLanguage
    @Environment(\.openSettings) private var openSettings
    @AppStorage(DayPlanSettings.startHourKey) private var startHour = 9
    @AppStorage(DayPlanSettings.endHourKey) private var endHour = 18
    @AppStorage(DayPlanSettings.bufferMinutesKey) private var bufferMinutes = 5
    @State private var showsSettings = false
    @State private var showsAllWindows = false
    @State private var latestActionDate: Date?
    @State private var actionFeedback: String?

    private var planningNow: Date { max(now, latestActionDate ?? now) }

    private var settings: DayPlanSettings {
        DayPlanSettings(startHour: startHour, endHour: endHour, bufferMinutes: bufferMinutes)
    }

    var body: some View {
        let plan = DayPlanEngine.makePlan(events: events, now: planningNow, settings: settings)
        WorkspaceCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .firstTextBaseline) {
                    Text(t("TIME TO FOCUS"))
                        .font(.system(size: 9.5, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(WorkspacePalette.secondaryText)
                    Spacer()
                    Button { showsSettings.toggle() } label: {
                        Label(t("Planning hours"), systemImage: "slider.horizontal.3")
                            .font(.system(size: 10.5, weight: .medium))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(WorkspacePalette.secondaryText)
                    .accessibilityValue(showsSettings ? t("Expanded") : t("Collapsed"))
                }

                if showsSettings { planningSettings }

                if sourceAvailability == .needsPermission {
                    unavailableState(
                        title: "Connect calendars to find time for focus.",
                        detail: "Availability needs Calendar access. You can still use the timer."
                    )
                } else if sourceAvailability == .noCalendars {
                    unavailableState(
                        title: "No calendars to plan with yet.",
                        detail: "Add an account or calendar in the Calendar app, then refresh Calendars in Settings."
                    )
                } else if sourceAvailability == .noneSelected {
                    unavailableState(
                        title: "Choose calendars before planning.",
                        detail: "Select the calendars that should count toward your day in Settings."
                    )
                } else {
                    planContent(plan)
                }
                if let actionFeedback {
                    Text(t(actionFeedback))
                        .font(.system(size: 11))
                        .foregroundStyle(WorkspacePalette.accent)
                }
            }
            .padding(18)
        }
        .onChange(of: now) { _, _ in actionFeedback = nil }
    }

    private func planContent(_ plan: DayPlan) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text(t("%@ min available", "\(plan.availableMinutes)"))
                    .font(.system(size: 21, weight: .semibold, design: .rounded))
                    .foregroundStyle(WorkspacePalette.primaryText)
                Spacer()
                Text(timeRange(plan.window))
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(WorkspacePalette.secondaryText)
            }
            timeline(plan)
            Text(t("Selected calendars · %@ min before and after events", "\(settings.bufferMinutes)"))
                .font(.system(size: 10.5))
                .foregroundStyle(WorkspacePalette.secondaryText)
                .fixedSize(horizontal: false, vertical: true)

            let windows = plan.freeIntervals.filter { $0.minutes >= 5 }
            if windows.isEmpty {
                Text(t(planningNow >= plan.window.end
                       ? "Today's planning window has ended. Adjust your hours or plan again tomorrow."
                       : "No 5-minute opening remains in this window. Try a shorter buffer or different hours."))
                    .font(.system(size: 12))
                    .foregroundStyle(WorkspacePalette.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                VStack(spacing: 10) {
                    ForEach(showsAllWindows ? windows : Array(windows.prefix(3))) { interval in
                        freeWindowRow(interval, plan: plan)
                    }
                    if windows.count > 3 {
                        Button(showsAllWindows ? t("Show fewer openings") : t("Show all %@ openings", "\(windows.count)")) {
                            showsAllWindows.toggle()
                        }
                        .buttonStyle(.plain)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(WorkspacePalette.accent)
                    }
                }
            }

            if !plan.conflicts.isEmpty { conflictList(plan.conflicts) }

            if plan.allDayEventCount > 0 {
                Label(t("All-day events stay in your agenda; they do not block these openings."), systemImage: "info.circle")
                    .font(.system(size: 10.5))
                    .foregroundStyle(WorkspacePalette.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func freeWindowRow(_ interval: DayPlanInterval, plan: DayPlan) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 12) {
                freeWindowLabel(interval)
                Spacer(minLength: 8)
                focusAction(interval, plan: plan)
            }
            VStack(alignment: .leading, spacing: 8) {
                freeWindowLabel(interval)
                focusAction(interval, plan: plan)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(WorkspacePalette.success.opacity(0.06), in: RoundedRectangle(cornerRadius: 9))
    }

    private func freeWindowLabel(_ interval: DayPlanInterval) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(interval.start <= planningNow ? t("Available now") : timeRange(interval))
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(WorkspacePalette.primaryText)
            Text(interval.start <= planningNow
                 ? t("%@ min · until %@", "\(interval.minutes)", interval.end.shortTime(locale: appLanguage.locale))
                 : t("%@ min opening", "\(interval.minutes)"))
                .font(.system(size: 10.5, design: .monospaced))
                .foregroundStyle(WorkspacePalette.secondaryText)
        }
        .fixedSize(horizontal: true, vertical: false)
    }

    @ViewBuilder private func focusAction(_ interval: DayPlanInterval, plan: DayPlan) -> some View {
        if interval.start <= planningNow, let minutes = plan.recommendedFocusMinutes(at: planningNow) {
            if focusTimer.hasUnfinishedSession {
                Button(t("Return to timer"), action: openFocus)
                    .buttonStyle(.bordered)
                    .controlSize(.small)
            } else {
                Button(t("Prepare %@ min focus", "\(minutes)")) {
                    let current = Date()
                    latestActionDate = current
                    if focusTimer.hasUnfinishedSession { openFocus(); return }
                    let refreshed = DayPlanEngine.makePlan(events: events, now: current, settings: settings)
                    if let duration = refreshed.recommendedFocusMinutes(at: current),
                       focusTimer.prepareFocus(minutes: duration) {
                        openFocus()
                    } else {
                        actionFeedback = "The available time changed. Review the updated openings."
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(WorkspacePalette.accent)
                .controlSize(.small)
                .help(t("Sets the timer duration. Press Start in Focus when you are ready."))
            }
        } else {
            Text(t("Later today"))
                .font(.system(size: 10.5))
                .foregroundStyle(WorkspacePalette.secondaryText)
        }
    }

    private func timeline(_ plan: DayPlan) -> some View {
        GeometryReader { geometry in
            let duration = max(1, plan.window.end.timeIntervalSince(plan.window.start))
            let fraction = min(1, max(0, planningNow.timeIntervalSince(plan.window.start) / duration))
            ZStack(alignment: .leading) {
                Capsule().fill(WorkspacePalette.success.opacity(0.28))
                ForEach(plan.busyIntervals) { interval in
                    Rectangle()
                        .fill(WorkspacePalette.accent.opacity(0.65))
                        .frame(width: max(1, geometry.size.width * interval.end.timeIntervalSince(interval.start) / duration))
                        .offset(x: geometry.size.width * interval.start.timeIntervalSince(plan.window.start) / duration)
                }
                Rectangle()
                    .fill(WorkspacePalette.canvas.opacity(0.7))
                    .frame(width: geometry.size.width * fraction)
                if planningNow >= plan.window.start && planningNow < plan.window.end {
                    Rectangle().fill(WorkspacePalette.primaryText).frame(width: 2)
                        .offset(x: geometry.size.width * fraction)
                }
            }
            .clipShape(Capsule())
        }
        .frame(height: 8)
        .accessibilityLabel(t("Planning timeline: %@ minutes available", "\(plan.availableMinutes)"))
    }

    private func conflictList(_ conflicts: [DayPlanConflict]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider().overlay(WorkspacePalette.stroke)
            HStack {
                Label(t("Overlapping events"), systemImage: "exclamationmark.triangle")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(WorkspacePalette.accent)
                Spacer()
                Button(t("View calendar"), action: openCalendar)
                    .buttonStyle(.plain)
                    .font(.system(size: 10.5, weight: .medium))
                    .foregroundStyle(WorkspacePalette.accent)
            }
            ForEach(conflicts) { conflict in
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(Array(conflict.events.enumerated()), id: \.offset) { _, event in
                        Text("\(event.startDate.shortTime(locale: appLanguage.locale))–\(event.endDate.shortTime(locale: appLanguage.locale))  \(event.displayTitle(language: appLanguage)) · \(event.calendarName)")
                            .font(.system(size: 11))
                            .foregroundStyle(WorkspacePalette.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    private var planningSettings: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 14) {
                Picker(t("From"), selection: Binding(
                    get: { settings.startHour },
                    set: { startHour = $0; if endHour <= $0 { endHour = $0 + 1 } }
                )) {
                    ForEach(0..<24) { hour in Text(hourLabel(hour)).tag(hour) }
                }
                Picker(t("Until"), selection: Binding(
                    get: { settings.endHour },
                    set: { endHour = $0 }
                )) {
                    ForEach((settings.startHour + 1)..<25, id: \.self) { hour in Text(hourLabel(hour)).tag(hour) }
                }
            }
            Picker(t("Meeting buffer"), selection: $bufferMinutes) {
                ForEach([0, 5, 10, 15, 30], id: \.self) { minutes in
                    Text(t("%@ min", "\(minutes)")).tag(minutes)
                }
            }
            Text(t("Applies to today's planning window, in your Mac's time zone. Does not change calendar events."))
                .font(.system(size: 10.5))
                .foregroundStyle(WorkspacePalette.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .pickerStyle(.menu)
        .controlSize(.small)
        .foregroundStyle(WorkspacePalette.primaryText)
    }

    private func unavailableState(title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(t(title)).font(.system(size: 14, weight: .semibold))
                .foregroundStyle(WorkspacePalette.primaryText)
            Text(t(detail)).font(.system(size: 12))
                .foregroundStyle(WorkspacePalette.secondaryText)
            Button(t("Settings")) { openSettings() }.controlSize(.small)
        }
    }

    private func timeRange(_ interval: DayPlanInterval) -> String {
        "\(interval.start.shortTime(locale: appLanguage.locale))–\(interval.end.shortTime(locale: appLanguage.locale))"
    }

    private func hourLabel(_ hour: Int) -> String {
        if hour == 24 { return "24:00" }
        return String(format: "%02d:00", hour)
    }

    private func t(_ key: String, _ arguments: CVarArg...) -> String {
        L10n.string(key, language: appLanguage, arguments: arguments)
    }
}
