@preconcurrency import EventKit
import AppKit
import SwiftUI

@MainActor
final class CalendarManager: ObservableObject {
    @Published private(set) var todayEvents: [CalendarEvent] = []
    @Published private(set) var planningEvents: [CalendarEvent] = []
    @Published private(set) var availableCalendars: [CalendarSource] = []
    @Published private(set) var selection: CalendarSelectionPolicy
    @Published private(set) var authorizationMessage: String?
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

    private func events(from start: Date, to end: Date) -> [CalendarEvent] {
        guard let calendarIDs = selection.queryCalendarIDs(
            hasAccess: hasCalendarAccess, availableCalendarIDs: availableCalendars.map(\.id)
        ) else { return [] }
        return dataSource.events(from: start, to: end, calendarIDs: calendarIDs)
            .sorted { $0.startDate == $1.startDate ? $0.id < $1.id : $0.startDate < $1.startDate }
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
                           color: NSColor(cgColor: $0.cgColor))
        }
    }

    func events(from start: Date, to end: Date, calendarIDs: Set<String>) -> [CalendarEvent] {
        let selected = store.calendars(for: .event).filter { calendarIDs.contains($0.calendarIdentifier) }
        // EventKit treats nil/empty calendars as all calendars. Never issue that query.
        guard !selected.isEmpty else { return [] }
        let predicate = store.predicateForEvents(withStart: start, end: end, calendars: selected)
        return store.events(matching: predicate).map(makeEvent)
    }

    private func makeEvent(_ event: EKEvent) -> CalendarEvent {
        let fallbackID = "\(event.calendarItemIdentifier)|\(event.startDate.timeIntervalSinceReferenceDate)"
        return CalendarEvent(id: event.eventIdentifier ?? fallbackID, title: event.title ?? "",
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
                      ))
    }
}
