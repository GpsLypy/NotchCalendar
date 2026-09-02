import SwiftUI

struct MeetingProgressRing: View {
    let event: CalendarEvent
    let now: Date
    var size: CGFloat = 22
    var lineWidth: CGFloat = 2.5

    private var progress: Double {
        UpcomingEventEngine.progress(now: now, event: event)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(.white.opacity(0.14), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AlcovePalette.accent,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
        }
        .frame(width: size, height: size)
        .animation(.linear(duration: 1), value: progress)
        .accessibilityElement()
        .accessibilityLabel("Meeting progress")
        .accessibilityValue("\(Int((progress * 100).rounded())) percent")
        .help("Meeting progress: \(Int((progress * 100).rounded()))%")
    }
}
