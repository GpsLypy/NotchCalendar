@preconcurrency import EventKit
import AppKit
import SwiftUI

@MainActor
final class CalendarManager: ObservableObject {
    let creationDraft = CalendarDraftSession()
    @Published private(set) var todayEvents: [CalendarEvent] = []
    @Published private(set) var planningEvents: [CalendarEvent] = []
    @Published private(set) var availableCalendars: [CalendarSource] = []
    @Published private(set) var selection: CalendarSelectionPolicy
    @Published private(set) var authorizationMessage: String?
    @Published private(set) var deduplicatesEvents: Bool
    // A change outside today must still invalidate the month and widget caches.
    @Published private(set) var contentRevision = 0

    private let dataSource: any CalendarDataSource
    private let defaults: UserDefaults
    private nonisolated(unsafe) var databaseObserver: NSObjectProtocol?
    private nonisolated(unsafe) var activationObserver: NSObjectProtocol?
    private var hasCalendarAccess: Bool { dataSource.authorizationStatus == .fullAccess }

    var isCalendarAccessGranted: Bool { hasCalendarAccess }
    var selectedCalendarCount: Int {
        selection.selectedIDs(availableCalendarIDs: availableCalendars.map(\.id)).count
    }
    var sourceAvailability: CalendarSourceAvailability {
        selection.availability(hasAccess: hasCalendarAccess, availableCalendarIDs: availableCalendars.map(\.id))
    }
    var availabilityMessage: String? {
        switch sourceAvailability {
        case .needsPermission:
            authorizationMessage ?? "Allow Calendar access in System Settings to show your agenda."
        case .noCalendars:
            "No system calendars found. Add an account or calendar in Calendar, then refresh."
        case .noneSelected:
            "All calendars are hidden. Show a calendar to restore your agenda and planning."
        case .available:
            nil
        }
    }

    init(dataSource: any CalendarDataSource = EventKitCalendarDataSource(), defaults: UserDefaults = .standard) {
        self.dataSource = dataSource
        self.defaults = defaults
        selection = CalendarSelectionPolicy(defaults: defaults)
        deduplicatesEvents = defaults.object(forKey: CalendarDuplicatePolicy.storageKey) as? Bool ?? true
        databaseObserver = NotificationCenter.default.addObserver(
            forName: .EKEventStoreChanged, object: dataSource.changeNotificationObject, queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        }
        activationObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didBecomeActiveNotification, object: nil, queue: .main
        ) { [weak self] _ in
            // Calendar permissions and accounts may have changed in Settings.
            Task { @MainActor in self?.refresh() }
        }
        if hasCalendarAccess {
            refresh()
        } else if dataSource.authorizationStatus == .notDetermined {
            requestAccess()
        } else {
            authorizationMessage = "Allow Calendar access in System Settings to show your agenda."
        }
    }

    deinit {
        if let databaseObserver { NotificationCenter.default.removeObserver(databaseObserver) }
        if let activationObserver { NotificationCenter.default.removeObserver(activationObserver) }
    }

    func requestAccess() {
        // EventKit invokes this completion on its CalendarAgent XPC queue.
        // Giving the callback an explicit Sendable type prevents it from
        // inheriting MainActor isolation before we hop back.
        let completion: @Sendable (Bool, Error?) -> Void = { [weak self] granted, error in
            let errorMessage = error?.localizedDescription
            Task { @MainActor [weak self, errorMessage] in
                guard let self else { return }
                self.refresh()
                if !granted, let errorMessage { self.authorizationMessage = errorMessage }
            }
        }
        dataSource.requestAccess(completion: completion)
    }

    func refresh(now: Date = Date()) {
        // Notify even if only a future month's events changed in EventKit.
        defer { contentRevision &+= 1 }
        guard hasCalendarAccess else {
            if !todayEvents.isEmpty { todayEvents = [] }
            if !planningEvents.isEmpty { planningEvents = [] }
            if !availableCalendars.isEmpty { availableCalendars = [] }
            let message = "Allow Calendar access in System Settings to show your agenda."
            if authorizationMessage != message { authorizationMessage = message }
            return
        }
        if authorizationMessage != nil { authorizationMessage = nil }
        let calendars = dataSource.availableCalendars().sorted {
            let sourceOrder = $0.sourceTitle.localizedStandardCompare($1.sourceTitle)
            if sourceOrder != .orderedSame { return sourceOrder == .orderedAscending }
            let titleOrder = $0.title.localizedStandardCompare($1.title)
            return titleOrder == .orderedSame ? $0.id < $1.id : titleOrder == .orderedAscending
        }
        if calendars != availableCalendars { availableCalendars = calendars }
        let dayStart = Calendar.current.startOfDay(for: now)
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: dayStart)!
        let fetched = events(from: dayStart.addingTimeInterval(-30 * 60), to: nextDay.addingTimeInterval(30 * 60))
        if fetched != planningEvents { planningEvents = fetched }
        let today = fetched.filter { $0.occurs(on: now) }
        if today != todayEvents { todayEvents = today }
    }

    func isCalendarSelected(_ id: String) -> Bool { selection.isSelected(id) }

    func setCalendarSelected(_ id: String, isSelected: Bool) {
        guard availableCalendars.contains(where: { $0.id == id }),
              selection.isSelected(id) != isSelected else { return }
        selection.setSelected(id, isSelected: isSelected)
        selection.save(to: defaults)
        refresh()
    }

    func selectAllCalendars() {
        guard !selection.excludedCalendarIDs.isEmpty else { return }
        selection.selectAll()
        selection.save(to: defaults)
        refresh()
    }

    func reloadPreferences() {
        selection = CalendarSelectionPolicy(defaults: defaults)
        deduplicatesEvents = defaults.object(forKey: CalendarDuplicatePolicy.storageKey) as? Bool ?? true
        refresh()
    }

    func setDeduplicatesEvents(_ enabled: Bool) {
        guard enabled != deduplicatesEvents else { return }
        deduplicatesEvents = enabled
        defaults.set(enabled, forKey: CalendarDuplicatePolicy.storageKey)
        refresh()
    }

    var writableCalendars: [CalendarSource] {
        availableCalendars.filter(\.allowsContentModifications)
    }

    /// User-initiated only. Failure leaves the view's draft intact.
    func createEvent(_ draft: CalendarEventDraft) throws -> CalendarEvent {
        guard hasCalendarAccess else { throw CalendarDraftError.accessDenied }
        try draft.validate(writableCalendarIDs: Set(writableCalendars.map(\.id)))
        let event = try dataSource.createEvent(draft)
        refresh()
        return event
    }

    func openPrivacySettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars") else { return }
        NSWorkspace.shared.open(url)
    }

    func events(for date: Date) -> [CalendarEvent] {
        events(from: date.startOfDay, to: date.endOfDay)
    }

    func events(inMonthContaining date: Date) -> [CalendarEvent] {
        let monthStart = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: date))!
        let monthEnd = Calendar.current.date(byAdding: .month, value: 1, to: monthStart)!
        return events(from: monthStart, to: monthEnd)
    }

    func events(from start: Date, to end: Date) -> [CalendarEvent] {
        guard end > start else { return [] }
        guard let calendarIDs = selection.queryCalendarIDs(
            hasAccess: hasCalendarAccess, availableCalendarIDs: availableCalendars.map(\.id)
        ) else { return [] }
        return CalendarDuplicatePolicy.events(
            dataSource.events(from: start, to: end, calendarIDs: calendarIDs),
            enabled: deduplicatesEvents
        )
    }
}

@MainActor
final class EventKitCalendarDataSource: CalendarDataSource {
    private let store = EKEventStore()
    var authorizationStatus: EKAuthorizationStatus { EKEventStore.authorizationStatus(for: .event) }
    var changeNotificationObject: AnyObject? { store }

    func requestAccess(completion: @escaping @Sendable (Bool, Error?) -> Void) {
        store.requestFullAccessToEvents(completion: completion)
    }

    func availableCalendars() -> [CalendarSource] {
        store.calendars(for: .event).map {
            CalendarSource(id: $0.calendarIdentifier, title: $0.title, sourceTitle: $0.source.title,
                           color: NSColor(cgColor: $0.cgColor),
                           allowsContentModifications: $0.allowsContentModifications)
        }
    }

    func events(from start: Date, to end: Date, calendarIDs: Set<String>) -> [CalendarEvent] {
        let selected = store.calendars(for: .event).filter { calendarIDs.contains($0.calendarIdentifier) }
        // EventKit treats nil/empty calendars as all calendars. Never issue that query.
        guard !selected.isEmpty else { return [] }
        let predicate = store.predicateForEvents(withStart: start, end: end, calendars: selected)
        return store.events(matching: predicate).map(makeEvent)
    }

    func createEvent(_ draft: CalendarEventDraft) throws -> CalendarEvent {
        guard authorizationStatus == .fullAccess else { throw CalendarDraftError.accessDenied }
        let writable = store.calendars(for: .event).filter(\.allowsContentModifications)
        try draft.validate(writableCalendarIDs: Set(writable.map(\.calendarIdentifier)))
        guard let calendar = writable.first(where: { $0.calendarIdentifier == draft.calendarID }) else {
            throw CalendarDraftError.calendarUnavailable
        }
        let interval = try draft.datesForSaving()
        let event = EKEvent(eventStore: store)
        event.calendar = calendar
        event.title = draft.title.trimmingCharacters(in: .whitespacesAndNewlines)
        event.startDate = interval.start
        event.endDate = interval.end
        event.isAllDay = draft.isAllDay
        event.timeZone = draft.timeZone
        let location = draft.location.trimmingCharacters(in: .whitespacesAndNewlines)
        event.location = location.isEmpty ? nil : location
        if !draft.link.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { event.url = draft.eventURL }
        if draft.repeatRule != .never {
            let frequency: EKRecurrenceFrequency
            switch draft.repeatRule {
            case .daily: frequency = .daily
            case .weekly: frequency = .weekly
            case .monthly: frequency = .monthly
            case .never: frequency = .daily
            }
            var calculationCalendar = Calendar(identifier: .gregorian)
            calculationCalendar.timeZone = draft.timeZone!
            let lastDay = calculationCalendar.startOfDay(for: draft.repeatThrough)
            let exclusiveEnd = calculationCalendar.date(byAdding: .day, value: 1, to: lastDay)!
            event.addRecurrenceRule(EKRecurrenceRule(
                recurrenceWith: frequency, interval: 1,
                end: EKRecurrenceEnd(end: exclusiveEnd.addingTimeInterval(-1))
            ))
        }
        // A new event contains no attendees. Existing events and invitations are
        // never edited by this path; EventKit commits only this new draft.
        try store.save(event, span: .thisEvent, commit: true)
        return makeEvent(event)
    }

    private func makeEvent(_ event: EKEvent) -> CalendarEvent {
        let occurrence = event.occurrenceDate ?? event.startDate!
        let isRecurring = event.hasRecurrenceRules || event.occurrenceDate != nil
        let occurrenceDay = event.isAllDay && isRecurring
            ? CalendarEvent.occurrenceDay(for: occurrence)
            : nil
        let instanceID = "\(event.eventIdentifier ?? event.calendarItemIdentifier)|\(occurrence.timeIntervalSinceReferenceDate)"
        return CalendarEvent(id: instanceID, title: event.title ?? "",
                      startDate: event.startDate, endDate: event.endDate,
                      calendarName: event.calendar.title, calendarColor: NSColor(cgColor: event.calendar.cgColor),
                      location: event.location,
                      meetingLink: MeetingLinkResolver.resolve(
                          eventURL: event.url,
                          location: event.location,
                          notes: event.notes
                      ),
                      isAllDay: event.isAllDay,
                      blocksTime: CalendarEventAvailabilityPolicy.blocksTime(
                          availability: event.availability,
                          status: event.status,
                          currentUserParticipationStatus: event.attendees?.first(where: \.isCurrentUser)?.participantStatus
                      ),
                      calendarID: event.calendar.calendarIdentifier,
                      originalOccurrenceDate: event.occurrenceDate,
                      originalOccurrenceDay: occurrenceDay,
                      // Server UID is shared by occurrences and survives a local
                      // store resync. Local calendars fall back to the item ID.
                      seriesIdentifier: event.calendarItemExternalIdentifier ?? event.calendarItemIdentifier,
                      isRecurring: isRecurring,
                      isEligibleForMeeting: event.status != .canceled
                          && event.attendees?.first(where: \.isCurrentUser)?.participantStatus != .declined)
    }
}
