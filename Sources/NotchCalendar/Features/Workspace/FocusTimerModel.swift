import Foundation
import SwiftUI

@MainActor
final class FocusTimerModel: ObservableObject {
    static let presets = [25, 50, 5]

    @Published private(set) var selectedMinutes = 25
    @Published private(set) var remainingSeconds = 25 * 60
    @Published private(set) var isRunning = false
    @Published private(set) var completedSessions: Int

    private static let completedSessionsKey = "workspace.focus.completedSessions"
    private static let selectedMinutesKey = "workspace.focus.selectedMinutes"
    private static let remainingSecondsKey = "workspace.focus.remainingSeconds"
    private static let isRunningKey = "workspace.focus.isRunning"
    private static let targetDateKey = "workspace.focus.targetDate"
    private var targetDate: Date?
    private var lastPersistedRemainingSeconds: Int?
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard, now: Date = Date()) {
        self.defaults = defaults
        completedSessions = defaults.integer(forKey: Self.completedSessionsKey)

        let storedMinutes = defaults.integer(forKey: Self.selectedMinutesKey)
        selectedMinutes = Self.presets.contains(storedMinutes) ? storedMinutes : 25
        let fullDuration = selectedMinutes * 60
        let storedRemaining = defaults.object(forKey: Self.remainingSecondsKey).map { _ in
            min(fullDuration, max(0, defaults.integer(forKey: Self.remainingSecondsKey)))
        }

        if defaults.bool(forKey: Self.isRunningKey),
           defaults.object(forKey: Self.targetDateKey) != nil {
            let restoredTarget = Date(
                timeIntervalSinceReferenceDate: defaults.double(forKey: Self.targetDateKey)
            )
            let restoredRemaining = min(
                fullDuration,
                storedRemaining ?? fullDuration,
                max(0, Int(ceil(restoredTarget.timeIntervalSince(now))))
            )
            remainingSeconds = restoredRemaining
            if restoredRemaining > 0 {
                targetDate = restoredTarget
                isRunning = true
                defaults.set(restoredRemaining, forKey: Self.remainingSecondsKey)
                lastPersistedRemainingSeconds = restoredRemaining
            } else {
                completedSessions += 1
                defaults.set(completedSessions, forKey: Self.completedSessionsKey)
                persistStoppedState()
            }
        } else if let storedRemaining {
            remainingSeconds = storedRemaining
            lastPersistedRemainingSeconds = storedRemaining
        }
    }

    var progress: Double {
        let total = selectedMinutes * 60
        guard total > 0 else { return 0 }
        return 1 - (Double(remainingSeconds) / Double(total))
    }

    var timeLabel: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func select(minutes: Int) {
        guard Self.presets.contains(minutes) else { return }
        selectedMinutes = minutes
        remainingSeconds = minutes * 60
        targetDate = nil
        isRunning = false
        persistStoppedState()
    }

    func toggle(now: Date = Date()) {
        if isRunning {
            synchronize(now: now)
            guard remainingSeconds > 0 else { return }
            targetDate = nil
            isRunning = false
            persistStoppedState()
        } else if remainingSeconds > 0 {
            targetDate = now.addingTimeInterval(TimeInterval(remainingSeconds))
            isRunning = true
            persistRunningState()
        }
    }

    func reset() {
        targetDate = nil
        isRunning = false
        remainingSeconds = selectedMinutes * 60
        persistStoppedState()
    }

    func synchronize(now: Date = Date()) {
        guard isRunning, let targetDate else { return }
        let updatedRemaining = min(
            remainingSeconds,
            max(0, Int(ceil(targetDate.timeIntervalSince(now))))
        )
        guard updatedRemaining != remainingSeconds else { return }

        remainingSeconds = updatedRemaining
        if updatedRemaining == 0 {
            isRunning = false
            self.targetDate = nil
            completedSessions += 1
            defaults.set(completedSessions, forKey: Self.completedSessionsKey)
            persistStoppedState()
        } else if let lastPersistedRemainingSeconds,
                  lastPersistedRemainingSeconds - updatedRemaining >= 15 {
            defaults.set(updatedRemaining, forKey: Self.remainingSecondsKey)
            self.lastPersistedRemainingSeconds = updatedRemaining
        }
    }

    private func persistRunningState() {
        defaults.set(selectedMinutes, forKey: Self.selectedMinutesKey)
        defaults.set(remainingSeconds, forKey: Self.remainingSecondsKey)
        lastPersistedRemainingSeconds = remainingSeconds
        defaults.set(true, forKey: Self.isRunningKey)
        if let targetDate {
            defaults.set(targetDate.timeIntervalSinceReferenceDate, forKey: Self.targetDateKey)
        } else {
            defaults.removeObject(forKey: Self.targetDateKey)
        }
    }

    private func persistStoppedState() {
        defaults.set(selectedMinutes, forKey: Self.selectedMinutesKey)
        defaults.set(remainingSeconds, forKey: Self.remainingSecondsKey)
        lastPersistedRemainingSeconds = remainingSeconds
        defaults.set(false, forKey: Self.isRunningKey)
        defaults.removeObject(forKey: Self.targetDateKey)
    }
}
