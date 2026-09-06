#if NOTCH_QUALITY_PROBE
import EventKit
import AppKit
import SwiftUI
import Combine

/// Runs the real panel and hidden workspace, with an offline calendar and disposable
/// storage. The external sampler measures this process, not the sampler itself.
@MainActor
final class QualityProbe {
    enum ProbeError: Error { case unknownCommand }
    static let env = ProcessInfo.processInfo.environment
    static var dataSource: QualityCalendarDataSource!
    static var suite = "NotchQuality.\(UUID())"
    static func makeState() -> AppState {
        guard let directory = env["NOTCH_QUALITY_OUTPUT"], let scenario = env["NOTCH_QUALITY_SCENARIO"] else {
            fatalError("Quality probe requires an output directory and scenario")
        }
        precondition(["idle", "focus", "meeting-switch", "interaction"].contains(scenario))
        let output = URL(fileURLWithPath: directory, isDirectory: true)
        try! FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
        let defaults = UserDefaults(suiteName: suite)!
        defaults.set(AppLanguage.simplifiedChinese.rawValue, forKey: AppLanguage.storageKey)
        defaults.set(true, forKey: PresentationPreferences.meetingStatusKey)
        defaults.set(true, forKey: PresentationPreferences.focusStatusKey)
        let origin = Date()
        let events = scenario == "meeting-switch" ? (0..<4).map { index in
            QualityCalendarDataSource.event(id: "Quality meeting \(index + 1)",
                start: origin.addingTimeInterval(8 + Double(index) * 8),
                end: origin.addingTimeInterval(12 + Double(index) * 8))
        } : []
        dataSource = QualityCalendarDataSource(eventsByCalendarID: ["quality": events])
        let calendar = CalendarManager(dataSource: dataSource, defaults: defaults)
        let assistant = MeetingAssistant(calendar: calendar, preferences: MeetingPreferences(defaults: defaults),
            notifications: QualityNotifications(), hotKey: QualityHotKey(), openURL: { _ in false }, showError: { _ in })
        let state = AppState(calendar: calendar, defaults: defaults,
            recoveryDirectory: output.appendingPathComponent("recovery"), meetingAssistant: assistant,
            reloadWidgetTimelines: { _ in })
        if scenario != "idle" { state.focusTimer.toggle() }
        return state
    }

    static func run(state: AppState) async throws {
        let output = URL(fileURLWithPath: env["NOTCH_QUALITY_OUTPUT"]!, isDirectory: true)
        let scenario = env["NOTCH_QUALITY_SCENARIO"]!
        let duration = Double(env["NOTCH_QUALITY_SECONDS"] ?? "35") ?? 35
        let calendar = state.calendar
        let assistant = state.meetingAssistant
        let defaults = state.defaults
        defer { defaults.removePersistentDomain(forName: suite) }
        let application = NSApplication.shared
        application.setActivationPolicy(.accessory)
        let controller = NotchWindowController(state: state)
        controller.show()
        assistant.start()
        let panel = application.windows.first { $0 is NotchPanel }!
        // Keep the hidden workspace mounted, just as the production cold launch does.
        let workspace = NSWindow(contentRect: NSRect(x: 80, y: 80, width: 980, height: 620), styleMask: [.titled], backing: .buffered, defer: false)
        workspace.isReleasedWhenClosed = false
        let presentation = MainCalendarPresentation()
        workspace.contentView = NSHostingView(rootView: WorkspaceVisibilityHost(presentation: presentation) { MainWorkspaceView(calendar: calendar,
            focusTimer: state.focusTimer, updateChecker: state.updateChecker, presentation: presentation,
            notesStore: state.notesStore, meetingAssistant: assistant).defaultAppStorage(defaults) })
        defer { assistant.stop(); panel.orderOut(nil); workspace.orderOut(nil); workspace.close() }
        let visibility = QualityVisibilityRecorder(panel: panel)
        func snapshot() throws {
            let screens: [[String: Any]] = NSScreen.screens.map {
                ["name": $0.localizedName, "frame": NSStringFromRect($0.frame), "notch": ScreenGeometry.notchBounds(on: $0) != nil]
            }
            let status = UpcomingEventEngine.status(now: Date(), events: calendar.todayEvents)
            let activity = NotchActivityPolicy.compactActivity(showsMeetings: state.presentationPreferences.showsMeetingStatus, meetingIsActive: status.isActive,
                showsFocus: state.presentationPreferences.showsFocusStatus, hasFocusSession: state.focusTimer.hasUnfinishedSession)
            let value: [String: Any] = ["pid": ProcessInfo.processInfo.processIdentifier, "scenario": scenario,
                "screens": screens, "expanded": state.isExpanded, "renderExpanded": state.isPresentationExpanded,
                "key": panel.isKeyWindow, "passthrough": panel.ignoresMouseEvents,
                "frame": NSStringFromRect(panel.frame), "activity": String(describing: activity),
                "remaining": state.focusTimer.remainingSeconds, "running": state.focusTimer.isRunning,
                "mode": state.presentationPreferences.notchInteractionMode.rawValue,
                "showsMeetings": state.presentationPreferences.showsMeetingStatus,
                "showsFocus": state.presentationPreferences.showsFocusStatus,
                "pointerEvents": controller.pointerEventCount,
                "displayVisible": panel.occlusionState.contains(.visible),
                "occludedDuringSample": visibility.wasOccluded,
                "timestamp": Date().timeIntervalSince1970]
            try JSONSerialization.data(withJSONObject: value, options: [.prettyPrinted, .sortedKeys])
                .write(to: output.appendingPathComponent("state.json"), options: .atomic)
        }
        try await Task.sleep(for: .seconds(3))
        visibility.begin()
        try snapshot()
        if scenario == "interaction" {
            let end = Date().addingTimeInterval(duration)
            while Date() < end {
                let command = output.appendingPathComponent("command")
                if let text = try? String(contentsOf: command, encoding: .utf8) {
                    try FileManager.default.removeItem(at: command)
                    switch text.trimmingCharacters(in: .whitespacesAndNewlines) {
                    case "click": state.presentationPreferences.notchInteractionMode = .clickOnly
                    case "hover": state.presentationPreferences.notchInteractionMode = .intentionalHover
                    case "focus": state.focusTimer.toggle()
                    case "meeting":
                        dataSource.eventsByCalendarID["quality"] = [QualityCalendarDataSource.event(id: "Quality meeting", start: Date(), end: Date().addingTimeInterval(10))]
                        calendar.refresh()
                    case "stop": return
                    default: throw ProbeError.unknownCommand
                    }
                }
                try snapshot()
                try await Task.sleep(for: .milliseconds(200))
            }
        } else {
            // No probe polling or trace timers inside the process being measured.
            try await Task.sleep(for: .seconds(duration))
            try snapshot()
        }
        withExtendedLifetime(controller) {}
    }
}

@MainActor private final class QualityVisibilityRecorder {
    private(set) var wasOccluded = false
    private var isSampling = false
    private var observer: AnyCancellable?
    init(panel: NSWindow) {
        observer = NotificationCenter.default.publisher(for: NSWindow.didChangeOcclusionStateNotification, object: panel)
            .receive(on: RunLoop.main)
            .sink { [weak self, weak panel] _ in
                guard let self, self.isSampling else { return }
                if panel?.occlusionState.contains(.visible) != true { self.wasOccluded = true }
            }
    }
    func begin() { isSampling = true }
}

@MainActor private final class QualityNotifications: MeetingNotificationScheduling {
    func authorization() async -> MeetingNotificationAuthorization { .denied }
    func requestAuthorization() async throws -> Bool { false }
    func prepare(language: AppLanguage) {}
    func pending() async -> [String: String] { [:] }
    func delivered() async -> [MeetingDeliveredReminder] { [] }
    func removePending(_ identifiers: [String]) {}
    func removeDelivered(_ identifiers: [String]) {}
    func add(_ plan: MeetingReminderPlan, language: AppLanguage) async throws {}
}
@MainActor private final class QualityHotKey: MeetingHotKeyRegistering {
    func register(letter: String, modifiers: MeetingHotKeyModifiers, action: @escaping @MainActor () -> Void) -> Bool { true }
    func unregister() {}
}

@MainActor
final class QualityCalendarDataSource: CalendarDataSource {
    struct Query {
        let start: Date
        let end: Date
        let calendarIDs: Set<String>
    }
    var authorizationStatus: EKAuthorizationStatus = .fullAccess
    var changeNotificationObject: AnyObject? { self }
    var calendars: [CalendarSource]
    var eventsByCalendarID: [String: [CalendarEvent]]
    private(set) var queries: [Query] = []
    private(set) var accessRequestCount = 0

    init(eventsByCalendarID: [String: [CalendarEvent]], calendars: [CalendarSource]? = nil) {
        self.eventsByCalendarID = eventsByCalendarID
        self.calendars = calendars ?? eventsByCalendarID.keys.sorted().map {
            CalendarSource(id: $0, title: $0.capitalized, sourceTitle: "Test account")
        }
    }

    func availableCalendars() -> [CalendarSource] { calendars }
    func events(from start: Date, to end: Date, calendarIDs: Set<String>) -> [CalendarEvent] {
        queries.append(Query(start: start, end: end, calendarIDs: calendarIDs))
        return calendarIDs.flatMap { eventsByCalendarID[$0] ?? [] }.filter {
            $0.startDate < end && $0.endDate > start
        }
    }
    func requestAccess(completion: @escaping @Sendable (Bool, Error?) -> Void) {
        accessRequestCount += 1
        completion(authorizationStatus == .fullAccess, nil)
    }
    static func event(id: String, start: Date, end: Date) -> CalendarEvent {
        CalendarEvent(id: id, title: id, startDate: start, endDate: end,
                      calendarName: "Work", calendarColor: .systemBlue,
                      location: nil, meetingLink: nil, isAllDay: false)
    }
}

#endif
