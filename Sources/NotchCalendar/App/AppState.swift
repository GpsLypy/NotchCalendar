import AppKit
import SwiftUI
import Combine
import WidgetKit

@MainActor
final class AppState: ObservableObject {
    @Published var calendar: CalendarManager
    let defaults: UserDefaults
    let focusTimer: FocusTimerModel
    let updateChecker = UpdateChecker()
    let presentationPreferences: PresentationPreferences
    let notesStore: MeetingNotesStore
    let backupStore: LocalBackupStore
    let meetingAssistant: MeetingAssistant
    var openWorkspace: ((WorkspaceDestination) -> Void)?
    @Published var selectedDate = Date()
    /// Desired hover state. The controller may keep the visual expanded briefly
    /// while its shrink animation completes.
    @Published var isExpanded = false
    @Published var isPresentationExpanded = false

    private var focusClock: Timer?
    private var focusDeadline: Date?
    private var focusObserver: AnyCancellable?
    private var calendarDayTimer: Timer?
    private var calendarObserver: AnyCancellable?
    private var timeContextObservers: Set<AnyCancellable> = []
    private var widgetSnapshotCoordinator: WidgetSnapshotCoordinator?
    private var lastSystemTimeRefreshAt: Date?

    init(
        calendar: CalendarManager? = nil,
        defaults: UserDefaults = .standard,
        recoveryDirectory: URL? = nil,
        meetingAssistant: MeetingAssistant? = nil,
        reloadWidgetTimelines: @escaping @MainActor (String) -> Void = { WidgetCenter.shared.reloadTimelines(ofKind: $0) }
    ) {
        let calendar = calendar ?? CalendarManager(defaults: defaults)
        let focusTimer = FocusTimerModel(defaults: defaults)
        self.defaults = defaults
        self.calendar = calendar
        self.focusTimer = focusTimer
        presentationPreferences = PresentationPreferences(defaults: defaults)
        notesStore = MeetingNotesStore(defaults: defaults)
        backupStore = LocalBackupStore(defaults: defaults, recoveryDirectory: recoveryDirectory)
        self.meetingAssistant = meetingAssistant ?? MeetingAssistant(calendar: calendar, preferences: MeetingPreferences(defaults: defaults))
        calendarObserver = calendar.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
        focusObserver = focusTimer.objectWillChange.sink { [weak self] _ in
            // Published properties announce before mutation. Read the complete
            // snapshot after the current action, then retain an unchanged deadline.
            DispatchQueue.main.async { [weak self] in self?.scheduleFocusCompletion() }
        }
        scheduleFocusCompletion()
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
            focusTimer: focusTimer,
            defaults: defaults,
            reloadTimelines: reloadWidgetTimelines
        )
    }

    private func scheduleFocusCompletion() {
        let deadline = focusTimer.isRunning ? focusTimer.widgetTargetDate : nil
        guard deadline != focusDeadline else { return }
        focusClock?.invalidate()
        focusClock = nil
        focusDeadline = deadline
        guard let deadline else { return }
        let timer = Timer(timeInterval: max(0.01, deadline.timeIntervalSinceNow), repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.focusDeadline = nil
                self.focusClock = nil
                self.focusTimer.synchronize(now: Date())
                self.scheduleFocusCompletion()
            }
        }
        focusClock = timer
        RunLoop.main.add(timer, forMode: .common)
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
        // A wall-clock correction can move an already scheduled Timer deadline.
        focusDeadline = nil
        focusClock?.invalidate()
        scheduleFocusCompletion()
        selectedDate = now
        if lastSystemTimeRefreshAt.map({ abs(now.timeIntervalSince($0)) >= 1 }) ?? true {
            lastSystemTimeRefreshAt = now
            calendar.refresh()
        }
        scheduleNextCalendarDayRefresh(now: now)
        PresentationDiagnostics.event("calendar refreshed reason=system-time-context")
    }
}
