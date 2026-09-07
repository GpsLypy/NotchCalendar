import XCTest
@testable import NotchCalendar

@MainActor
final class CalendarCancellationTests: XCTestCase {
    func testExplicitCancellationLabelsWithoutHidingNormalTitles() {
        let now = Date()
        for title in ["已取消: redis 管控方案讨论", " 已取消：项目会议", "已取消 ：项目会议",
                      "Canceled: Review", "CANCELLED: Review", "[Cancelled] Review", "【已取消】会议"] {
            XCTAssertTrue(CalendarSelectionTestDataSource.event(id: title, start: now, end: now.addingTimeInterval(600)).isCancelled, title)
        }
        for title in ["讨论取消流程", "取消方案评审", "Review cancelled orders", "讨论：已取消的订单"] {
            XCTAssertFalse(CalendarSelectionTestDataSource.event(id: title, start: now, end: now.addingTimeInterval(600)).isCancelled, title)
        }
    }

    @MainActor
    func testCancellationIsExcludedFromEveryCalendarQueryWithDuplicatesOnOrOff() throws {
        let suite = "CalendarCancellationTests.\(UUID())"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let now = Date()
        func event(_ title: String) -> CalendarEvent {
            CalendarSelectionTestDataSource.event(id: title, start: now, end: now.addingTimeInterval(600))
        }
        var cancelled = event("Provider cancelled")
        cancelled.isCancelledByProvider = true
        var declined = event("Declined but not cancelled")
        declined.isEligibleForMeeting = false
        let source = CalendarSelectionTestDataSource(eventsByCalendarID: ["work": [
            cancelled, event("已取消: redis 管控方案讨论"), declined, event("Normal meeting")
        ]])
        let manager = CalendarManager(dataSource: source, defaults: defaults)
        let expected: Set<String> = [declined.id, "Normal meeting"]
        for deduplicates in [true, false] {
            manager.setDeduplicatesEvents(deduplicates)
            manager.refresh(now: now)
            for events in [manager.todayEvents, manager.planningEvents, manager.events(for: now),
                           manager.events(inMonthContaining: now),
                           manager.events(from: now, to: now.addingTimeInterval(3600))] {
                XCTAssertEqual(Set(events.map(\.id)), expected)
            }
        }
        XCTAssertEqual(source.eventsByCalendarID["work"]?.count, 4, "Filtering must not delete calendar data")
    }
}
