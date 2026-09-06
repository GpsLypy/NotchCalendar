import AppKit
import SwiftUI

struct FocusCompactNotchView: View {
    @ObservedObject var timer: FocusTimerModel
    let notchWidth: CGFloat?
    let notchDepth: CGFloat?
    @Environment(\.appLanguage) private var appLanguage

    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: 5) {
                Image(systemName: timer.isRunning ? (timer.selectedKind == .focus ? "timer" : "cup.and.saucer.fill") : "pause.fill")
                    .font(.system(size: 12, weight: .medium))
                if notchWidth == nil {
                    Text(L10n.string(timer.selectedKind == .focus ? "Focus" : "Break", language: appLanguage))
                        .font(.system(size: 11, weight: .semibold)).lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity)
            if let notchWidth { Color.clear.frame(width: notchWidth).accessibilityHidden(true) }
            Text(timer.timeLabel)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .monospacedDigit()
                .frame(maxWidth: .infinity)
                .accessibilityLabel(L10n.string("%@ left", language: appLanguage, timer.timeLabel))
        }
        .foregroundStyle(WorkspacePalette.accent)
        .frame(height: ScreenGeometry.compactPanelHeight(notchDepth: notchDepth))
        .background(.black.opacity(0.96), in: NotchAttachedCardShape(cornerRadius: ScreenGeometry.compactPanelCornerRadius))
        .accessibilityElement(children: .combine)
    }
}

struct NotchCompactActivityView: View {
    @ObservedObject var timer: FocusTimerModel
    @ObservedObject var preferences: PresentationPreferences
    @ObservedObject var metrics: NotchLayoutMetrics
    let events: [CalendarEvent]
    let activityChanged: (Bool) -> Void
    @State private var now = Date()

    private var meetingIsActive: Bool { UpcomingEventEngine.status(now: now, events: events).isActive }
    private var activity: NotchActivity {
        NotchActivityPolicy.compactActivity(showsMeetings: preferences.showsMeetingStatus, meetingIsActive: meetingIsActive,
                                          showsFocus: preferences.showsFocusStatus, hasFocusSession: timer.hasUnfinishedSession)
    }
    private var showsShoulders: Bool {
        NotchActivityPolicy.showsShoulders(showsMeetings: preferences.showsMeetingStatus, meetingIsActive: meetingIsActive,
                                         showsFocus: preferences.showsFocusStatus, hasFocusSession: timer.hasUnfinishedSession)
    }

    var body: some View {
        Group {
            if activity == .focus {
                FocusCompactNotchView(timer: timer, notchWidth: metrics.compactNotchWidth, notchDepth: metrics.compactNotchDepth)
            } else {
                CompactNotchView(events: events, notchWidth: metrics.compactNotchWidth, notchDepth: metrics.compactNotchDepth,
                                 showsMeetingStatus: preferences.showsMeetingStatus, showsClickTarget: metrics.showsClickTarget,
                                 onMeetingActivityChange: { _ in }, now: now)
            }
        }
        .onAppear { timer.synchronize(); now = Date(); activityChanged(showsShoulders) }
        .onChange(of: events) { _, _ in now = Date() }
        .onChange(of: preferences.showsMeetingStatus) { _, _ in now = Date() }
        .onChange(of: showsShoulders) { _, value in activityChanged(value) }
        .onActivityClock(every: ActivityClockPolicy.compactInterval(
            now: now, events: events, showsMeetings: preferences.showsMeetingStatus,
            displaysUpcoming: metrics.compactNotchWidth == nil,
            visibleFocusRunning: activity == .focus && timer.isRunning
        )) { date in
            now = date
            timer.synchronize(now: date)
        }
    }
}

struct FocusNotchView: View {
    @ObservedObject var timer: FocusTimerModel
    let events: [CalendarEvent]
    let openFocus: () -> Void
    @Environment(\.appLanguage) private var appLanguage
    @State private var now = Date()

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 7) {
                    Label(t(timer.selectedKind == .focus ? "Focus" : "Break"), systemImage: timer.selectedKind == .focus ? "timer" : "cup.and.saucer")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(WorkspacePalette.accent)
                    Text(timer.taskLabel.isEmpty || timer.selectedKind != .focus ? t("One thing at a time.") : timer.taskLabel)
                        .font(.system(size: 19, weight: .semibold, design: .rounded)).lineLimit(2)
                    Text(t(timer.hasUnfinishedSession ? (timer.isRunning ? (timer.selectedKind == .focus ? "FOCUS RUNNING" : "Break running") : "Paused") : (timer.remainingSeconds == 0 ? "Session complete" : "Ready when you are")))
                        .font(.system(size: 11)).foregroundStyle(WorkspacePalette.secondaryText)
                }
                Spacer(minLength: 20)
                Text(timer.timeLabel)
                    .font(.system(size: 38, weight: .light, design: .monospaced))
                    .monospacedDigit()
            }
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.12))
                    Capsule().fill(WorkspacePalette.accent)
                        .frame(width: geometry.size.width * min(1, max(0, timer.progress)))
                }
            }
                .frame(height: 5)
                .accessibilityLabel(t("Focus progress"))
                .accessibilityValue("\(Int(timer.progress * 100))%")
            HStack(spacing: 10) {
                Button {
                    timer.synchronize()
                    if timer.remainingSeconds > 0 { timer.toggle() }
                } label: {
                    Label(t(timer.isRunning ? "Pause" : timer.hasUnfinishedSession ? "Resume" : "Start"),
                          systemImage: timer.isRunning ? "pause.fill" : "play.fill")
                        .frame(minWidth: 72)
                        .font(.system(size: 12, weight: .semibold))
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .foregroundStyle(WorkspacePalette.canvas)
                        .background(WorkspacePalette.accent, in: Capsule())
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.space, modifiers: [])
                .disabled(timer.remainingSeconds == 0 || timer.persistenceError != nil)
                .opacity(timer.remainingSeconds == 0 || timer.persistenceError != nil ? 0.45 : 1)
                Button(action: openFocus) {
                    Text(t("Open Focus"))
                        .font(.system(size: 12, weight: .medium))
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .background(.white.opacity(0.10), in: Capsule())
                }.buttonStyle(.plain)
                Spacer()
                Text(L10n.string("%@ min", language: appLanguage, "\(timer.selectedMinutes)"))
                    .font(.system(size: 11, design: .monospaced)).foregroundStyle(WorkspacePalette.secondaryText)
            }
            if let error = timer.persistenceError {
                Text(t(error)).font(.caption).foregroundStyle(WorkspacePalette.accent)
            }
            if let event = nextEvent {
                Divider().overlay(WorkspacePalette.stroke)
                HStack(spacing: 10) {
                    Image(systemName: "calendar").foregroundStyle(AlcovePalette.accent)
                    Text(event.displayTitle(language: appLanguage)).lineLimit(1)
                    Spacer()
                    Text(event.startDate.shortTime(locale: appLanguage.locale))
                        .monospacedDigit().foregroundStyle(WorkspacePalette.secondaryText)
                }
                .font(.system(size: 11))
            }
        }
        .padding(.horizontal, 30).padding(.top, 20).padding(.bottom, 28)
        .foregroundStyle(WorkspacePalette.primaryText)
        .background(.black)
        .onAppear { timer.synchronize(); now = Date() }
        .onActivityClock(every: timer.isRunning ? 1 : nil) { date in now = date; timer.synchronize(now: date) }
    }

    private var nextEvent: CalendarEvent? {
        switch UpcomingEventEngine.status(now: now, events: events) {
        case .active(let event, _), .upcoming(let event, _): event
        case .idle: nil
        }
    }
    private func t(_ key: String) -> String { L10n.string(key, language: appLanguage) }
}
