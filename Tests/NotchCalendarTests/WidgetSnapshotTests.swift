import Foundation
import NotchCalendarShared
import XCTest

final class WidgetSnapshotTests: XCTestCase {
    func testLegacyFocusSnapshotDecodesWithPresetAndPauseFallbacks() throws {
        let legacyJSON = """
        {"selectedMinutes":5,"remainingSecondsAtWrite":120,"isRunning":false,
         "completedSessions":4,"localizationIdentifier":"en"}
        """
        let snapshot = try JSONDecoder().decode(WidgetFocusSnapshot.self, from: Data(legacyJSON.utf8))

        XCTAssertTrue(snapshot.isBreak)
        XCTAssertTrue(snapshot.hasUnfinishedSession)
        XCTAssertEqual(snapshot.phase(at: Date()), .paused)
        XCTAssertEqual(try JSONDecoder().decode(WidgetFocusSnapshot.self, from: JSONEncoder().encode(snapshot)), snapshot)

        let legacyFocus = legacyJSON.replacingOccurrences(of: "\"selectedMinutes\":5", with: "\"selectedMinutes\":25")
            .replacingOccurrences(of: "\"remainingSecondsAtWrite\":120", with: "\"remainingSecondsAtWrite\":1500")
        let ready = try JSONDecoder().decode(WidgetFocusSnapshot.self, from: Data(legacyFocus.utf8))
        XCTAssertFalse(ready.isBreak)
        XCTAssertFalse(ready.hasUnfinishedSession)
        XCTAssertEqual(ready.phase(at: Date()), .ready)
    }

    func testFiveMinuteFocusAndBreakRoundTripWithExplicitKinds() throws {
        let suiteName = "NotchCalendarTests.WidgetSnapshotStore.\(#function)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        defaults.removePersistentDomain(forName: suiteName)

        for isBreak in [false, true] {
            let snapshot = WidgetFocusSnapshot(
                selectedMinutes: 5, remainingSecondsAtWrite: 300, isRunning: false,
                targetDate: nil, completedSessions: 4, localizationIdentifier: "zh-Hans",
                isBreak: isBreak, hasUnfinishedSession: false
            )
            XCTAssertTrue(WidgetSnapshotStore.writeFocus(snapshot, to: defaults))
            let restored = WidgetSnapshotStore.readFocus(from: defaults)
            XCTAssertEqual(restored, snapshot)
            XCTAssertEqual(restored?.isBreak, isBreak)
            XCTAssertEqual(restored?.phase(at: Date()), .ready)
        }
    }

    func testImmediatelyPausedFocusRemainsPausedAfterRoundTrip() throws {
        let snapshot = WidgetFocusSnapshot(
            selectedMinutes: 180, remainingSecondsAtWrite: 10_800, isRunning: false,
            targetDate: nil, completedSessions: 0, localizationIdentifier: "en",
            isBreak: false, hasUnfinishedSession: true
        )
        let restored = try JSONDecoder().decode(WidgetFocusSnapshot.self, from: JSONEncoder().encode(snapshot))
        XCTAssertEqual(restored.remainingSeconds(at: Date()), 10_800)
        XCTAssertEqual(restored.phase(at: Date()), .paused)
        XCTAssertEqual(restored.progress(at: Date()), 0)
    }

    func testThreeHourCustomFocusCountsDownToCompletion() {
        let start = Date(timeIntervalSinceReferenceDate: 2_500)
        let target = start.addingTimeInterval(10_800)
        let snapshot = WidgetFocusSnapshot(
            selectedMinutes: 180, remainingSecondsAtWrite: 10_800, isRunning: true,
            targetDate: target, completedSessions: 0, localizationIdentifier: "en",
            isBreak: false, hasUnfinishedSession: true
        )
        XCTAssertEqual(snapshot.remainingSeconds(at: start), 10_800)
        XCTAssertEqual(snapshot.remainingSeconds(at: start.addingTimeInterval(3_600)), 7_200)
        XCTAssertEqual(snapshot.phase(at: start), .running)
        XCTAssertEqual(snapshot.phase(at: target), .complete)
        XCTAssertEqual(snapshot.progress(at: target), 1)
    }

    func testFocusSnapshotUsesAbsoluteTargetWithoutGrowingAfterClockRollback() {
        let target = Date(timeIntervalSinceReferenceDate: 2_500)
        let snapshot = WidgetFocusSnapshot(
            selectedMinutes: 5,
            remainingSecondsAtWrite: 240,
            isRunning: true,
            targetDate: target,
            completedSessions: 0,
            localizationIdentifier: "en"
        )

        XCTAssertEqual(
            snapshot.remainingSeconds(at: Date(timeIntervalSinceReferenceDate: 2_300)),
            200
        )
        XCTAssertEqual(
            snapshot.remainingSeconds(at: Date(timeIntervalSinceReferenceDate: 2_000)),
            240
        )
        XCTAssertEqual(snapshot.phase(at: target), .complete)
    }

    func testCalendarSnapshotRoundTripsThroughIsolatedPreferences() {
        let suiteName = "NotchCalendarTests.WidgetSnapshotStore.\(#function)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        defaults.removePersistentDomain(forName: suiteName)

        let snapshot = WidgetCalendarSnapshot(
            authorization: .available,
            events: [
                WidgetEventSnapshot(
                    id: "event-1",
                    title: "Weekly review",
                    startDate: Date(timeIntervalSinceReferenceDate: 1_000),
                    endDate: Date(timeIntervalSinceReferenceDate: 1_900),
                    calendarName: "Work",
                    calendarColor: WidgetRGBAColor(
                        red: 1,
                        green: 0.2,
                        blue: 0.3,
                        alpha: 1
                    ),
                    isAllDay: false
                )
            ],
            localizationIdentifier: "en",
            timeZoneIdentifier: "Asia/Shanghai"
        )

        XCTAssertTrue(WidgetSnapshotStore.writeCalendar(snapshot, to: defaults))
        XCTAssertFalse(WidgetSnapshotStore.writeCalendar(snapshot, to: defaults))
        XCTAssertEqual(WidgetSnapshotStore.readCalendar(from: defaults), snapshot)
    }

    func testEventOverlapUsesExclusiveEndBoundary() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let day = Date(timeIntervalSince1970: 86_400)
        let event = WidgetEventSnapshot(
            id: "overnight",
            title: "Overnight",
            startDate: day.addingTimeInterval(-3_600),
            endDate: day.addingTimeInterval(3_600),
            calendarName: "Work",
            calendarColor: nil,
            isAllDay: false
        )

        XCTAssertTrue(event.occurs(on: day, calendar: calendar))
        XCTAssertFalse(
            event.occurs(on: day.addingTimeInterval(86_400), calendar: calendar)
        )
    }
}
