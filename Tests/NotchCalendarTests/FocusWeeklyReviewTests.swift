import XCTest
@testable import NotchCalendar

@MainActor
final class FocusWeeklyReviewTests: XCTestCase {
    func testDamagedSnapshotRemainsUntouchedUntilValidRestore() throws {
        let suite = "NotchCalendarTests.DamagedFocus.\(UUID())"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let key = "workspace.focus.snapshot.v1"
        let original = Data("unreadable retained history".utf8)
        defaults.set(original, forKey: key)
        let timer = FocusTimerModel(defaults: defaults)
        XCTAssertNotNil(timer.persistenceError)
        XCTAssertFalse(timer.prepareFocus(minutes: 25))
        timer.toggle()
        timer.reset()
        timer.setTaskLabel("do not write")
        timer.reload()
        XCTAssertEqual(defaults.data(forKey: key), original)
        defaults.removeObject(forKey: key)
        timer.reload()
        XCTAssertNil(timer.persistenceError)
        XCTAssertTrue(timer.prepareFocus(minutes: 25))
    }

    func testWeekUsesLocalDaysAcrossDaylightSavingAndExcludesBreaksAndFuture() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try XCTUnwrap(TimeZone(identifier: "America/New_York"))
        calendar.firstWeekday = 2
        let records = [
            record("2026-03-08T06:30:00Z", minutes: 25, label: "Ship"),
            record("2026-03-08T07:30:00Z", minutes: 50, label: "Ship"),
            record("2026-03-09T04:00:00Z", minutes: 30, label: "Next week"),
            record("2026-03-08T08:00:00Z", minutes: 5, kind: .breakTime),
            record("2026-03-08T22:00:00Z", minutes: 25, label: "Future")
        ]
        let review = FocusWeeklyReview(records: records, weekContaining: date("2026-03-08T12:00:00Z"), now: date("2026-03-08T12:00:00Z"), calendar: calendar)
        XCTAssertEqual(review.interval.duration, 167 * 3600)
        XCTAssertEqual(review.days.count, 7)
        XCTAssertEqual(review.days.last?.minutes, 75)
        XCTAssertEqual(review.minutes, 75)
        XCTAssertEqual(review.sessions, 2)
        XCTAssertEqual(review.tasks.first?.label, "Ship")
        XCTAssertEqual(review.tasks.first?.minutes, 75)
    }

    func testLegacyRecordDecodesWithoutTaskAndCSVProtectsUserInput() throws {
        let original = record("2026-09-05T10:00:00Z", minutes: 25)
        let data = try JSONEncoder().encode(original)
        XCTAssertNil(try JSONDecoder().decode(FocusHistoryRecord.self, from: data).taskLabel)
        var tagged = original
        tagged.taskLabel = "=SUM(1,2)\n\"quoted\""
        let csv = FocusHistoryCSV.string(records: [tagged])
        XCTAssertTrue(csv.contains(",task_label\r\n"))
        XCTAssertTrue(csv.contains("\"'=SUM(1,2)\n\"\"quoted\"\"\""))
    }

    func testTaskSurvivesPauseRelaunchCompletionAndRestoreReload() throws {
        let suite = "NotchCalendarTests.Tasks.\(UUID())"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let now = date("2026-09-05T10:00:00Z")
        let timer = FocusTimerModel(defaults: defaults, now: now)
        timer.setTaskLabel("发布准备")
        XCTAssertTrue(timer.prepareFocus(minutes: 5))
        timer.toggle(now: now)
        timer.toggle(now: now.addingTimeInterval(30))
        let restored = FocusTimerModel(defaults: defaults, now: now.addingTimeInterval(60))
        XCTAssertEqual(restored.taskLabel, "发布准备")
        XCTAssertTrue(restored.hasUnfinishedSession)
        restored.toggle(now: now.addingTimeInterval(60))
        restored.synchronize(now: now.addingTimeInterval(330))
        XCTAssertEqual(restored.history.first?.taskLabel, "发布准备")
        timer.reload(now: now.addingTimeInterval(330))
        XCTAssertEqual(timer.history, restored.history)
        XCTAssertFalse(timer.isRunning)
    }

    func testReviewExportIncludesAllTaskLabelsAndEscapesMarkdown() {
        let now = date("2026-09-05T12:00:00Z")
        let review = FocusWeeklyReview(records: [record("2026-09-05T10:00:00Z", minutes: 25, label: "[link](url)\n# heading")], weekContaining: now, now: now)
        let markdown = review.markdown(language: .english)
        XCTAssertTrue(markdown.contains("25 minutes across 1 focus sessions"))
        XCTAssertTrue(markdown.contains("\\[link\\](url) \\# heading"))
        XCTAssertTrue(markdown.contains(Calendar.current.timeZone.identifier))
    }

    private func date(_ value: String) -> Date { ISO8601DateFormatter().date(from: value)! }
    private func record(_ value: String, minutes: Int, kind: FocusSessionKind = .focus, label: String? = nil) -> FocusHistoryRecord {
        FocusHistoryRecord(id: UUID(), completedAt: date(value), minutes: minutes, kind: kind, taskLabel: label)
    }
}
