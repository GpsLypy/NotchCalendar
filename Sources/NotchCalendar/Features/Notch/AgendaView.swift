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
                    HStack(alignment: .center, spacing: 8) {
                        Button { openInCalendar() } label: {
                            eventSummary(event)
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity, alignment: .leading)

                        if let meetingLink = event.meetingLink {
                            Button { openMeeting(meetingLink) } label: {
                                Image(systemName: meetingLink.provider.actionSystemImage)
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.black)
                                    .frame(width: 28, height: 28)
                                    .background(AlcovePalette.accent, in: Circle())
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(meetingLink.provider.actionTitle)
                            .help(meetingLink.provider.actionTitle)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 22).padding(.top, 17)
    }

    private func eventSummary(_ event: CalendarEvent) -> some View {
        HStack(alignment: .top, spacing: 9) {
            Capsule()
                .fill(event.calendarColor.map { Color(nsColor: $0) } ?? AlcovePalette.accent)
                .frame(width: 3)
                .frame(minHeight: 39)
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .lineLimit(1)
                Text(timeDescription(for: event))
                    .font(.system(size: 10.5, weight: .medium, design: .monospaced))
                    .foregroundStyle(AlcovePalette.secondaryText)
                if let location = MeetingLinkResolver.physicalLocation(from: event.location) {
                    Label(location, systemImage: "mappin.and.ellipse")
                        .font(.system(size: 10.5))
                        .foregroundStyle(AlcovePalette.secondaryText)
                        .lineLimit(1)
                } else if let location = event.location,
                          let locationLink = MeetingLinkResolver.resolve(
                              eventURL: nil,
                              location: location,
                              notes: nil
                          ) {
                    Label(locationLink.provider.displayName, systemImage: "video")
                        .font(.system(size: 10.5))
                        .foregroundStyle(AlcovePalette.secondaryText)
                }
            }
            Spacer(minLength: 0)
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityHint("Opens Calendar")
    }

    private func openInCalendar() {
        NSWorkspace.shared.open(URL(string: "ical://")!)
    }

    private func openMeeting(_ meetingLink: MeetingLink) {
        NSWorkspace.shared.open(meetingLink.url)
    }

    private func timeDescription(for event: CalendarEvent) -> String {
        event.isAllDay ? "All day" : "\(event.startDate.shortTime)–\(event.endDate.shortTime)"
    }
}
