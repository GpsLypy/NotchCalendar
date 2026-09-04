import AppKit
import Combine
import Foundation
import NotchCalendarShared
import WidgetKit

/// WidgetKit runs outside the app process and cannot safely request EventKit
/// access. Publish a minimal, read-only snapshot into the host preference domain
/// instead; the sandboxed widget receives read access to this domain only.
@MainActor
final class WidgetSnapshotCoordinator {
    private let calendar: CalendarManager
    private let focusTimer: FocusTimerModel
    private var cancellables: Set<AnyCancellable> = []
    private var calendarPublishTask: Task<Void, Never>?
    private var focusPublishTask: Task<Void, Never>?
    private var publishedLocalizationIdentifier: String

    init(calendar: CalendarManager, focusTimer: FocusTimerModel) {
        self.calendar = calendar
        self.focusTimer = focusTimer
        publishedLocalizationIdentifier = AppLanguage.persisted().localizationIdentifier

        calendar.objectWillChange
            .sink { [weak self] _ in self?.scheduleCalendarPublish() }
            .store(in: &cancellables)
        focusTimer.objectWillChange
            .sink { [weak self] _ in self?.scheduleFocusPublish() }
            .store(in: &cancellables)
        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .sink { [weak self] _ in self?.publishLanguageChangeIfNeeded() }
            .store(in: &cancellables)
        NotificationCenter.default.publisher(for: NSLocale.currentLocaleDidChangeNotification)
            .sink { [weak self] _ in self?.publishLanguageChangeIfNeeded() }
            .store(in: &cancellables)

        scheduleCalendarPublish()
        scheduleFocusPublish()
    }

    deinit {
        calendarPublishTask?.cancel()
        focusPublishTask?.cancel()
    }

    private func scheduleCalendarPublish() {
        calendarPublishTask?.cancel()
        calendarPublishTask = Task { @MainActor [weak self] in
            // ObservableObject announces immediately before a mutation. Yield so
            // related calendar changes collapse into one coherent snapshot.
            await Task.yield()
            guard !Task.isCancelled else { return }
            self?.publishCalendar()
        }
    }

    private func scheduleFocusPublish() {
        focusPublishTask?.cancel()
        focusPublishTask = Task { @MainActor [weak self] in
            await Task.yield()
            guard !Task.isCancelled else { return }
            self?.publishFocus()
        }
    }

    private func publishLanguageChangeIfNeeded() {
        let localizationIdentifier = AppLanguage.persisted().localizationIdentifier
        guard localizationIdentifier != publishedLocalizationIdentifier else { return }
        publishedLocalizationIdentifier = localizationIdentifier
        scheduleCalendarPublish()
        scheduleFocusPublish()
    }

    private func publishCalendar() {
        let now = Date()
        let calendarSnapshot = WidgetCalendarSnapshot(
            authorization: calendar.isCalendarAccessGranted ? .available : .needsPermission,
            events: calendar.events(inMonthContaining: now).map {
                WidgetEventSnapshot(event: $0)
            },
            localizationIdentifier: publishedLocalizationIdentifier,
            timeZoneIdentifier: TimeZone.autoupdatingCurrent.identifier
        )

        if WidgetSnapshotStore.writeCalendar(calendarSnapshot) {
            WidgetCenter.shared.reloadTimelines(ofKind: WidgetConstants.monthKind)
            WidgetCenter.shared.reloadTimelines(ofKind: WidgetConstants.agendaKind)
        }
    }

    private func publishFocus() {
        let targetDate = focusTimer.widgetTargetDate
        let existingSnapshot = WidgetSnapshotStore.readFocus(from: .standard)
        let remainingSecondsAtWrite: Int
        if focusTimer.isRunning,
           let targetDate,
           existingSnapshot?.isRunning == true,
           existingSnapshot?.targetDate == targetDate {
            // SwiftUI's timer views derive every displayed second from the stable
            // target date. Preserve the session-start upper bound so a normal
            // ticking update does not rewrite preferences or ask WidgetKit to
            // reload every second.
            remainingSecondsAtWrite = existingSnapshot?.remainingSecondsAtWrite
                ?? focusTimer.remainingSeconds
        } else {
            remainingSecondsAtWrite = focusTimer.remainingSeconds
        }

        let focusSnapshot = WidgetFocusSnapshot(
            selectedMinutes: focusTimer.selectedMinutes,
            remainingSecondsAtWrite: remainingSecondsAtWrite,
            isRunning: focusTimer.isRunning,
            targetDate: targetDate,
            completedSessions: focusTimer.completedSessions,
            localizationIdentifier: publishedLocalizationIdentifier
        )

        if WidgetSnapshotStore.writeFocus(focusSnapshot) {
            WidgetCenter.shared.reloadTimelines(ofKind: WidgetConstants.focusKind)
        }
    }
}

private extension WidgetEventSnapshot {
    init(event: CalendarEvent) {
        self.init(
            id: event.id,
            title: event.title,
            startDate: event.startDate,
            endDate: event.endDate,
            calendarName: event.calendarName,
            calendarColor: event.calendarColor.flatMap { WidgetRGBAColor(color: $0) },
            isAllDay: event.isAllDay
        )
    }
}

private extension WidgetRGBAColor {
    init?(color: NSColor) {
        guard let color = color.usingColorSpace(.sRGB) else { return nil }
        self.init(
            red: Double(color.redComponent),
            green: Double(color.greenComponent),
            blue: Double(color.blueComponent),
            alpha: Double(color.alphaComponent)
        )
    }
}
