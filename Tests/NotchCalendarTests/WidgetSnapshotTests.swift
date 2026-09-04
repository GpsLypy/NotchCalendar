import Foundation
import NotchCalendarShared
import XCTest

final class WidgetSnapshotTests: XCTestCase {
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
