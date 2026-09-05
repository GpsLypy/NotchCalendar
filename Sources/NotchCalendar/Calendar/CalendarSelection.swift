import AppKit
import EventKit

struct CalendarSource: Identifiable, Equatable {
    let id: String
    let title: String
    let sourceTitle: String
    var color: NSColor? = nil
    var allowsContentModifications: Bool = false
}

enum CalendarSourceAvailability: Equatable {
    case needsPermission
    case noCalendars
    case noneSelected
    case available
}

/// Persist exclusions so a newly added calendar appears automatically. Keep
/// missing IDs: an account that temporarily disconnects must retain its choice.
struct CalendarSelectionPolicy: Equatable {
    static let storageKey = "calendar.excludedCalendarIDs"
    private(set) var excludedCalendarIDs: Set<String>

    init(excludedCalendarIDs: Set<String> = []) {
        self.excludedCalendarIDs = excludedCalendarIDs
    }

    init(defaults: UserDefaults) {
        excludedCalendarIDs = Set(defaults.stringArray(forKey: Self.storageKey) ?? [])
    }

    func isSelected(_ calendarID: String) -> Bool {
        !excludedCalendarIDs.contains(calendarID)
    }

    mutating func setSelected(_ calendarID: String, isSelected: Bool) {
        if isSelected {
            excludedCalendarIDs.remove(calendarID)
        } else {
            excludedCalendarIDs.insert(calendarID)
        }
    }

    mutating func selectAll() {
        excludedCalendarIDs.removeAll()
    }

    func save(to defaults: UserDefaults) {
        defaults.set(excludedCalendarIDs.sorted(), forKey: Self.storageKey)
    }

    func selectedIDs(availableCalendarIDs: [String]) -> Set<String> {
        Set(availableCalendarIDs.filter(isSelected))
    }

    func availability(hasAccess: Bool, availableCalendarIDs: [String]) -> CalendarSourceAvailability {
        guard hasAccess else { return .needsPermission }
        guard !availableCalendarIDs.isEmpty else { return .noCalendars }
        guard !selectedIDs(availableCalendarIDs: availableCalendarIDs).isEmpty else { return .noneSelected }
        return .available
    }

    /// An empty scope means "perform no query", never EventKit's implicit all.
    func queryCalendarIDs(hasAccess: Bool, availableCalendarIDs: [String]) -> Set<String>? {
        guard hasAccess else { return nil }
        let selected = selectedIDs(availableCalendarIDs: availableCalendarIDs)
        return selected.isEmpty ? nil : selected
    }
}

@MainActor
protocol CalendarDataSource {
    var authorizationStatus: EKAuthorizationStatus { get }
    var changeNotificationObject: AnyObject? { get }
    func availableCalendars() -> [CalendarSource]
    func events(from start: Date, to end: Date, calendarIDs: Set<String>) -> [CalendarEvent]
    func requestAccess(completion: @escaping @Sendable (Bool, Error?) -> Void)
    func createEvent(_ draft: CalendarEventDraft) throws -> CalendarEvent
}

extension CalendarDataSource {
    func createEvent(_ draft: CalendarEventDraft) throws -> CalendarEvent {
        throw CalendarDraftError.creationUnavailable
    }
}

enum CalendarEventAvailabilityPolicy {
    static func blocksTime(
        availability: EKEventAvailability,
        status: EKEventStatus,
        currentUserParticipationStatus: EKParticipantStatus?
    ) -> Bool {
        availability != .free && status != .canceled && currentUserParticipationStatus != .declined
    }
}
