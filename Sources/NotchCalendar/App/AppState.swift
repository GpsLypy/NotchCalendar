import SwiftUI
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published var calendar = CalendarManager()
    @Published var selectedDate = Date()
    /// Desired hover state. The controller may keep the visual expanded briefly
    /// while its shrink animation completes.
    @Published var isExpanded = false
    @Published var isPresentationExpanded = false

    private var clock: Timer?
    private var calendarObserver: AnyCancellable?

    init() {
        calendarObserver = calendar.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
        clock = .scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.calendar.refresh() }
        }
    }

    func toggleExpansion() { isExpanded.toggle() }
}
