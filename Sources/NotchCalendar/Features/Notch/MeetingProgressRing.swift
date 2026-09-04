import SwiftUI

struct MeetingProgressRing: View {
    let event: CalendarEvent
    let now: Date
    var size: CGFloat = 22
    var lineWidth: CGFloat = 2.5
    @Environment(\.appLanguage) private var appLanguage

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
        .accessibilityLabel(t("Meeting progress"))
        .accessibilityValue(t("%@ percent", "\(percentage)"))
        .help(t("Meeting progress: %@", "\(percentage)%"))
    }

    private var percentage: Int {
        Int((progress * 100).rounded())
    }

    private func t(_ key: String, _ arguments: CVarArg...) -> String {
        L10n.string(key, language: appLanguage, arguments: arguments)
    }
}
