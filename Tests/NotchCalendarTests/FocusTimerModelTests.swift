import Foundation
import XCTest
@testable import NotchCalendar

final class FocusTimerModelTests: XCTestCase {
    @MainActor
    func testTimerUsesAbsoluteEndDateAndPausesAtSynchronizedValue() {
        let defaults = isolatedDefaults(for: #function)
        defer { defaults.removePersistentDomain(forName: suiteName(for: #function)) }
        let timer = FocusTimerModel(defaults: defaults)
        timer.select(minutes: 5)

        let start = Date(timeIntervalSinceReferenceDate: 1_000)
        timer.toggle(now: start)
        timer.synchronize(now: start.addingTimeInterval(61))

        XCTAssertEqual(timer.remainingSeconds, 239)
        XCTAssertTrue(timer.isRunning)

        timer.toggle(now: start.addingTimeInterval(90))
        XCTAssertEqual(timer.remainingSeconds, 210)
        XCTAssertFalse(timer.isRunning)

        timer.synchronize(now: start.addingTimeInterval(200))
        XCTAssertEqual(timer.remainingSeconds, 210)

        let restoredTimer = FocusTimerModel(defaults: defaults, now: start.addingTimeInterval(200))
        XCTAssertEqual(restoredTimer.remainingSeconds, 210)
        XCTAssertFalse(restoredTimer.isRunning)

        restoredTimer.toggle(now: start.addingTimeInterval(200))
        restoredTimer.synchronize(now: start.addingTimeInterval(410))
        XCTAssertEqual(restoredTimer.remainingSeconds, 0)
        XCTAssertEqual(restoredTimer.completedSessions, 1)
    }

    @MainActor
    func testCompletedSessionIsCountedOnceAndPersisted() {
        let defaults = isolatedDefaults(for: #function)
        defer { defaults.removePersistentDomain(forName: suiteName(for: #function)) }
        let timer = FocusTimerModel(defaults: defaults)
        timer.select(minutes: 5)

        let start = Date(timeIntervalSinceReferenceDate: 2_000)
        timer.toggle(now: start)
        timer.synchronize(now: start.addingTimeInterval(301))
        timer.synchronize(now: start.addingTimeInterval(600))

        XCTAssertEqual(timer.remainingSeconds, 0)
        XCTAssertFalse(timer.isRunning)
        XCTAssertEqual(timer.completedSessions, 1)

        let restoredTimer = FocusTimerModel(defaults: defaults)
        XCTAssertEqual(restoredTimer.completedSessions, 1)
    }

    @MainActor
    func testRunningSessionRestoresFromTargetDateAndExpiredSessionCountsOnce() {
        let defaults = isolatedDefaults(for: #function)
        defer { defaults.removePersistentDomain(forName: suiteName(for: #function)) }
        let start = Date(timeIntervalSinceReferenceDate: 3_000)
        let timer = FocusTimerModel(defaults: defaults, now: start)
        timer.select(minutes: 25)
        timer.toggle(now: start)

        let restoredTimer = FocusTimerModel(
            defaults: defaults,
            now: start.addingTimeInterval(60)
        )
        XCTAssertTrue(restoredTimer.isRunning)
        XCTAssertEqual(restoredTimer.remainingSeconds, 1_440)

        let expiredTimer = FocusTimerModel(
            defaults: defaults,
            now: start.addingTimeInterval(1_501)
        )
        XCTAssertFalse(expiredTimer.isRunning)
        XCTAssertEqual(expiredTimer.remainingSeconds, 0)
        XCTAssertEqual(expiredTimer.completedSessions, 1)

        let secondRestore = FocusTimerModel(
            defaults: defaults,
            now: start.addingTimeInterval(1_600)
        )
        XCTAssertEqual(secondRestore.completedSessions, 1)
    }

    @MainActor
    func testWallClockRollbackDoesNotIncreaseRemainingTime() {
        let defaults = isolatedDefaults(for: #function)
        defer { defaults.removePersistentDomain(forName: suiteName(for: #function)) }
        let start = Date(timeIntervalSinceReferenceDate: 4_000)
        let timer = FocusTimerModel(defaults: defaults, now: start)
        timer.select(minutes: 5)
        timer.toggle(now: start)
        timer.synchronize(now: start.addingTimeInterval(30))

        XCTAssertEqual(timer.remainingSeconds, 270)
        timer.synchronize(now: start.addingTimeInterval(-60))
        XCTAssertEqual(timer.remainingSeconds, 270)

        let restoredTimer = FocusTimerModel(
            defaults: defaults,
            now: start.addingTimeInterval(-60)
        )
        XCTAssertEqual(restoredTimer.remainingSeconds, 270)
    }

    private func isolatedDefaults(for testName: String) -> UserDefaults {
        let name = suiteName(for: testName)
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        return defaults
    }

    private func suiteName(for testName: String) -> String {
        "NotchCalendarTests.FocusTimerModel.\(testName)"
    }
}
