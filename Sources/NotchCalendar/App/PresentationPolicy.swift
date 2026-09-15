import Foundation
import OSLog

enum NotchInteractionMode: String, CaseIterable, Identifiable, Sendable {
    case intentionalHover
    case clickOnly

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .intentionalHover: "Intentional hover"
        case .clickOnly: "Click only"
        }
    }
}

enum NotchHoverResponse: String, CaseIterable, Identifiable, Sendable {
    case fast
    case balanced
    case deliberate

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .fast: "Fast"
        case .balanced: "Balanced"
        case .deliberate: "Deliberate"
        }
    }

    var dwell: Duration {
        switch self {
        case .fast: .milliseconds(70)
        case .balanced: .milliseconds(140)
        case .deliberate: .milliseconds(300)
        }
    }

    var expansionDuration: TimeInterval {
        switch self {
        case .fast: 0.18
        case .balanced: 0.20
        case .deliberate: 0.28
        }
    }
}

struct NotchInteractionPolicy {
    static func effectiveMode(
        requestedMode: NotchInteractionMode,
        isGlobalMouseMonitorAvailable: Bool
    ) -> NotchInteractionMode {
        guard requestedMode == .intentionalHover,
              !isGlobalMouseMonitorAvailable else { return requestedMode }
        return .clickOnly
    }
}

@MainActor
final class PresentationPreferences: ObservableObject {
    static let interactionModeKey = "presentation.notchInteractionMode"
    static let meetingStatusKey = "presentation.showsMeetingStatus"
    static let focusStatusKey = "presentation.showsFocusStatus"
    static let hoverResponseKey = "presentation.notchHoverResponse"

    @Published var showsFocusStatus: Bool {
        didSet {
            guard oldValue != showsFocusStatus else { return }
            defaults.set(showsFocusStatus, forKey: Self.focusStatusKey)
        }
    }

    @Published var notchInteractionMode: NotchInteractionMode {
        didSet {
            guard oldValue != notchInteractionMode else { return }
            defaults.set(notchInteractionMode.rawValue, forKey: Self.interactionModeKey)
        }
    }

    @Published var showsMeetingStatus: Bool {
        didSet {
            guard oldValue != showsMeetingStatus else { return }
            defaults.set(showsMeetingStatus, forKey: Self.meetingStatusKey)
        }
    }

    @Published var hoverResponse: NotchHoverResponse {
        didSet {
            guard oldValue != hoverResponse else { return }
            defaults.set(hoverResponse.rawValue, forKey: Self.hoverResponseKey)
        }
    }

    @Published private(set) var isHoverMonitorAvailable = true

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        notchInteractionMode = defaults.string(forKey: Self.interactionModeKey)
            .flatMap(NotchInteractionMode.init(rawValue:))
            ?? .intentionalHover
        // Meeting shoulders can resize over another app without any pointer
        // interaction. Keep that opt-in so an upgrade never creates a surprise.
        showsMeetingStatus = defaults.object(forKey: Self.meetingStatusKey) as? Bool ?? false
        showsFocusStatus = defaults.object(forKey: Self.focusStatusKey) as? Bool ?? true
        hoverResponse = defaults.string(forKey: Self.hoverResponseKey)
            .flatMap(NotchHoverResponse.init(rawValue:)) ?? .balanced
    }

    func setHoverMonitorAvailable(_ isAvailable: Bool) {
        guard isHoverMonitorAvailable != isAvailable else { return }
        isHoverMonitorAvailable = isAvailable
    }

    func reload() {
        notchInteractionMode = defaults.string(forKey: Self.interactionModeKey)
            .flatMap(NotchInteractionMode.init(rawValue:)) ?? .intentionalHover
        showsMeetingStatus = defaults.object(forKey: Self.meetingStatusKey) as? Bool ?? false
        showsFocusStatus = defaults.object(forKey: Self.focusStatusKey) as? Bool ?? true
        hoverResponse = defaults.string(forKey: Self.hoverResponseKey)
            .flatMap(NotchHoverResponse.init(rawValue:)) ?? .balanced
    }
}

/// Main-window presentation is driven by semantic AppKit events, never by an
/// activation timer. A passive launch (for example a system relaunch) and the
/// updater handoff keep the app quiet. A provenance-free "open untitled" event
/// is quiet too; only a Dock reopen or explicit widget destination may reveal
/// and activate the workspace.
enum WindowPresentationIntent: Sendable {
    case passiveColdLaunch
    case updateHandoff
    case provenanceFreeOpen
    case dockReopen
    case deepLink
}

struct WindowPresentationPolicy {
    static func revealsMainWindow(for intent: WindowPresentationIntent) -> Bool {
        switch intent {
        case .passiveColdLaunch, .updateHandoff, .provenanceFreeOpen:
            false
        case .dockReopen, .deepLink:
            true
        }
    }

    static func activatesApplication(for intent: WindowPresentationIntent) -> Bool {
        revealsMainWindow(for: intent)
    }
}

enum PresentationDiagnostics {
    private static let logger = Logger(
        subsystem: "com.codex.notch-calendar",
        category: "presentation"
    )

    static func event(_ message: String) {
        logger.notice("\(message, privacy: .public)")
    }

    static func debug(_ message: String) {
        logger.debug("\(message, privacy: .public)")
    }
}
