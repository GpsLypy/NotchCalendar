import Foundation
import Combine

/// Only merges exact representations from different calendars. Distinct events
/// on the same calendar and recurrence occurrences always remain separate.
enum CalendarDuplicatePolicy {
    static let storageKey = "calendar.deduplicatesEvents"

    private struct Key: Hashable {
        let title: String
        let start: Date
        let end: Date
        let isAllDay: Bool
        let location: String
        let meetingURL: String
        let blocksTime: Bool
        let isEligibleForMeeting: Bool
        let isRecurring: Bool
    }

    static func events(_ events: [CalendarEvent], enabled: Bool) -> [CalendarEvent] {
        let sorted = events.sorted {
            if $0.startDate != $1.startDate { return $0.startDate < $1.startDate }
            if $0.calendarID != $1.calendarID { return $0.calendarID < $1.calendarID }
            return $0.id < $1.id
        }
        guard enabled else { return sorted }
        var result: [CalendarEvent] = []
        var groups: [Key: [Int]] = [:]
        var sourceIDs: [Int: Set<String>] = [:]
        for event in sorted {
            // Unknown origins (including old fixtures) cannot be merged safely.
            guard !event.calendarID.isEmpty else {
                result.append(event)
                continue
            }
            let key = Key(title: event.title, start: event.startDate, end: event.endDate,
                          isAllDay: event.isAllDay, location: event.location ?? "",
                          meetingURL: event.meetingLink?.url.absoluteString ?? "",
                          blocksTime: event.blocksTime, isEligibleForMeeting: event.isEligibleForMeeting,
                          isRecurring: event.isRecurring)
            if let index = groups[key]?.first(where: { !(sourceIDs[$0] ?? []).contains(event.calendarID) }) {
                result[index].duplicateSourceNames = result[index].displayedSourceNames + event.displayedSourceNames
                result[index].relatedOccurrenceIDs = Array(Set(result[index].allOccurrenceStableIDs + event.allOccurrenceStableIDs)).sorted()
                sourceIDs[index, default: []].insert(event.calendarID)
            } else {
                let index = result.count
                result.append(event)
                groups[key, default: []].append(index)
                sourceIDs[index] = [event.calendarID]
            }
        }
        return result
    }
}

struct CalendarSearchResult: Equatable {
    let events: [CalendarEvent]
    let totalCount: Int
    var isTruncated: Bool { totalCount > events.count }
}

enum CalendarSearchEngine {
    static let resultLimit = 200
    static let maximumRangeDays = 366

    static func defaultRange(now: Date = Date(), calendar: Calendar = .current) -> DateInterval {
        let start = calendar.startOfDay(for: now)
        return DateInterval(start: calendar.date(byAdding: .day, value: -30, to: start)!,
                            end: calendar.date(byAdding: .day, value: 91, to: start)!)
    }

    static func search(_ events: [CalendarEvent], query: String, limit: Int = resultLimit) -> CalendarSearchResult {
        let terms = query.split(whereSeparator: \.isWhitespace).map(String.init)
        let matches = events.filter { event in
            let text = ([event.title, event.location ?? ""] + event.displayedSourceNames).joined(separator: "\n")
            return terms.allSatisfy { text.localizedStandardContains($0) }
        }.sorted { $0.startDate == $1.startDate ? $0.occurrenceStableID < $1.occurrenceStableID : $0.startDate < $1.startDate }
        return CalendarSearchResult(events: Array(matches.prefix(max(0, limit))), totalCount: matches.count)
    }

    static func interval(from firstDay: Date, through lastDay: Date, calendar: Calendar = .current) -> DateInterval? {
        let start = calendar.startOfDay(for: firstDay)
        let last = calendar.startOfDay(for: lastDay)
        guard let end = calendar.date(byAdding: .day, value: 1, to: last), end > start,
              let days = calendar.dateComponents([.day], from: start, to: end).day,
              days <= maximumRangeDays else { return nil }
        return DateInterval(start: start, end: end)
    }
}

enum CalendarRepeatRule: String, CaseIterable, Identifiable {
    case never, daily, weekly, monthly
    var id: String { rawValue }
    var titleKey: String {
        switch self {
        case .never: "Does not repeat"
        case .daily: "Every day"
        case .weekly: "Every week"
        case .monthly: "Every month"
        }
    }
}

enum CalendarDraftError: Error, LocalizedError, Equatable {
    case missingTitle, invalidDates, invalidTimeZone, invalidLink, calendarUnavailable, accessDenied
    case invalidRepeatEnd, creationUnavailable

    var errorDescription: String? {
        switch self {
        case .missingTitle: "Add a title before saving."
        case .invalidDates: "The end must be after the start."
        case .invalidTimeZone: "Choose a valid time zone."
        case .invalidLink: "Enter a complete http or https link."
        case .calendarUnavailable: "Choose a writable calendar. Read-only calendars cannot save events."
        case .accessDenied: "Allow Calendar access in System Settings to create events."
        case .invalidRepeatEnd: "Choose a repeat end on or after the first event and within two years."
        case .creationUnavailable: "This calendar cannot create events."
        }
    }
}

struct CalendarEventDraft: Equatable {
    var title = ""
    var startDate: Date
    var endDate: Date
    var isAllDay = false
    var timeZoneIdentifier = TimeZone.current.identifier
    var calendarID = ""
    var location = ""
    var link = ""
    var repeatRule: CalendarRepeatRule = .never
    var repeatThrough: Date

    init(startDate: Date = Date(), calendarID: String = "") {
        self.startDate = startDate
        self.endDate = startDate.addingTimeInterval(1_800)
        self.repeatThrough = Calendar.current.date(byAdding: .month, value: 3, to: startDate)!
        self.calendarID = calendarID
    }

    var timeZone: TimeZone? { TimeZone(identifier: timeZoneIdentifier) }
    var eventURL: URL? { URL(string: link.trimmingCharacters(in: .whitespacesAndNewlines)) }

    /// All-day end in the editor is inclusive; EventKit expects an exclusive
    /// midnight in the chosen zone. Calendar arithmetic handles DST correctly.
    func datesForSaving() throws -> DateInterval {
        guard let timeZone else { throw CalendarDraftError.invalidTimeZone }
        if isAllDay {
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = timeZone
            let start = calendar.startOfDay(for: startDate)
            let lastDay = calendar.startOfDay(for: endDate)
            guard lastDay >= start, let end = calendar.date(byAdding: .day, value: 1, to: lastDay) else {
                throw CalendarDraftError.invalidDates
            }
            return DateInterval(start: start, end: end)
        }
        guard endDate > startDate else { throw CalendarDraftError.invalidDates }
        return DateInterval(start: startDate, end: endDate)
    }

    func validate(writableCalendarIDs: Set<String>) throws {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw CalendarDraftError.missingTitle }
        _ = try datesForSaving()
        guard writableCalendarIDs.contains(calendarID) else { throw CalendarDraftError.calendarUnavailable }
        if !link.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            guard let url = eventURL, ["http", "https"].contains(url.scheme?.lowercased() ?? ""),
                  let host = url.host, !host.isEmpty else { throw CalendarDraftError.invalidLink }
        }
        if repeatRule != .never {
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = timeZone!
            let firstDay = calendar.startOfDay(for: startDate)
            let lastDay = calendar.startOfDay(for: repeatThrough)
            guard lastDay >= firstDay,
                  let maximum = calendar.date(byAdding: .year, value: 2, to: firstDay), lastDay <= maximum else {
                throw CalendarDraftError.invalidRepeatEnd
            }
        }
    }
}

enum CalendarTimeZoneTools {
    static let secondaryStorageKey = "calendar.secondaryTimeZone"
    static let favorites = ["Asia/Shanghai", "Asia/Tokyo", "Asia/Singapore", "Europe/London", "Europe/Paris", "America/New_York", "America/Los_Angeles", "Australia/Sydney", "UTC"]

    static func search(_ query: String, locale: Locale = .current) -> [String] {
        let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty { return Array(NSOrderedSet(array: [TimeZone.current.identifier] + favorites)) as? [String] ?? favorites }
        return TimeZone.knownTimeZoneIdentifiers.filter { identifier in
            identifier.replacingOccurrences(of: "_", with: " ").localizedStandardContains(query)
            || (TimeZone(identifier: identifier)?.localizedName(for: .generic, locale: locale)?.localizedStandardContains(query) ?? false)
            || (TimeZone(identifier: identifier)?.localizedName(for: .shortGeneric, locale: locale)?.localizedStandardContains(query) ?? false)
        }
    }

    static func label(_ identifier: String, at date: Date, locale: Locale) -> String {
        guard let zone = TimeZone(identifier: identifier) else { return identifier }
        let seconds = zone.secondsFromGMT(for: date)
        let sign = seconds < 0 ? "−" : "+"
        let magnitude = abs(seconds)
        let offset = String(format: "%@%02d:%02d", sign, magnitude / 3_600, (magnitude % 3_600) / 60)
        return "\(identifier.split(separator: "/").last?.replacingOccurrences(of: "_", with: " ") ?? identifier) · UTC\(offset)"
    }

    static func time(_ date: Date, in identifier: String, locale: Locale, includeDate: Bool = true) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.timeZone = TimeZone(identifier: identifier) ?? .current
        formatter.dateStyle = includeDate ? .medium : .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

/// One in-memory draft per application session, retained when pages switch.
/// Kept separate from the manager publisher to avoid EventKit reloads per key.
@MainActor
final class CalendarDraftSession: ObservableObject {
    @Published var draft = CalendarEventDraft()
}
