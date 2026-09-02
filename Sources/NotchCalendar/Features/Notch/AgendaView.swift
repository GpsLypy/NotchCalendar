import SwiftUI
import AppKit

struct AgendaView: View {
    let events: [CalendarEvent]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("AGENDA").font(.system(size: 10, weight: .bold)).tracking(1.3).foregroundStyle(AlcovePalette.secondaryText)
            if events.isEmpty {
                Text("Nothing else on your calendar.").font(.system(size: 13)).foregroundStyle(AlcovePalette.secondaryText).padding(.vertical, 8)
            } else {
                ForEach(events.prefix(4)) { event in
                    Button { openInCalendar(event) } label: {
                        HStack(alignment: .top, spacing: 9) {
                            Capsule()
                                .fill(AlcovePalette.accent)
                                .frame(width: 3)
                                .frame(minHeight: 39)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(event.title)
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .lineLimit(1)
                                Text(timeDescription(for: event))
                                    .font(.system(size: 10.5, weight: .medium, design: .monospaced))
                                    .foregroundStyle(AlcovePalette.secondaryText)
                            if let location = event.location?.trimmingCharacters(in: .whitespacesAndNewlines), !location.isEmpty {
                                Label(location, systemImage: "mappin.and.ellipse")
                                    .font(.system(size: 10.5))
                                    .foregroundStyle(AlcovePalette.secondaryText)
                                    .lineLimit(1)
                            }
                            }
                            Spacer(minLength: 0)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 22).padding(.top, 17)
    }

    private func openInCalendar(_ event: CalendarEvent) {
        NSWorkspace.shared.open(URL(string: "ical://")!)
    }

    private func timeDescription(for event: CalendarEvent) -> String {
        event.isAllDay ? "All day" : "\(event.startDate.shortTime)–\(event.endDate.shortTime)"
    }
}
