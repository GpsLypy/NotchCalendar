import AppKit
import SwiftUI

struct FocusWorkspaceView: View {
    @ObservedObject var timer: FocusTimerModel
    @ObservedObject var calendar: CalendarManager
    let now: Date
    @Environment(\.appLanguage) private var appLanguage

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                pageHeader
                HStack(alignment: .top, spacing: 18) {
                    timerCard
                        .frame(maxWidth: .infinity, alignment: .top)
                    contextColumn
                        .frame(width: 230, alignment: .top)
                }
            }
            .padding(.horizontal, 30)
            .padding(.top, 52)
            .padding(.bottom, 30)
        }
        .background(WorkspacePalette.canvas)
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
                            : timer.remainingSeconds == 0 ? t("COMPLETE") : t("READY")
                    )
                        .font(.system(size: 9, weight: .bold))
                        .tracking(0.8)
                        .foregroundStyle(WorkspacePalette.secondaryText)
                }

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
                        ? t("Stay with the work in front of you.")
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
                            isSelected: timer.selectedMinutes == minutes
                        ) {
                            timer.select(minutes: minutes)
                        }
                        .disabled(timer.isRunning)
                    }
                }

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
                        .disabled(!timer.isRunning && timer.remainingSeconds == timer.selectedMinutes * 60)
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
                Text(timer.isRunning ? t("FOCUSING") : t("SESSION"))
                Spacer()
                Text("\(Int(timer.progress * 100))%")
                    .monospacedDigit()
            }
            .font(.system(size: 8.5, weight: .bold, design: .monospaced))
            .foregroundStyle(WorkspacePalette.secondaryText)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(t("Focus session progress"))
        .accessibilityValue(t("%@ percent", "\(Int(timer.progress * 100))"))
    }

    private var contextColumn: some View {
        VStack(spacing: 12) {
            WorkspaceCard {
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: "checkmark.seal")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(WorkspacePalette.success)
                        .accessibilityHidden(true)
                    Text(t("SESSIONS"))
                        .font(.system(size: 9, weight: .bold))
                        .tracking(0.9)
                        .foregroundStyle(WorkspacePalette.secondaryText)
                    Text("\(timer.completedSessions)")
                        .font(.system(size: 30, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(WorkspacePalette.primaryText)
                    Text(t("Completed timers on this Mac"))
                        .font(.system(size: 10.5))
                        .foregroundStyle(WorkspacePalette.secondaryText)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            nextMeetingCard
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
                } else if let message = calendar.authorizationMessage {
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
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var nextTimedEvent: CalendarEvent? {
        calendar.todayEvents.first {
            !$0.isAllDay && $0.endDate > now
        }
    }

    private var sessionTitle: String {
        switch timer.selectedMinutes {
        case 5: t("SHORT BREAK")
        case 50: t("DEEP FOCUS")
        default: t("FOCUS SESSION")
        }
    }

    private var sessionDescription: String {
        switch timer.selectedMinutes {
        case 5: t("Step away, breathe, and return with a clean slate.")
        case 50: t("A longer block for work that needs depth.")
        default: t("A focused block with enough room to make progress.")
        }
    }

    private var primaryButtonTitle: String {
        if timer.isRunning { return t("Pause") }
        if timer.remainingSeconds == 0 { return t("Complete") }
        return timer.remainingSeconds < timer.selectedMinutes * 60 ? t("Resume") : t("Start")
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
        guard event.startDate > now, timer.remainingSeconds > 0 else { return false }
        return now.addingTimeInterval(TimeInterval(timer.remainingSeconds)) > event.startDate
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
