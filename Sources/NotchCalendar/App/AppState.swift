import SwiftUI
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published var calendar: CalendarManager
    let focusTimer: FocusTimerModel
    let updateChecker = UpdateChecker()
    @Published var selectedDate = Date()
    /// Desired hover state. The controller may keep the visual expanded briefly
    /// while its shrink animation completes.
    @Published var isExpanded = false
    @Published var isPresentationExpanded = false

    private var clock: Timer?
    private var calendarObserver: AnyCancellable?
    private var widgetSnapshotCoordinator: WidgetSnapshotCoordinator?

    init() {
        let calendar = CalendarManager()
        let focusTimer = FocusTimerModel()
        self.calendar = calendar
        self.focusTimer = focusTimer
        calendarObserver = calendar.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
        clock = .scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                let now = Date()
                self.focusTimer.synchronize(now: now)
                self.calendar.refresh()
            }
        }
        widgetSnapshotCoordinator = WidgetSnapshotCoordinator(
            calendar: calendar,
            focusTimer: focusTimer
        )
    }

    func toggleExpansion() { isExpanded.toggle() }
}
