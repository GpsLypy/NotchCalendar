import AppKit
import SwiftUI
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published var calendar: CalendarManager
    let focusTimer: FocusTimerModel
    let updateChecker = UpdateChecker()
    let presentationPreferences: PresentationPreferences
    let notesStore: MeetingNotesStore
    let backupStore: LocalBackupStore
    let meetingAssistant: MeetingAssistant
    @Published var selectedDate = Date()
    /// Desired hover state. The controller may keep the visual expanded briefly
    /// while its shrink animation completes.
    @Published var isExpanded = false
    @Published var isPresentationExpanded = false

    private var focusClock: Timer?
    private var calendarDayTimer: Timer?
    private var calendarObserver: AnyCancellable?
    private var timeContextObservers: Set<AnyCancellable> = []
    private var widgetSnapshotCoordinator: WidgetSnapshotCoordinator?
    private var lastSystemTimeRefreshAt: Date?

    init() {
        let calendar = CalendarManager()
        let focusTimer = FocusTimerModel()
        self.calendar = calendar
        self.focusTimer = focusTimer
        presentationPreferences = PresentationPreferences()
        notesStore = MeetingNotesStore()
        backupStore = LocalBackupStore()
        meetingAssistant = MeetingAssistant(calendar: calendar)
        calendarObserver = calendar.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
        focusClock = .scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                self.focusTimer.synchronize(now: Date())
            }
        }
        observeSystemTimeContext()
        // Restore is posted on MainActor. Reload before it returns so a queued timer
        // tick or shortcut cannot persist the pre-restore in-memory snapshot.
        NotificationCenter.default.publisher(for: .localBackupDidRestore)
            .sink { [weak self] _ in
                self?.reloadLocalPreferences()
            }
            .store(in: &timeContextObservers)
        scheduleNextCalendarDayRefresh()
        widgetSnapshotCoordinator = WidgetSnapshotCoordinator(
            calendar: calendar,
            focusTimer: focusTimer
        )
    }

    func toggleExpansion() { isExpanded.toggle() }

    private func reloadLocalPreferences() {
        notesStore.reload()
        focusTimer.reload()
        calendar.reloadPreferences()
        presentationPreferences.reload()
        meetingAssistant.reloadPreferences()
    }

    private func scheduleNextCalendarDayRefresh(now: Date = Date()) {
        calendarDayTimer?.invalidate()
        let calendar = Calendar.autoupdatingCurrent
        guard let nextDay = calendar.nextDate(
            after: now,
            matching: DateComponents(hour: 0, minute: 0, second: 1),
            matchingPolicy: .nextTime
        ) else { return }

        let timer = Timer(
            timeInterval: max(1, nextDay.timeIntervalSince(now)),
            repeats: false
        ) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                self.refreshAfterSystemTimeChange()
            }
        }
        calendarDayTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    private func observeSystemTimeContext() {
        let systemNotifications = [
            NotificationCenter.default.publisher(for: .NSCalendarDayChanged),
            NotificationCenter.default.publisher(for: .NSSystemClockDidChange),
            NotificationCenter.default.publisher(for: .NSSystemTimeZoneDidChange),
            NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.didWakeNotification)
        ]

        Publishers.MergeMany(systemNotifications)
            // Clock and wake notifications can arrive together. One run-loop
            // coalescing window avoids duplicate EventKit fetches while still
            // repairing the visible day immediately after wake or travel.
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.refreshAfterSystemTimeChange()
                }
            }
            .store(in: &timeContextObservers)
    }

    private func refreshAfterSystemTimeChange() {
        let now = Date()
        focusTimer.synchronize(now: now)
        selectedDate = now
        if lastSystemTimeRefreshAt.map({ abs(now.timeIntervalSince($0)) >= 1 }) ?? true {
            lastSystemTimeRefreshAt = now
            calendar.refresh()
        }
        scheduleNextCalendarDayRefresh(now: now)
        PresentationDiagnostics.event("calendar refreshed reason=system-time-context")
    }
}
