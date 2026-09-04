import Combine
import SwiftUI

struct CompactNotchView: View {
    let events: [CalendarEvent]
    let notchWidth: CGFloat?
    let notchDepth: CGFloat?
    let showsMeetingStatus: Bool
    let showsClickTarget: Bool
    let onMeetingActivityChange: (Bool) -> Void
    @State private var now = Date()
    @Environment(\.appLanguage) private var appLanguage

    var body: some View {
        let status = UpcomingEventEngine.status(now: now, events: events)
        let displayStatus = showsMeetingStatus ? status : .idle

        Group {
            if let notchWidth, notchWidth > 0 {
                notchedContent(
                    status: displayStatus,
                    notchWidth: notchWidth,
                    notchDepth: ScreenGeometry.compactPanelHeight(notchDepth: notchDepth)
                )
            } else {
                fallbackPillContent(status: displayStatus)
            }
        }
        .font(.system(size: 12, weight: .medium, design: .rounded))
        .accessibilityElement(children: .combine)
        .onAppear { onMeetingActivityChange(status.isActive) }
        .onChange(of: status.isActive) { _, isActive in
            onMeetingActivityChange(isActive)
        }
        .onReceive(
            Timer.publish(
                every: showsMeetingStatus ? 1 : 60,
                on: .main,
                in: .common
            ).autoconnect()
        ) { now = $0 }
        .onChange(of: showsMeetingStatus) { _, _ in now = Date() }
    }

    /// Hardware screenshots can capture pixels drawn behind the camera housing,
    /// even though those pixels are not visible to the person using the Mac. Keep
    /// the physical notch completely free of semantic content and use its two
    /// unobstructed shoulders for the glanceable meeting state instead.
    private func notchedContent(
        status: EventStatus,
        notchWidth: CGFloat,
        notchDepth: CGFloat
    ) -> some View {
        GeometryReader { proxy in
            let centerWidth = min(max(0, notchWidth), proxy.size.width)
            let shoulderWidth = max(0, (proxy.size.width - centerWidth) / 2)

            ZStack {
                NotchAttachedCardShape(cornerRadius: ScreenGeometry.compactPanelCornerRadius)
                    .fill(.black.opacity(0.94))
                    .frame(width: centerWidth, height: proxy.size.height)
                    .accessibilityHidden(true)

                HStack(spacing: 0) {
                    notchedLeadingContent(for: status)
                        .padding(.leading, 8)
                        .padding(.trailing, 9)
                        .frame(
                            width: shoulderWidth,
                            height: proxy.size.height,
                            alignment: .trailing
                        )
                        .clipped()

                    Color.clear
                        .frame(width: centerWidth, height: proxy.size.height)
                        .accessibilityHidden(true)

                    notchedTrailingContent(for: status)
                        .padding(.leading, 9)
                        .padding(.trailing, 8)
                        .frame(
                            width: shoulderWidth,
                            height: proxy.size.height,
                            alignment: .leading
                        )
                        .clipped()
                }
            }
        }
        .frame(height: notchDepth)
    }

    private func fallbackPillContent(status: EventStatus) -> some View {
        HStack(spacing: 10) {
            switch status {
            case let .active(event, _):
                MeetingProgressRing(event: event, now: now, size: 10, lineWidth: 2)
                eventTitle(for: event)
                meetingLinkIndicator(for: event)
            case let .upcoming(event, secondsUntilStart):
                statusDot(AlcovePalette.accent)
                eventTitle(for: event)
                meetingLinkIndicator(for: event)
                countdownLabel(
                    t("in %@", UpcomingEventEngine.countdown(secondsUntilStart)),
                    color: AlcovePalette.secondaryText
                )
            case .idle:
                Text(formattedDate)
                    .lineLimit(1)
                Spacer(minLength: 0)
                Text(formattedTime)
                    .monospacedDigit()
            }
        }
        .foregroundStyle(.white.opacity(0.92))
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity, minHeight: ScreenGeometry.compactPanelHeight)
        .background(
            .black.opacity(0.94),
            in: NotchAttachedCardShape(cornerRadius: ScreenGeometry.compactPanelCornerRadius)
        )
    }

    @ViewBuilder
    private func notchedLeadingContent(for status: EventStatus) -> some View {
        if case let .active(event, _) = status {
            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .font(.system(size: 13, weight: .semibold))
                    .frame(width: 16, height: 16)
                    .accessibilityHidden(true)

                eventTitle(for: event)
                meetingLinkIndicator(for: event)
            }
            .foregroundStyle(Color.primary.opacity(0.86))
        } else if showsClickTarget {
            compactClickIndicator
        }
    }

    @ViewBuilder
    private func notchedTrailingContent(for status: EventStatus) -> some View {
        switch status {
        case let .active(event, _):
            MeetingProgressRing(
                event: event,
                now: now,
                size: 18,
                lineWidth: 2.5,
                trackColor: Color.primary.opacity(0.16)
            )
        case .upcoming, .idle:
            if showsClickTarget {
                compactClickIndicator
            }
        }
    }

    private var compactClickIndicator: some View {
        Circle()
            .fill(AlcovePalette.accent)
            .frame(width: 5, height: 5)
            .shadow(color: AlcovePalette.accent.opacity(0.34), radius: 3)
            .accessibilityHidden(true)
    }

    private func eventTitle(for event: CalendarEvent) -> some View {
        Text(event.displayTitle(language: appLanguage))
            .lineLimit(1)
            .truncationMode(.tail)
    }

    private func statusDot(_ color: Color) -> some View {
        Circle()
            .fill(color)
            .frame(width: 6, height: 6)
    }

    @ViewBuilder
    private func meetingLinkIndicator(for event: CalendarEvent) -> some View {
        if let meetingLink = event.meetingLink {
            Image(systemName: meetingLink.provider.actionSystemImage)
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(AlcovePalette.accent)
                .accessibilityLabel(meetingLink.provider.availabilityDescription(language: appLanguage))
        }
    }

    private func countdownLabel(
        _ text: String,
        color: Color,
        allowsCompression: Bool = false,
        accessibilityText: String? = nil
    ) -> some View {
        Text(text)
            .monospacedDigit()
            .foregroundStyle(color)
            .lineLimit(1)
            .minimumScaleFactor(allowsCompression ? 0.72 : 1)
            .allowsTightening(allowsCompression)
            .fixedSize(horizontal: !allowsCompression, vertical: true)
            .layoutPriority(allowsCompression ? 1 : 0)
            .accessibilityLabel(accessibilityText ?? text)
    }

    private var formattedDate: String {
        now.formatted(
            .dateTime
                .weekday(.abbreviated)
                .month(.abbreviated)
                .day()
                .locale(appLanguage.locale)
        )
    }

    private var formattedTime: String {
        now.formatted(.dateTime.hour().minute().locale(appLanguage.locale))
    }

    private func t(_ key: String, _ arguments: CVarArg...) -> String {
        L10n.string(key, language: appLanguage, arguments: arguments)
    }
}
