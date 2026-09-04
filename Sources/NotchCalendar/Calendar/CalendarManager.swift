@preconcurrency import EventKit
import AppKit
import SwiftUI

@MainActor
final class CalendarManager: ObservableObject {
    @Published private(set) var todayEvents: [CalendarEvent] = []
    @Published private(set) var authorizationMessage: String?

    private let store = EKEventStore()
    private nonisolated(unsafe) var databaseObserver: NSObjectProtocol?
    private var hasCalendarAccess: Bool {
        EKEventStore.authorizationStatus(for: .event) == .fullAccess
    }

    init() {
        databaseObserver = NotificationCenter.default.addObserver(
            forName: .EKEventStoreChanged, object: store, queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        }
        let status = EKEventStore.authorizationStatus(for: .event)
        if status == .fullAccess {
            refresh()
        } else if status == .notDetermined {
            // An installed app has a different privacy identity from the Xcode
            // debug executable, so request access on its first launch.
            requestAccess()
        } else {
            authorizationMessage = "Allow Calendar access in System Settings to show your agenda."
        }
    }

    deinit { if let databaseObserver { NotificationCenter.default.removeObserver(databaseObserver) } }

    func requestAccess() {
        // EventKit invokes this completion on its CalendarAgent XPC queue.
        // Giving the callback an explicit Sendable type prevents it from
        // inheriting MainActor isolation from this method before we hop back.
        let completion: @Sendable (Bool, Error?) -> Void = { [weak self] granted, error in
            let errorMessage = error?.localizedDescription
            Task { @MainActor [weak self, errorMessage] in
                guard let self else { return }
                if granted {
                    self.authorizationMessage = nil
                    self.refresh()
                } else {
                    self.authorizationMessage = errorMessage
                        ?? "Allow Calendar access in System Settings to show your agenda."
                }
            }
        }
        store.requestFullAccessToEvents(completion: completion)
    }

    func refresh() {
        guard hasCalendarAccess else {
            todayEvents = []
            authorizationMessage = "Allow Calendar access in System Settings to show your agenda."
            return
        }
        authorizationMessage = nil
        loadEvents(from: Date().startOfDay, to: Date().endOfDay)
    }

    func openPrivacySettings() {
        guard let url = URL(
            string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars"
        ) else { return }
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
        guard hasCalendarAccess else { return [] }
        let predicate = store.predicateForEvents(withStart: start, end: end, calendars: nil)
        return store.events(matching: predicate).map(makeEvent).sorted { $0.startDate < $1.startDate }
    }

    private func loadEvents(from start: Date, to end: Date) {
        guard hasCalendarAccess else {
            todayEvents = []
            return
        }
        let predicate = store.predicateForEvents(withStart: start, end: end, calendars: nil)
        todayEvents = store.events(matching: predicate).map(makeEvent).sorted { $0.startDate < $1.startDate }
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
                      isAllDay: event.isAllDay)
    }
}
