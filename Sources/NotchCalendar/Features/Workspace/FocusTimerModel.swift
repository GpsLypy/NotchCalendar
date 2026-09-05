import Foundation
import SwiftUI

@MainActor
final class FocusTimerModel: ObservableObject {
    static let presets = [25, 50, 5]
    static let customMinuteRange = 5...180
    static let historyLimit = 1_000

    @Published private(set) var selectedMinutes = 25
    @Published private(set) var selectedKind: FocusSessionKind = .focus
    @Published private(set) var remainingSeconds = 25 * 60
    @Published private(set) var isRunning = false
    /// Includes the legacy cumulative total and completed breaks for compatibility.
    @Published private(set) var completedSessions = 0
    @Published private(set) var history: [FocusHistoryRecord] = []
    @Published private(set) var taskLabel = ""
    @Published private(set) var persistenceError: String?

    private static let snapshotKey = "workspace.focus.snapshot.v1"
    private static let completedSessionsKey = "workspace.focus.completedSessions"
    private static let selectedMinutesKey = "workspace.focus.selectedMinutes"
    private static let remainingSecondsKey = "workspace.focus.remainingSeconds"
    private static let isRunningKey = "workspace.focus.isRunning"
    private static let targetDateKey = "workspace.focus.targetDate"
    private var targetDate: Date?
    private var activeSessionID: UUID?
    private var lastPersistedRemainingSeconds: Int?
    private let defaults: UserDefaults

    private struct Snapshot: Codable {
        let selectedMinutes: Int
        let selectedKind: FocusSessionKind
        let remainingSeconds: Int
        let isRunning: Bool
        let targetDate: Date?
        let activeSessionID: UUID?
        let completedSessions: Int
        let history: [FocusHistoryRecord]
        let taskLabel: String?
    }

    init(defaults: UserDefaults = .standard, now: Date = Date()) {
        self.defaults = defaults
        reload(now: now)
    }

    func reload(now: Date = Date()) {
        targetDate = nil
        activeSessionID = nil
        isRunning = false
        history = []
        taskLabel = ""
        selectedMinutes = 25
        selectedKind = .focus
        remainingSeconds = 25 * 60
        completedSessions = 0
        persistenceError = nil
        if defaults.object(forKey: Self.snapshotKey) != nil {
            guard let data = defaults.data(forKey: Self.snapshotKey),
                  (try? JSONDecoder().decode(Snapshot.self, from: data)) != nil else {
                // Preserve damaged or future-format bytes for recovery; never overwrite them with an empty history.
                persistenceError = "Focus data could not be read. Restore a valid backup in Settings before starting a timer."
                return
            }
        }
        if let data = defaults.data(forKey: Self.snapshotKey),
           let snapshot = try? JSONDecoder().decode(Snapshot.self, from: data) {
            selectedMinutes = Self.customMinuteRange.contains(snapshot.selectedMinutes) ? snapshot.selectedMinutes : 25
            selectedKind = snapshot.selectedKind
            remainingSeconds = min(selectedMinutes * 60, max(0, snapshot.remainingSeconds))
            completedSessions = max(0, snapshot.completedSessions)
            history = Array(snapshot.history.sorted { $0.completedAt > $1.completedAt }.prefix(Self.historyLimit))
            taskLabel = String((snapshot.taskLabel ?? "").prefix(200))
            activeSessionID = snapshot.activeSessionID
            targetDate = snapshot.targetDate
            isRunning = snapshot.isRunning && targetDate != nil && remainingSeconds > 0
        } else {
            // Old cumulative counts have no dates or durations. Preserve them without inventing history.
            completedSessions = max(0, defaults.integer(forKey: Self.completedSessionsKey))
            let storedMinutes = defaults.integer(forKey: Self.selectedMinutesKey)
            selectedMinutes = Self.presets.contains(storedMinutes) ? storedMinutes : 25
            selectedKind = selectedMinutes == 5 ? .breakTime : .focus
            remainingSeconds = defaults.object(forKey: Self.remainingSecondsKey).map { _ in
                min(selectedMinutes * 60, max(0, defaults.integer(forKey: Self.remainingSecondsKey)))
            } ?? selectedMinutes * 60
            if defaults.bool(forKey: Self.isRunningKey), defaults.object(forKey: Self.targetDateKey) != nil {
                targetDate = Date(timeIntervalSinceReferenceDate: defaults.double(forKey: Self.targetDateKey))
                isRunning = remainingSeconds > 0
            }
            if isRunning || (remainingSeconds > 0 && remainingSeconds < selectedMinutes * 60) {
                activeSessionID = UUID()
            }
        }
        // Persist the session identity before reconciling an expired timer after a relaunch.
        if isRunning && activeSessionID == nil { activeSessionID = UUID() }
        persistState()
        synchronize(now: now)
    }

    /// Also protects a timer paused immediately after starting, before its first second elapsed.
    var hasUnfinishedSession: Bool {
        remainingSeconds > 0 && (isRunning || activeSessionID != nil)
    }

    var progress: Double {
        1 - (Double(remainingSeconds) / Double(selectedMinutes * 60))
    }

    var widgetTargetDate: Date? { targetDate }

    func setTaskLabel(_ value: String) {
        guard persistenceError == nil else { return }
        taskLabel = String(value.prefix(200))
        persistState()
    }

    var timeLabel: String {
        String(format: "%02d:%02d", remainingSeconds / 60, remainingSeconds % 60)
    }

    func summary(now: Date = Date(), calendar: Calendar = .current) -> FocusHistorySummary {
        FocusHistorySummary(records: history, now: now, calendar: calendar)
    }

    /// Calendar suggestions and custom durations prepare a paused timer, without replacing existing work.
    @discardableResult
    func prepareFocus(minutes: Int) -> Bool {
        guard persistenceError == nil, !hasUnfinishedSession, Self.customMinuteRange.contains(minutes) else { return false }
        prepare(minutes: minutes, kind: .focus)
        return true
    }

    /// Retains the original 25/50 focus and 5-minute break preset behavior.
    func select(minutes: Int) {
        guard persistenceError == nil, !hasUnfinishedSession, Self.presets.contains(minutes) else { return }
        prepare(minutes: minutes, kind: minutes == 5 ? .breakTime : .focus)
    }

    private func prepare(minutes: Int, kind: FocusSessionKind) {
        selectedMinutes = minutes
        selectedKind = kind
        remainingSeconds = minutes * 60
        targetDate = nil
        activeSessionID = nil
        isRunning = false
        persistState()
    }

    func toggle(now: Date = Date()) {
        guard persistenceError == nil else { return }
        if isRunning {
            synchronize(now: now)
            guard remainingSeconds > 0 else { return }
            targetDate = nil
            isRunning = false
            persistState()
        } else if remainingSeconds > 0 {
            if activeSessionID == nil { activeSessionID = UUID() }
            targetDate = now.addingTimeInterval(TimeInterval(remainingSeconds))
            isRunning = true
            persistState()
        }
    }

    func reset() {
        guard persistenceError == nil else { return }
        targetDate = nil
        activeSessionID = nil
        isRunning = false
        remainingSeconds = selectedMinutes * 60
        persistState()
    }

    func synchronize(now: Date = Date()) {
        guard persistenceError == nil else { return }
        guard isRunning, let targetDate else { return }
        let updatedRemaining = min(remainingSeconds, max(0, Int(ceil(targetDate.timeIntervalSince(now)))))
        guard updatedRemaining != remainingSeconds else { return }

        remainingSeconds = updatedRemaining
        if updatedRemaining == 0 {
            // Use the scheduled completion instant, even when the app was asleep or closed overnight.
            let sessionID = activeSessionID ?? UUID()
            if !history.contains(where: { $0.id == sessionID }) {
                history.append(FocusHistoryRecord(
                    id: sessionID,
                    completedAt: targetDate,
                    minutes: selectedMinutes,
                    kind: selectedKind,
                    taskLabel: selectedKind == .focus ? taskLabel.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty : nil
                ))
                history.sort { $0.completedAt > $1.completedAt }
                if history.count > Self.historyLimit { history.removeLast(history.count - Self.historyLimit) }
                completedSessions += 1
            }
            isRunning = false
            self.targetDate = nil
            activeSessionID = nil
            // History and stopped state share one snapshot, so a restart cannot count this completion twice.
            persistState()
        } else if let lastPersistedRemainingSeconds, lastPersistedRemainingSeconds - updatedRemaining >= 15 {
            persistState()
        }
    }

    private func persistState() {
        guard persistenceError == nil else { return }
        let snapshot = Snapshot(
            selectedMinutes: selectedMinutes,
            selectedKind: selectedKind,
            remainingSeconds: remainingSeconds,
            isRunning: isRunning,
            targetDate: targetDate,
            activeSessionID: activeSessionID,
            completedSessions: completedSessions,
            history: history,
            taskLabel: taskLabel
        )
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults.set(data, forKey: Self.snapshotKey)
        lastPersistedRemainingSeconds = remainingSeconds
    }
}

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}
