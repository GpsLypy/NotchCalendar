import SwiftUI

/// The day's score: time-proportional appointments with a live playhead.
struct DayTimelineView: View {
    let events: [CalendarEvent]
    let now: Date
    let window: DayPlanInterval
    var onSelectEvent: ((CalendarEvent) -> Void)? = nil
    @Environment(\.appLanguage) private var appLanguage
    @State private var selectedID: String?

    private var layout: DayTimelineLayout { DayTimelineLayout(events: events, window: window) }
    private var selection: CalendarEvent? {
        layout.segments.first { $0.id == selectedID }?.event
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(t("Day track"), systemImage: "chart.bar.xaxis")
                    .font(.system(size: 11, weight: .semibold))
                Spacer()
                Text(t("Select an event to inspect it"))
                    .font(.system(size: 10))
            }
            .foregroundStyle(WorkspacePalette.secondaryText)

            ScrollView(.vertical) {
                tracks
                    .frame(height: CGFloat(max(2, layout.laneCount)) * 30 + 24)
            }
            .frame(height: CGFloat(min(4, max(2, layout.laneCount))) * 30 + 24)

            HStack(alignment: .top, spacing: 12) {
                if let event = selection {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(event.displayTitle(language: appLanguage))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(WorkspacePalette.primaryText)
                        Text("\(range(event.startDate, event.endDate)) · \(event.calendarName)")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(WorkspacePalette.secondaryText)
                    }
                    Spacer(minLength: 4)
                    if let onSelectEvent {
                        Button { onSelectEvent(event) } label: {
                            Label(t("Meeting notes"), systemImage: "note.text")
                        }
                        .buttonStyle(.bordered).controlSize(.small)
                    }
                } else {
                    Text(t(layout.segments.isEmpty
                           ? "No timed events in your planning hours."
                           : "Each lane separates overlapping events. Scroll for more lanes."))
                        .font(.system(size: 11))
                        .foregroundStyle(WorkspacePalette.secondaryText)
                }
            }
            .frame(minHeight: 32, alignment: .top)
        }
        .onChange(of: events) { _, _ in
            if selection == nil { selectedID = nil }
        }
    }

    private var tracks: some View {
        GeometryReader { proxy in
            let width = max(0, proxy.size.width - 2)
            let duration = max(1, window.end.timeIntervalSince(window.start))
            let fraction = min(1, max(0, now.timeIntervalSince(window.start) / duration))
            ZStack(alignment: .topLeading) {
                ForEach(0..<5) { index in
                    let position = Double(index) / 4
                    Group {
                        Text(index == 4 && !Calendar.current.isDate(window.start, inSameDayAs: window.end)
                             ? "24:00" : window.start.addingTimeInterval(duration * position).shortTime(locale: appLanguage.locale))
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundStyle(WorkspacePalette.secondaryText)
                            .frame(width: 58, alignment: index == 0 ? .leading : index == 4 ? .trailing : .center)
                            .offset(x: width * position - (index == 0 ? 0 : index == 4 ? 58 : 29))
                        Rectangle().fill(WorkspacePalette.stroke)
                            .frame(width: 1, height: max(0, proxy.size.height - 24))
                            .offset(x: width * position, y: 24)
                    }
                    .accessibilityHidden(true)
                }
                ForEach(layout.segments) { segment in
                    Button { selectedID = segment.id } label: {
                        Text(segment.event.displayTitle(language: appLanguage))
                            .font(.system(size: 10, weight: .medium))
                            .lineLimit(1)
                            .padding(.horizontal, 7)
                            .frame(width: max(2, width * (segment.endFraction - segment.startFraction)), height: 24, alignment: .leading)
                            .background(AlcovePalette.accent.opacity(selectedID == segment.id ? 0.50 : 0.22), in: RoundedRectangle(cornerRadius: 5))
                            .overlay {
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(selectedID == segment.id ? WorkspacePalette.primaryText : AlcovePalette.accent.opacity(0.45), lineWidth: 1)
                            }
                            .clipped()
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(WorkspacePalette.primaryText)
                    .offset(x: width * segment.startFraction, y: 24 + CGFloat(segment.lane) * 30)
                    .help("\(segment.event.displayTitle(language: appLanguage)) · \(range(segment.event.startDate, segment.event.endDate))")
                    .accessibilityLabel("\(segment.event.displayTitle(language: appLanguage)), \(range(segment.event.startDate, segment.event.endDate))")
                    .accessibilityAddTraits(selectedID == segment.id ? .isSelected : [])
                }
                if now >= window.start && now < window.end {
                    VStack(spacing: 0) {
                        Circle().fill(WorkspacePalette.accent).frame(width: 5, height: 5)
                        Rectangle().fill(WorkspacePalette.accent).frame(width: 1)
                    }
                    .offset(x: width * fraction - 2.5, y: 19)
                    .frame(height: max(0, proxy.size.height - 19))
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
                }
            }
        }
    }

    private func range(_ start: Date, _ end: Date) -> String {
        "\(start.shortTime(locale: appLanguage.locale))–\(end.shortTime(locale: appLanguage.locale))"
    }
    private func t(_ key: String) -> String { L10n.string(key, language: appLanguage) }
}
