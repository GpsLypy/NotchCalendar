import Foundation
import NotchCalendarShared
import SwiftUI
import WidgetKit

struct FocusTimerWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: WidgetConstants.focusKind,
            provider: FocusWidgetProvider()
        ) { entry in
            FocusTimerWidgetView(entry: entry)
        }
        .configurationDisplayName("专注 / Focus")
        .description("查看专注倒计时与进度 / See the current focus timer")
        .supportedFamilies([.systemSmall])
        .contentMarginsDisabled()
        .containerBackgroundRemovable(false)
    }
}

private struct FocusTimerWidgetView: View {
    let entry: FocusWidgetEntry

    var body: some View {
        NotchWidgetCanvas {
            if let snapshot = entry.snapshot {
                FocusTimerContent(
                    date: entry.date,
                    snapshot: snapshot,
                    copy: NotchWidgetCopy(
                        localizationIdentifier: snapshot.localizationIdentifier
                    )
                )
            } else {
                let copy = NotchWidgetCopy(localizationIdentifier: nil)
                NotchWidgetGuidance(
                    symbol: "timer",
                    title: copy.focusSetupTitle,
                    detail: copy.focusSetupDetail,
                    destination: NotchWidgetDestination.focus,
                    openLabel: copy.openApp
                )
            }
        }
    }
}

private struct FocusTimerContent: View {
    let date: Date
    let snapshot: WidgetFocusSnapshot
    let copy: NotchWidgetCopy

    private var phase: WidgetFocusPhase {
        snapshot.phase(at: date)
    }

    var body: some View {
        VStack(spacing: 8) {
            NotchWidgetHeader(
                title: copy.focusWidgetName,
                destination: NotchWidgetDestination.focus,
                openLabel: copy.openApp
            ) {
                HStack(spacing: 3) {
                    Text("\(snapshot.completedSessions)")
                        .monospacedDigit()
                    Text(copy.sessions)
                }
                .font(.system(size: 9, weight: .medium, design: .rounded))
                .foregroundStyle(NotchWidgetPalette.secondary)
            }

            Spacer(minLength: 0)

            FocusProgressDial(date: date, snapshot: snapshot, phase: phase)

            Text(phaseTitle)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(
                    phase == .running
                        ? NotchWidgetPalette.coral
                        : NotchWidgetPalette.secondary
                )

            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(copy.focusWidgetName), \(phaseTitle)")
    }

    private var phaseTitle: String {
        switch phase {
        case .ready: copy.ready
        case .running: copy.running
        case .paused: copy.paused
        case .complete: copy.complete
        }
    }
}

private struct FocusProgressDial: View {
    let date: Date
    let snapshot: WidgetFocusSnapshot
    let phase: WidgetFocusPhase

    var body: some View {
        ZStack {
            if phase == .running,
               let targetDate = snapshot.targetDate,
               targetDate > date {
                ProgressView(
                    timerInterval: runningInterval(endingAt: targetDate),
                    countsDown: true
                )
                .progressViewStyle(NotchWidgetRingProgressStyle())

                Text(
                    timerInterval: date...targetDate,
                    countsDown: true,
                    showsHours: false
                )
                .font(.system(size: 23, weight: .medium, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(NotchWidgetPalette.primary)
            } else {
                ProgressView(value: remainingFraction)
                    .progressViewStyle(NotchWidgetRingProgressStyle())

                Text(formattedRemaining)
                    .font(.system(size: 23, weight: .medium, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(NotchWidgetPalette.primary)
            }
        }
        .frame(width: 84, height: 84)
    }

    private var remainingFraction: Double {
        Double(snapshot.remainingSeconds(at: date)) / Double(snapshot.totalSeconds)
    }

    private var formattedRemaining: String {
        let remaining = snapshot.remainingSeconds(at: date)
        let minutes = remaining / 60
        let seconds = remaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func runningInterval(endingAt targetDate: Date) -> ClosedRange<Date> {
        let startDate = targetDate.addingTimeInterval(-TimeInterval(snapshot.totalSeconds))
        return startDate...targetDate
    }
}
