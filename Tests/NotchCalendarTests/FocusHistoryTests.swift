import Foundation
import XCTest
@testable import NotchCalendar

final class FocusHistoryTests: XCTestCase {
    @MainActor
    func testCustomFocusSurvivesPauseAndRelaunchWithoutCountingBreaksAsFocus() {
        let name = suiteName(for: #function)
        let defaults = freshDefaults(name)
        defer { defaults.removePersistentDomain(forName: name) }
        let start = date("2026-09-05T09:00:00Z")
        let timer = FocusTimerModel(defaults: defaults, now: start)
        XCTAssertTrue(timer.prepareFocus(minutes: 37))
        XCTAssertFalse(timer.isRunning)
        timer.toggle(now: start)
        timer.toggle(now: start.addingTimeInterval(60))
        XCTAssertTrue(timer.hasUnfinishedSession)

        let restored = FocusTimerModel(defaults: UserDefaults(suiteName: name)!, now: start.addingTimeInterval(600))
        XCTAssertEqual(restored.selectedMinutes, 37)
        XCTAssertEqual(restored.selectedKind, .focus)
        XCTAssertFalse(restored.isRunning)
        XCTAssertEqual(restored.remainingSeconds, 36 * 60)
        restored.toggle(now: start.addingTimeInterval(600))
        let completion = start.addingTimeInterval(600 + 36 * 60)
        restored.synchronize(now: completion)
        restored.synchronize(now: completion.addingTimeInterval(100))
        XCTAssertEqual(restored.history.count, 1)
        XCTAssertEqual(restored.history.first?.minutes, 37)
        XCTAssertEqual(restored.history.first?.completedAt, completion)
        let completedID = restored.history.first?.id

        restored.select(minutes: 5)
        XCTAssertEqual(restored.selectedKind, .breakTime)
        restored.toggle(now: completion)
        restored.synchronize(now: completion.addingTimeInterval(300))
        let secondRelaunch = FocusTimerModel(defaults: UserDefaults(suiteName: name)!, now: completion.addingTimeInterval(400))
        XCTAssertEqual(secondRelaunch.history.count, 2)
        XCTAssertTrue(secondRelaunch.history.contains { $0.id == completedID })
        XCTAssertEqual(secondRelaunch.completedSessions, 2)
        XCTAssertEqual(secondRelaunch.summary(now: completion.addingTimeInterval(400), calendar: utcCalendar()).todayMinutes, 37)
        XCTAssertEqual(secondRelaunch.summary(now: completion.addingTimeInterval(400), calendar: utcCalendar()).weekMinutes, 37)
    }

    @MainActor
    func testSuggestionCannotReplaceRunningOrImmediatelyPausedSession() {
        let name = suiteName(for: #function)
        let defaults = freshDefaults(name)
        defer { defaults.removePersistentDomain(forName: name) }
        let start = date("2026-09-05T09:00:00Z")
        let timer = FocusTimerModel(defaults: defaults, now: start)
        XCTAssertFalse(timer.prepareFocus(minutes: 4))
        XCTAssertFalse(timer.prepareFocus(minutes: 181))
        XCTAssertTrue(timer.prepareFocus(minutes: 180))
        timer.toggle(now: start)
        XCTAssertFalse(timer.prepareFocus(minutes: 25))
        timer.toggle(now: start)
        XCTAssertEqual(timer.remainingSeconds, 180 * 60)
        XCTAssertTrue(timer.hasUnfinishedSession)
        XCTAssertFalse(timer.prepareFocus(minutes: 50))
        timer.select(minutes: 5)
        XCTAssertEqual(timer.selectedMinutes, 180)
        XCTAssertEqual(timer.selectedKind, .focus)

        let restored = FocusTimerModel(defaults: UserDefaults(suiteName: name)!, now: start)
        XCTAssertTrue(restored.hasUnfinishedSession)
        XCTAssertFalse(restored.prepareFocus(minutes: 50))
        restored.reset()
        XCTAssertFalse(restored.hasUnfinishedSession)
        XCTAssertTrue(restored.prepareFocus(minutes: 5))
        XCTAssertEqual(restored.selectedKind, .focus)
        restored.toggle(now: start)
        restored.synchronize(now: start.addingTimeInterval(300))
        XCTAssertEqual(restored.summary(now: start.addingTimeInterval(301), calendar: utcCalendar()).todayMinutes, 5)
    }

    @MainActor
    func testOvernightRelaunchUsesActualCompletionDayAndOnlyRecordsOnce() {
        let name = suiteName(for: #function)
        let defaults = freshDefaults(name)
        defer { defaults.removePersistentDomain(forName: name) }
        let start = date("2026-09-04T23:20:00Z")
        let timer = FocusTimerModel(defaults: defaults, now: start)
        timer.toggle(now: start)
        let nextMorning = date("2026-09-05T09:00:00Z")
        let restored = FocusTimerModel(defaults: UserDefaults(suiteName: name)!, now: nextMorning)
        XCTAssertEqual(restored.history.count, 1)
        XCTAssertEqual(restored.history.first?.completedAt, date("2026-09-04T23:45:00Z"))
        XCTAssertEqual(restored.summary(now: nextMorning, calendar: utcCalendar()).todayMinutes, 0)
        XCTAssertEqual(restored.summary(now: nextMorning, calendar: utcCalendar()).weekMinutes, 25)
        XCTAssertEqual(restored.summary(now: date("2026-09-04T23:59:00Z"), calendar: utcCalendar()).todayMinutes, 25)
        let secondRestore = FocusTimerModel(defaults: UserDefaults(suiteName: name)!, now: nextMorning)
        XCTAssertEqual(secondRestore.history, restored.history)
        XCTAssertEqual(secondRestore.completedSessions, 1)
    }

    @MainActor
    func testLegacyCountMigratesWithoutCreatingFictionalRecords() {
        let name = suiteName(for: #function)
        let defaults = freshDefaults(name)
        defer { defaults.removePersistentDomain(forName: name) }
        defaults.set(42, forKey: "workspace.focus.completedSessions")
        defaults.set(5, forKey: "workspace.focus.selectedMinutes")
        defaults.set(120, forKey: "workspace.focus.remainingSeconds")
        let start = date("2026-09-05T09:00:00Z")
        let timer = FocusTimerModel(defaults: defaults, now: start)
        XCTAssertEqual(timer.completedSessions, 42)
        XCTAssertTrue(timer.history.isEmpty)
        XCTAssertTrue(timer.hasUnfinishedSession)
        XCTAssertEqual(timer.selectedKind, .breakTime)
        timer.toggle(now: start)
        timer.synchronize(now: start.addingTimeInterval(120))
        XCTAssertEqual(timer.completedSessions, 43)
        XCTAssertEqual(timer.history.count, 1)
        XCTAssertEqual(timer.history.first?.kind, .breakTime)
        XCTAssertEqual(timer.summary(now: start.addingTimeInterval(121), calendar: utcCalendar()).todayMinutes, 0)
        let restored = FocusTimerModel(defaults: UserDefaults(suiteName: name)!, now: start.addingTimeInterval(200))
        XCTAssertEqual(restored.completedSessions, 43)
        XCTAssertEqual(restored.history, timer.history)
    }

    func testSummaryUsesLocalMidnightAndConfiguredWeekBoundaries() {
        var calendar = utcCalendar()
        calendar.timeZone = TimeZone(identifier: "Asia/Shanghai")!
        let now = date("2026-09-06T16:10:00Z") // Monday 00:10 local time.
        let records = [
            record("2026-09-06T15:59:59Z", minutes: 25),
            record("2026-09-06T16:00:00Z", minutes: 50),
            record("2026-09-06T16:05:00Z", minutes: 5, kind: .breakTime),
            record("2026-09-07T16:00:00Z", minutes: 60) // Future records cannot inflate today's results.
        ]
        let summary = FocusHistorySummary(records: records, now: now, calendar: calendar)
        XCTAssertEqual(summary.todayMinutes, 50)
        XCTAssertEqual(summary.weekMinutes, 50)
    }

    @MainActor
    func testHistoryRetentionPreservesLifetimeCountAndMostRecentRecords() throws {
        let name = suiteName(for: #function)
        let defaults = freshDefaults(name)
        defer { defaults.removePersistentDomain(forName: name) }
        let now = date("2026-09-05T09:00:00Z")
        let records = (0..<1_005).map { index in
            FocusHistoryRecord(id: UUID(), completedAt: now.addingTimeInterval(Double(-index - 1) * 300), minutes: 5, kind: .focus)
        }
        struct StoredState: Encodable {
            let selectedMinutes = 25
            let selectedKind = FocusSessionKind.focus
            let remainingSeconds = 25 * 60
            let isRunning = false
            let completedSessions = 2_000
            let history: [FocusHistoryRecord]
        }
        defaults.set(try JSONEncoder().encode(StoredState(history: records)), forKey: "workspace.focus.snapshot.v1")
        let timer = FocusTimerModel(defaults: defaults, now: now)
        XCTAssertEqual(timer.history.count, FocusTimerModel.historyLimit)
        XCTAssertEqual(timer.completedSessions, 2_000)
        XCTAssertEqual(timer.history.first?.id, records.first?.id)
        XCTAssertEqual(timer.history.last?.id, records[999].id)
        timer.toggle(now: now)
        timer.synchronize(now: now.addingTimeInterval(1_500))
        XCTAssertEqual(timer.history.count, FocusTimerModel.historyLimit)
        XCTAssertEqual(timer.history.first?.completedAt, now.addingTimeInterval(1_500))
        XCTAssertEqual(timer.history.last?.id, records[998].id)
        XCTAssertEqual(timer.completedSessions, 2_001)
    }

    func testCSVWritesActualFileWithStableIDsUTCDateAndExplicitKinds() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let first = record("2026-09-05T09:00:00Z", minutes: 37)
        let second = record("2026-09-05T09:05:00Z", minutes: 5, kind: .breakTime)
        let url = directory.appendingPathComponent("focus.csv")
        try FocusHistoryCSV.write(records: [second, first], to: url)
        let content = try String(contentsOf: url, encoding: .utf8)
        let rows = content.components(separatedBy: "\r\n")
        XCTAssertEqual(rows[0], "session_id,completed_at_utc,duration_minutes,kind")
        XCTAssertEqual(rows[1], "\(first.id.uuidString),2026-09-05T09:00:00.000Z,37,focus")
        XCTAssertEqual(rows[2], "\(second.id.uuidString),2026-09-05T09:05:00.000Z,5,break")
        XCTAssertEqual(rows.count, 4)
        XCTAssertThrowsError(try FocusHistoryCSV.write(records: [first], to: directory))
    }

    private func date(_ string: String) -> Date { ISO8601DateFormatter().date(from: string)! }

    private func record(_ timestamp: String, minutes: Int, kind: FocusSessionKind = .focus) -> FocusHistoryRecord {
        FocusHistoryRecord(id: UUID(), completedAt: date(timestamp), minutes: minutes, kind: kind)
    }

    private func utcCalendar() -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar.firstWeekday = 2
        calendar.minimumDaysInFirstWeek = 4
        return calendar
    }

    private func freshDefaults(_ name: String) -> UserDefaults {
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        return defaults
    }

    private func suiteName(for name: String) -> String { "NotchCalendarTests.FocusHistory.\(name)" }
}
