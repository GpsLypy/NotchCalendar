import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct FocusWorkspaceView: View {
    @ObservedObject var timer: FocusTimerModel
    @ObservedObject var calendar: CalendarManager
    let now: Date
    @Environment(\.appLanguage) private var appLanguage
    @Environment(\.openSettings) private var openSettings
    @AppStorage(DayPlanSettings.startHourKey) private var planningStartHour = 9
    @AppStorage(DayPlanSettings.endHourKey) private var planningEndHour = 18
    @AppStorage(DayPlanSettings.bufferMinutesKey) private var planningBufferMinutes = 5
    @State private var customMinutes = "30"
    @State private var durationError: String?
    @State private var exportError: String?
    @State private var exportConfirmation: String?
    @State private var recommendationFeedback: String?
    @State private var taskDraft = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                pageHeader
                if let error = timer.persistenceError {
                    VStack(alignment: .leading, spacing: 8) {
                        Label(t(error), systemImage: "exclamationmark.triangle").foregroundStyle(.orange)
                        Button(t("Open Settings")) { openSettings() }
                    }.font(.system(size: 12))
                }
                HStack(alignment: .top, spacing: 18) {
                    timerCard
                        .disabled(timer.persistenceError != nil)
                        .frame(maxWidth: .infinity, alignment: .top)
                    contextColumn
                        .frame(width: 230, alignment: .top)
                }
                historyCard
                FocusWeeklyReviewView(records: timer.history, now: now)
            }
            .padding(.horizontal, 30)
            .padding(.top, 52)
            .padding(.bottom, 30)
        }
        .background(WorkspacePalette.canvas)
        .onAppear { taskDraft = timer.taskLabel }
        .onChange(of: taskDraft) { _, value in timer.setTaskLabel(value) }
        .onChange(of: timer.taskLabel) { _, value in
            if taskDraft != value { taskDraft = value }
        }
    }

    private var pageHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(t("Focus"))
                .font(.system(size: 27, weight: .bold, design: .rounded))
                .foregroundStyle(WorkspacePalette.primaryText)
            Text(t("Give one thing a protected stretch of time."))
                .font(.system(size: 12.5, weight: .medium))
                .foregroundStyle(WorkspacePalette.secondaryText)
        }
    }

    private var timerCard: some View {
        WorkspaceCard {
            VStack(spacing: 0) {
                HStack {
                    Label(sessionTitle, systemImage: "timer")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(0.8)
                        .foregroundStyle(WorkspacePalette.accent)
                    Spacer()
                    Text(
                        timer.isRunning
                            ? t("IN PROGRESS")
                            : timer.remainingSeconds == 0 ? t("COMPLETE") : timer.hasUnfinishedSession ? t("PAUSED") : t("READY")
                    )
                        .font(.system(size: 9, weight: .bold))
                        .tracking(0.8)
                        .foregroundStyle(WorkspacePalette.secondaryText)
                }

                TextField(t("Task label (optional)"), text: $taskDraft)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 12))
                    .disabled(timer.selectedKind == .breakTime)
                    .accessibilityLabel(t("Task label"))
                    .padding(.top, 18)

                Spacer(minLength: 38)

                Text(timer.timeLabel)
                    .font(.system(size: 68, weight: .medium, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(WorkspacePalette.primaryText)
                    .contentTransition(.numericText(countsDown: true))
                    .accessibilityLabel(
                        t(
                            "%@ minutes %@ seconds remaining",
                            "\(timer.remainingSeconds / 60)",
                            "\(timer.remainingSeconds % 60)"
                        )
                    )

                Text(
                    timer.isRunning
                        ? timer.selectedKind == .breakTime ? t("Step away, breathe, and return with a clean slate.") : t("Stay with the work in front of you.")
                        : timer.remainingSeconds == 0
                            ? t("Session complete. Reset when you are ready.")
                            : sessionDescription
                )
                    .font(.system(size: 12.5))
                    .foregroundStyle(WorkspacePalette.secondaryText)
                    .padding(.top, 8)

                Spacer(minLength: 38)

                progressBar
                    .padding(.bottom, 24)

                HStack(spacing: 8) {
                    ForEach(FocusTimerModel.presets, id: \.self) { minutes in
                        FocusPresetButton(
                            minutes: minutes,
                            isSelected: timer.selectedMinutes == minutes && timer.selectedKind == (minutes == 5 ? .breakTime : .focus)
                        ) {
                            timer.select(minutes: minutes)
                        }
                        .disabled(timer.hasUnfinishedSession)
                    }
                }

                customDurationControls
                    .padding(.top, 12)

                HStack(spacing: 10) {
                    Button {
                        timer.toggle()
                    } label: {
                        Label(primaryButtonTitle, systemImage: primaryButtonSystemImage)
                            .frame(minWidth: 112)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .tint(WorkspacePalette.accent)
                    .disabled(timer.remainingSeconds == 0)
                    .keyboardShortcut(.space, modifiers: [])

                    Button(t("Reset")) { timer.reset() }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                        .disabled(!timer.hasUnfinishedSession && timer.remainingSeconds == timer.selectedMinutes * 60)
                }
                .padding(.top, 18)
            }
            .padding(22)
            .frame(minHeight: 390)
        }
    }

    private var progressBar: some View {
        VStack(spacing: 8) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.07))
                    Capsule()
                        .fill(WorkspacePalette.accent)
                        .frame(width: max(3, geometry.size.width * timer.progress))
                }
            }
            .frame(height: 4)

            HStack {
                Text(timer.isRunning ? t(timer.selectedKind == .breakTime ? "RESTING" : "FOCUSING") : t("SESSION"))
                Spacer()
                Text("\(Int(timer.progress * 100))%")
                    .monospacedDigit()
            }
            .font(.system(size: 8.5, weight: .bold, design: .monospaced))
            .foregroundStyle(WorkspacePalette.secondaryText)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(t(timer.selectedKind == .breakTime ? "Break progress" : "Focus session progress"))
        .accessibilityValue(t("%@ percent", "\(Int(timer.progress * 100))"))
    }

    private var contextColumn: some View {
        VStack(spacing: 12) {
            WorkspaceCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text(t("COMPLETED FOCUS"))
                        .font(.system(size: 9, weight: .bold))
                        .tracking(0.9)
                        .foregroundStyle(WorkspacePalette.secondaryText)

                    HStack(alignment: .firstTextBaseline, spacing: 16) {
                        focusMetric("Today", minutes: timer.summary(now: now).todayMinutes)
                        focusMetric("This week", minutes: timer.summary(now: now).weekMinutes)
                    }
                    Text(t("Only finished focus sessions count. Breaks are excluded."))
                        .font(.system(size: 10.5))
                        .foregroundStyle(WorkspacePalette.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                    Divider().overlay(WorkspacePalette.stroke)
                    Text(t("%@ completed timers on this Mac, including breaks.", "\(timer.completedSessions)"))
                        .font(.system(size: 10.5))
                        .foregroundStyle(WorkspacePalette.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            nextMeetingCard
        }
    }

    private func focusMetric(_ title: String, minutes: Int) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(t(title))
                .font(.system(size: 10.5, weight: .medium))
                .foregroundStyle(WorkspacePalette.secondaryText)
            Text(t("%@ min", "\(minutes)"))
                .font(.system(size: 23, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(WorkspacePalette.primaryText)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var customDurationControls: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text(t("Custom focus"))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(WorkspacePalette.secondaryText)
                Spacer(minLength: 0)
                TextField("30", text: $customMinutes)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 48)
                    .multilineTextAlignment(.trailing)
                    .accessibilityLabel(t("Focus duration in minutes"))
                    .onSubmit(prepareCustomFocus)
                    .disabled(timer.hasUnfinishedSession)
                Text(t("minutes"))
                    .font(.system(size: 10.5))
                    .foregroundStyle(WorkspacePalette.secondaryText)
                Button(t("Set"), action: prepareCustomFocus)
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .disabled(timer.hasUnfinishedSession)
            }
            Text(durationError.map { t($0) } ?? t(timer.hasUnfinishedSession ? "Reset the current timer to change its duration." : "Choose 5–180 minutes. The timer starts when you press Start."))
                .font(.system(size: 10))
                .foregroundStyle(durationError == nil ? WorkspacePalette.secondaryText : .orange)
                .fixedSize(horizontal: false, vertical: true)
        }
        .onChange(of: customMinutes) { _, _ in durationError = nil }
    }

    private var historyCard: some View {
        WorkspaceCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text(t("RECENT COMPLETIONS"))
                        .font(.system(size: 9, weight: .bold))
                        .tracking(0.9)
                        .foregroundStyle(WorkspacePalette.secondaryText)
                    Spacer()
                    Button(action: exportHistory) {
                        Label(t("Export CSV"), systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .disabled(timer.history.isEmpty)
                }

                if timer.history.isEmpty {
                    Text(t("Finish a timer to see its record here."))
                        .font(.system(size: 12))
                        .foregroundStyle(WorkspacePalette.primaryText)
                } else {
                    ForEach(timer.history.prefix(8)) { record in
                        HStack(spacing: 10) {
                            Image(systemName: record.kind == .focus ? "checkmark.circle.fill" : "cup.and.saucer")
                                .foregroundStyle(record.kind == .focus ? WorkspacePalette.success : WorkspacePalette.secondaryText)
                                .frame(width: 18)
                                .accessibilityHidden(true)
                            Text(record.taskLabel ?? t(record.kind == .focus ? "Focus" : "Break"))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(WorkspacePalette.primaryText)
                                .lineLimit(1)
                            Text(t("%@ min", "\(record.minutes)"))
                                .monospacedDigit()
                                .foregroundStyle(WorkspacePalette.secondaryText)
                            Spacer()
                            Text(completionDateLabel(record.completedAt))
                                .foregroundStyle(WorkspacePalette.secondaryText)
                        }
                        .font(.system(size: 11))
                        .accessibilityElement(children: .combine)
                    }
                }

                Text(t("Focus minutes belong to the day a session finishes. The latest 1,000 completions stay on this Mac; earlier totals have no detailed records. CSV exports all retained records with UTC timestamps."))
                    .font(.system(size: 10.5))
                    .foregroundStyle(WorkspacePalette.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
                if let exportError {
                    Label(exportError, systemImage: "exclamationmark.triangle")
                        .font(.system(size: 11))
                        .foregroundStyle(.orange)
                        .textSelection(.enabled)
                } else if let exportConfirmation {
                    Label(exportConfirmation, systemImage: "checkmark.circle")
                        .font(.system(size: 11))
                        .foregroundStyle(WorkspacePalette.success)
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder private var nextMeetingCard: some View {
        WorkspaceCard {
            VStack(alignment: .leading, spacing: 10) {
                Text(t("UP NEXT"))
                    .font(.system(size: 9, weight: .bold))
                    .tracking(0.9)
                    .foregroundStyle(WorkspacePalette.secondaryText)

                if let event = nextTimedEvent {
                    Text(
                        event.startDate <= now
                            ? t("Happening now")
                            : t("Next at %@", event.startDate.shortTime(locale: appLanguage.locale))
                    )
                        .font(.system(size: 10.5, weight: .semibold))
                        .foregroundStyle(WorkspacePalette.accent)
                    Text(event.displayTitle(language: appLanguage))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(WorkspacePalette.primaryText)
                        .lineLimit(2)
                    Text(guardrailDescription(for: event))
                        .font(.system(size: 10.5))
                        .foregroundStyle(WorkspacePalette.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                    if sessionWillOverlap(event) {
                        Label(t("This timer would overlap the meeting."), systemImage: "exclamationmark.triangle.fill")
                            .font(.system(size: 10.5, weight: .medium))
                            .foregroundStyle(.orange)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    if let meetingLink = event.meetingLink {
                        Button {
                            NSWorkspace.shared.open(meetingLink.url)
                        } label: {
                            Label(
                                meetingLink.provider.actionTitle(language: appLanguage),
                                systemImage: meetingLink.provider.actionSystemImage
                            )
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                } else if let message = calendar.availabilityMessage {
                    Label(t(message), systemImage: "calendar.badge.exclamationmark")
                        .font(.system(size: 10.5))
                        .foregroundStyle(WorkspacePalette.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text(t("No more timed events today."))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(WorkspacePalette.primaryText)
                    Text(t("Nothing upcoming on your calendar."))
                        .font(.system(size: 10.5))
                        .foregroundStyle(WorkspacePalette.secondaryText)
                }

                if let minutes = suggestedFocusMinutes(at: now) {
                    Divider().overlay(WorkspacePalette.stroke)
                    Text(t("A %@ minute focus fits your current calendar gap.", "\(minutes)"))
                        .font(.system(size: 10.5))
                        .foregroundStyle(WorkspacePalette.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                    Button(t("Prepare %@ min focus", "\(minutes)")) {
                        guard let refreshedMinutes = suggestedFocusMinutes(at: Date()) else {
                            recommendationFeedback = "Available time has changed. Check the latest gaps on Today."
                            return
                        }
                        recommendationFeedback = timer.prepareFocus(minutes: refreshedMinutes)
                            ? nil : "Reset the current timer to change its duration."
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .disabled(timer.hasUnfinishedSession)
                }
                if let recommendationFeedback {
                    Text(t(recommendationFeedback))
                        .font(.system(size: 10.5))
                        .foregroundStyle(.orange)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var nextTimedEvent: CalendarEvent? {
        calendar.todayEvents.first {
            !$0.isAllDay && $0.blocksTime && $0.endDate > now
        }
    }

    private var sessionTitle: String {
        if timer.selectedKind == .breakTime { return t("SHORT BREAK") }
        switch timer.selectedMinutes {
        case 50: return t("DEEP FOCUS")
        default: return t("FOCUS SESSION")
        }
    }

    private var sessionDescription: String {
        if timer.selectedKind == .breakTime { return t("Step away, breathe, and return with a clean slate.") }
        switch timer.selectedMinutes {
        case 50: return t("A longer block for work that needs depth.")
        default: return t("A focused block with enough room to make progress.")
        }
    }

    private var primaryButtonTitle: String {
        if timer.isRunning { return t("Pause") }
        if timer.remainingSeconds == 0 { return t("Complete") }
        return timer.hasUnfinishedSession ? t("Resume") : t("Start")
    }

    private var primaryButtonSystemImage: String {
        if timer.isRunning { return "pause.fill" }
        return timer.remainingSeconds == 0 ? "checkmark" : "play.fill"
    }

    private func guardrailDescription(for event: CalendarEvent) -> String {
        guard event.startDate > now else {
            return t("Ends at %@", event.endDate.shortTime(locale: appLanguage.locale))
        }
        let minutes = max(1, Int(event.startDate.timeIntervalSince(now) / 60))
        return minutes == 1
            ? t("Starts in 1 minute")
            : t("Starts in %@ minutes", "\(minutes)")
    }

    private func sessionWillOverlap(_ event: CalendarEvent) -> Bool {
        guard event.blocksTime, event.endDate > now, timer.remainingSeconds > 0 else { return false }
        return now.addingTimeInterval(TimeInterval(timer.remainingSeconds)) > event.startDate
    }

    private func suggestedFocusMinutes(at date: Date) -> Int? {
        guard calendar.sourceAvailability == .available else { return nil }
        let settings = DayPlanSettings(
            startHour: planningStartHour,
            endHour: planningEndHour,
            bufferMinutes: planningBufferMinutes
        )
        return DayPlanEngine.makePlan(events: calendar.planningEvents, now: date, settings: settings)
            .recommendedFocusMinutes(at: date)
    }

    private func prepareCustomFocus() {
        guard let minutes = Int(customMinutes.trimmingCharacters(in: .whitespacesAndNewlines)),
              FocusTimerModel.customMinuteRange.contains(minutes) else {
            durationError = "Enter a whole number from 5 to 180."
            return
        }
        guard timer.prepareFocus(minutes: minutes) else {
            durationError = "Reset the current timer to change its duration."
            return
        }
        durationError = nil
    }

    private func completionDateLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = appLanguage.locale
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func exportHistory() {
        exportError = nil
        exportConfirmation = nil
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.commaSeparatedText]
        panel.canCreateDirectories = true
        panel.nameFieldStringValue = "Notch-focus.csv"
        panel.title = t("Export focus history")
        panel.prompt = t("Export")
        panel.begin { response in
            Task { @MainActor in
                guard response == .OK, let url = panel.url else { return }
                do {
                    try FocusHistoryCSV.write(records: timer.history, to: url)
                    exportConfirmation = t("Saved %@", url.lastPathComponent)
                } catch {
                    exportError = t("Could not export focus history: %@", error.localizedDescription)
                }
            }
        }
    }

    private func t(_ key: String, _ arguments: CVarArg...) -> String {
        L10n.string(key, language: appLanguage, arguments: arguments)
    }
}

private struct FocusPresetButton: View {
    let minutes: Int
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.appLanguage) private var appLanguage

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text("\(minutes)")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                Text(
                    L10n.string(
                        minutes == 5 ? "break" : "minutes",
                        language: appLanguage
                    )
                )
                    .font(.system(size: 8.5, weight: .medium))
            }
            .foregroundStyle(isSelected ? WorkspacePalette.primaryText : WorkspacePalette.secondaryText)
            .frame(maxWidth: .infinity)
            .frame(height: 43)
            .background(
                isSelected ? WorkspacePalette.accent.opacity(0.16) : Color.white.opacity(0.045),
                in: RoundedRectangle(cornerRadius: 9, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .stroke(isSelected ? WorkspacePalette.accent.opacity(0.55) : WorkspacePalette.stroke, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            minutes == 5
                ? L10n.string("5 minute break", language: appLanguage)
                : L10n.string(
                    "%@ minute focus session",
                    language: appLanguage,
                    "\(minutes)"
                )
        )
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
