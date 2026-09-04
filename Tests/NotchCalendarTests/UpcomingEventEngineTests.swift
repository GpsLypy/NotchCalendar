import XCTest
@testable import NotchCalendar

final class UpcomingEventEngineTests: XCTestCase {
    func testMeetingIsActiveAtItsStartAndIdleAtItsEnd() {
        let start = Date(timeIntervalSinceReferenceDate: 10_000)
        let end = start.addingTimeInterval(30 * 60)
        let event = CalendarEvent(
            id: "meeting",
            title: "Weekly sync",
            startDate: start,
            endDate: end,
            calendarName: "Work",
            calendarColor: nil,
            location: nil,
            meetingLink: nil,
            isAllDay: false
        )

        let statusAtStart = UpcomingEventEngine.status(now: start, events: [event])
        guard case .active = statusAtStart else {
            return XCTFail("A meeting should become active exactly when it starts")
        }
        XCTAssertTrue(statusAtStart.isActive)

        let statusAtEnd = UpcomingEventEngine.status(now: end, events: [event])
        guard case .idle = statusAtEnd else {
            return XCTFail("A meeting should stop driving compact content exactly when it ends")
        }
        XCTAssertFalse(statusAtEnd.isActive)
    }
}
