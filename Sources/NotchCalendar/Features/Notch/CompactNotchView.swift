import Combine
import SwiftUI

struct CompactNotchView: View {
    let events: [CalendarEvent]
    @State private var now = Date()
    @Environment(\.appLanguage) private var appLanguage

    var body: some View {
        let status = UpcomingEventEngine.status(now: now, events: events)
        HStack(spacing: 10) {
            switch status {
            case let .active(event, secondsRemaining):
                MeetingProgressRing(event: event, now: now, size: 10, lineWidth: 2)
                Text(event.displayTitle(language: appLanguage)).lineLimit(1)
                meetingLinkIndicator(for: event)
                countdownLabel(
                    t("%@ left", UpcomingEventEngine.countdown(secondsRemaining))
                )
            case let .upcoming(event, secondsUntilStart):
                statusDot(AlcovePalette.accent)
                Text(event.displayTitle(language: appLanguage)).lineLimit(1)
                meetingLinkIndicator(for: event)
                countdownLabel(
                    t("in %@", UpcomingEventEngine.countdown(secondsUntilStart))
                )
            case .idle:
                Text(
                    now.formatted(
                        .dateTime
                            .weekday(.abbreviated)
                            .month(.abbreviated)
                            .day()
                            .locale(appLanguage.locale)
                    )
                )
                Spacer(minLength: 0)
                Text(now.formatted(.dateTime.hour().minute().locale(appLanguage.locale)))
                    .monospacedDigit()
            }
        }
        .font(.system(size: 12, weight: .medium, design: .rounded))
        .foregroundStyle(.white.opacity(0.92))
        .padding(.horizontal, 18)
        .frame(height: ScreenGeometry.compactPanelHeight)
        .background(
            .black.opacity(0.94),
            in: NotchAttachedCardShape(cornerRadius: ScreenGeometry.compactPanelCornerRadius)
        )
        .accessibilityElement(children: .combine)
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { now = $0 }
    }

    private func statusDot(_ color: Color) -> some View { Circle().fill(color).frame(width: 6, height: 6) }

    @ViewBuilder private func meetingLinkIndicator(for event: CalendarEvent) -> some View {
        if let meetingLink = event.meetingLink {
            Image(systemName: meetingLink.provider.actionSystemImage)
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(AlcovePalette.accent)
                .accessibilityLabel(meetingLink.provider.availabilityDescription(language: appLanguage))
        }
    }

    private func countdownLabel(_ text: String) -> some View {
        Text(text)
            .monospacedDigit()
            .foregroundStyle(AlcovePalette.secondaryText)
            .fixedSize()
    }

    private func t(_ key: String, _ arguments: CVarArg...) -> String {
        L10n.string(key, language: appLanguage, arguments: arguments)
    }
}
