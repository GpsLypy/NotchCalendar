import Foundation

/// Shortcuts uses the same live stores as the app; a second timer or stale copy of a note is never created.
@MainActor
final class WorkspaceAutomation {
    static var shared: WorkspaceAutomation?
    let focusTimer: FocusTimerModel
    let notes: MeetingNotesStore
    let navigate: (WorkspaceDestination) -> Void
    let joinMeeting: () async throws -> Void

    init(focusTimer: FocusTimerModel, notes: MeetingNotesStore, navigate: @escaping (WorkspaceDestination) -> Void, joinMeeting: @escaping () async throws -> Void) {
        self.focusTimer = focusTimer
        self.notes = notes
        self.navigate = navigate
        self.joinMeeting = joinMeeting
    }

    static func ready() async throws -> WorkspaceAutomation {
        // An explicit shortcut can arrive while applicationDidFinishLaunching is constructing the window.
        for _ in 0..<100 {
            if let shared { return shared }
            try await Task.sleep(for: .milliseconds(20))
        }
        throw WorkspaceAutomationError("Open Notch Calendar and try the shortcut again.")
    }

    func startFocus(minutes: Int, taskLabel: String?, now: Date = Date()) throws {
        if let error = focusTimer.persistenceError { throw WorkspaceAutomationError(error) }
        guard FocusTimerModel.customMinuteRange.contains(minutes) else {
            throw WorkspaceAutomationError("Choose a focus duration from 5 to 180 minutes.")
        }
        focusTimer.synchronize(now: now)
        guard focusTimer.prepareFocus(minutes: minutes) else {
            throw WorkspaceAutomationError("A focus timer is already in progress. Finish or reset it first.")
        }
        focusTimer.setTaskLabel(taskLabel ?? "")
        focusTimer.toggle(now: now)
        navigate(.focus)
    }

    func appendScratchpad(text: String) throws {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw WorkspaceAutomationError("Enter text to append to the scratchpad.")
        }
        guard notes.appendScratchpad(text: text) else {
            throw WorkspaceAutomationError(notes.errorMessage ?? "Changes could not be saved. Keep this window open and try again.")
        }
        navigate(.scratchpad)
    }
}

struct WorkspaceAutomationError: LocalizedError {
    let key: String
    init(_ key: String) { self.key = key }
    var errorDescription: String? { L10n.string(key, language: AppLanguage(rawValue: UserDefaults.standard.string(forKey: "app.language") ?? "") ?? .system) }
}
