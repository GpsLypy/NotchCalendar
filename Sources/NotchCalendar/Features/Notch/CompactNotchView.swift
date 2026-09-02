import Combine
import SwiftUI

struct CompactNotchView: View {
    let events: [CalendarEvent]
    @State private var now = Date()

    var body: some View {
        let status = UpcomingEventEngine.status(now: now, events: events)
        HStack(spacing: 10) {
            switch status {
            case let .active(event, secondsRemaining):
                statusDot(AlcovePalette.accent)
                Text(event.title).lineLimit(1)
                countdownLabel(UpcomingEventEngine.countdown(secondsRemaining), suffix: "left")
            case let .upcoming(event, secondsUntilStart):
                statusDot(AlcovePalette.accent)
                Text(event.title).lineLimit(1)
                countdownLabel(UpcomingEventEngine.countdown(secondsUntilStart), prefix: "in")
            case .idle:
                Text(now.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day()))
                Spacer(minLength: 0)
                Text(now, format: .dateTime.hour().minute())
                    .monospacedDigit()
            }
        }
        .font(.system(size: 12, weight: .medium, design: .rounded))
        .foregroundStyle(.white.opacity(0.92))
        .padding(.horizontal, 18)
        .frame(height: 36)
        .background(.black.opacity(0.94), in: NotchAttachedCardShape())
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { now = $0 }
    }

    private func statusDot(_ color: Color) -> some View { Circle().fill(color).frame(width: 6, height: 6) }

    private func countdownLabel(_ countdown: String, prefix: String? = nil, suffix: String? = nil) -> some View {
        HStack(spacing: 3) {
            if let prefix { Text(prefix) }
            Text(countdown).monospacedDigit()
            if let suffix { Text(suffix) }
        }
        .foregroundStyle(AlcovePalette.secondaryText)
        .fixedSize()
    }
}
