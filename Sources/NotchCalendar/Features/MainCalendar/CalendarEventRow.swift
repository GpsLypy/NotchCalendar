import AppKit
import SwiftUI

struct CalendarEventRow: View {
    let event: CalendarEvent
    var secondaryTimeZone = ""
    var showsDate = false
    var onSelectEvent: ((CalendarEvent) -> Void)? = nil
    @Environment(\.appLanguage) private var language

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            RoundedRectangle(cornerRadius: 2)
                .fill(event.calendarColor.map(Color.init(nsColor:)) ?? WorkspacePalette.accent)
                .frame(width: 3)
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 7) {
                    Text(event.displayTitle(language: language))
                        .font(.system(size: 13, weight: .semibold))
                        .lineLimit(2)
                    if event.isRecurring {
                        Image(systemName: "repeat")
                            .font(.system(size: 10))
                            .foregroundStyle(WorkspacePalette.secondaryText)
                            .help(t("Recurring event · each date is a separate occurrence"))
                            .accessibilityLabel(t("Recurring event"))
                    }
                }
                Text(primaryTime).font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(WorkspacePalette.secondaryText)
                if !secondaryTimeZone.isEmpty && !event.isAllDay {
                    Text(secondaryTime)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(WorkspacePalette.accent)
                        .fixedSize(horizontal: false, vertical: true)
                }
                HStack(spacing: 6) {
                    Text(event.calendarName)
                    if event.displayedSourceNames.count > 1 {
                        Text(t("%@ sources", "\(event.displayedSourceNames.count)"))
                            .foregroundStyle(WorkspacePalette.accent)
                            .help(event.displayedSourceNames.joined(separator: " · "))
                    }
                    if let location = MeetingLinkResolver.physicalLocation(from: event.location) {
                        Text("· \(location)")
                    }
                }
                .font(.system(size: 10))
                .foregroundStyle(WorkspacePalette.secondaryText)
                .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if let onSelectEvent {
                Button { onSelectEvent(event) } label: {
                    Image(systemName: "note.text")
                }
                .buttonStyle(.borderless)
                .accessibilityLabel(t("Meeting notes"))
                .help(t("Meeting notes"))
            }
            if let link = event.meetingLink, event.isEligibleForMeeting {
                Button { NSWorkspace.shared.open(link.url) } label: {
                    Label(link.provider.actionTitle(language: language), systemImage: link.provider.actionSystemImage)
                        .font(.system(size: 11, weight: .medium))
                }
                .buttonStyle(.bordered)
                .tint(WorkspacePalette.accent)
            }
        }
        .padding(14)
        .fixedSize(horizontal: false, vertical: true)
        .background(WorkspacePalette.elevated, in: RoundedRectangle(cornerRadius: 10))
        .foregroundStyle(WorkspacePalette.primaryText)
        .accessibilityElement(children: .contain)
    }

    private var primaryTime: String {
        if event.isAllDay {
            return showsDate
                ? "\(event.startDate.formatted(.dateTime.year().month(.abbreviated).day().locale(language.locale))) · \(t("All day"))"
                : t("All day")
        }
        return "\(CalendarTimeZoneTools.time(event.startDate, in: TimeZone.current.identifier, locale: language.locale, includeDate: showsDate)) – \(CalendarTimeZoneTools.time(event.endDate, in: TimeZone.current.identifier, locale: language.locale, includeDate: !Calendar.current.isDate(event.startDate, inSameDayAs: event.endDate)))"
    }

    private var secondaryTime: String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: secondaryTimeZone) ?? .current
        let start = CalendarTimeZoneTools.time(event.startDate, in: secondaryTimeZone, locale: language.locale)
        let end = CalendarTimeZoneTools.time(event.endDate, in: secondaryTimeZone, locale: language.locale, includeDate: !calendar.isDate(event.startDate, inSameDayAs: event.endDate))
        return "\(start) – \(end) · \(CalendarTimeZoneTools.label(secondaryTimeZone, at: event.startDate, locale: language.locale))"
    }

    private func t(_ key: String, _ arguments: CVarArg...) -> String {
        L10n.string(key, language: language, arguments: arguments)
    }
}
