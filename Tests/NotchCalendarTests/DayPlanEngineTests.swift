import XCTest
@testable import NotchCalendar

final class DayPlanEngineTests: XCTestCase {
    private var calendar: Calendar {
        var value = Calendar(identifier: .gregorian)
        value.timeZone = TimeZone(secondsFromGMT: 0)!
        return value
    }

    func testOverlapsAreMergedAndMeetingBufferIsAppliedOnce() {
        let plan = DayPlanEngine.makePlan(events: [event("a", 10, 11), event("b", 10.5, 12)], now: time(9), calendar: calendar)
        XCTAssertEqual(plan.busyIntervals, [DayPlanInterval(start: time(9, 55), end: time(12, 5))])
        XCTAssertEqual(plan.freeIntervals, [
            DayPlanInterval(start: time(9), end: time(9, 55)),
            DayPlanInterval(start: time(12, 5), end: time(18))
        ])
        XCTAssertEqual(plan.availableMinutes, 410)
        XCTAssertEqual(plan.conflicts.count, 1)
        XCTAssertEqual(plan.conflicts.first?.events.map(\.id), ["a", "b"])
        XCTAssertEqual(plan.recommendedFocusMinutes(at: time(9)), 50)
    }

    func testTouchingEventsAndTheirBuffersDoNotCreateFalseConflict() {
        let plan = DayPlanEngine.makePlan(events: [event("a", 10, 11), event("b", 11, 12)], now: time(9), calendar: calendar)
        XCTAssertTrue(plan.conflicts.isEmpty)
        XCTAssertEqual(plan.busyIntervals.count, 1)
    }

    func testCurrentEventHasNoRecommendationAndExpiredConflictDisappears() {
        let events = [event("a", 9, 10), event("b", 9.5, 10.5)]
        let active = DayPlanEngine.makePlan(events: events, now: time(10), calendar: calendar)
        XCTAssertNil(active.recommendedFocusMinutes(at: time(10)))
        XCTAssertTrue(active.conflicts.isEmpty)
        XCTAssertEqual(active.freeIntervals.first?.start, time(10, 35))
        let after = DayPlanEngine.makePlan(events: events, now: time(11), calendar: calendar)
        XCTAssertEqual(after.freeIntervals.first?.start, time(11))
        XCTAssertTrue(after.conflicts.isEmpty)
    }

    func testSuggestionNeverRoundsUpIntoNextMeeting() {
        let plan = DayPlanEngine.makePlan(events: [event("next", 10, 11)], now: time(9, 37).addingTimeInterval(30), calendar: calendar)
        XCTAssertEqual(plan.recommendedFocusMinutes(at: time(9, 37).addingTimeInterval(30)), 17)
        XCTAssertNil(plan.recommendedFocusMinutes(at: time(9, 51)))
        XCTAssertNil(plan.recommendedFocusMinutes(at: time(8)))
    }

    func testAllDayAndNonBlockingEventsRemainInformational() {
        var free = event("free", 9, 18)
        free.blocksTime = false
        let allDay = CalendarEvent(id: "holiday", title: "Holiday", startDate: time(0), endDate: time(24), calendarName: "Work", calendarColor: nil, location: nil, meetingLink: nil, isAllDay: true)
        let invalid = event("invalid", 11, 10)
        let plan = DayPlanEngine.makePlan(events: [free, allDay, invalid], now: time(9), calendar: calendar)
        XCTAssertEqual(plan.availableMinutes, 540)
        XCTAssertEqual(plan.allDayEventCount, 1)
        XCTAssertTrue(plan.conflicts.isEmpty)
    }

    func testCrossMidnightEventsAndBufferRespectFullDayWindow() {
        let yesterday = event("yesterday", -1, 0)
        let tomorrow = event("tomorrow", 24, 25)
        let plan = DayPlanEngine.makePlan(
            events: [yesterday, tomorrow], now: time(0),
            settings: DayPlanSettings(startHour: 0, endHour: 24, bufferMinutes: 5), calendar: calendar
        )
        XCTAssertEqual(plan.freeIntervals, [DayPlanInterval(start: time(0, 5), end: time(23, 55))])
        XCTAssertTrue(plan.conflicts.isEmpty)
    }

    func testPastAndFutureOutsideWindowCannotProduceExtraFreeTime() {
        let events = [event("early", 6, 8), event("late", 19, 21)]
        let before = DayPlanEngine.makePlan(events: events, now: time(7), calendar: calendar)
        XCTAssertEqual(before.availableMinutes, 540)
        XCTAssertNil(before.recommendedFocusMinutes(at: time(7)))
        let after = DayPlanEngine.makePlan(events: events, now: time(19), calendar: calendar)
        XCTAssertTrue(after.freeIntervals.isEmpty)
        XCTAssertEqual(after.availableMinutes, 0)
    }

    func testConflictOutsidePlanningHoursIsStillVisible() {
        let plan = DayPlanEngine.makePlan(events: [event("late-a", 19, 21), event("late-b", 20, 22)], now: time(18), calendar: calendar)
        XCTAssertEqual(plan.conflicts.count, 1)
        XCTAssertTrue(plan.freeIntervals.isEmpty)
    }

    func testNestedAndChainedOverlapsDoNotLoseLaterConflict() {
        let plan = DayPlanEngine.makePlan(events: [event("outer", 10, 14), event("inner", 11, 12), event("later", 13, 15), event("separate", 16, 17)], now: time(9), calendar: calendar)
        XCTAssertEqual(plan.conflicts.count, 1)
        XCTAssertEqual(plan.conflicts.first?.events.count, 3)
        XCTAssertEqual(plan.busyIntervals.count, 2)
    }

    func testDSTUsesLocalHourBoundariesAndCalendarDayLength() throws {
        var local = Calendar(identifier: .gregorian)
        local.timeZone = try XCTUnwrap(TimeZone(identifier: "America/Los_Angeles"))
        let day = try XCTUnwrap(local.date(from: DateComponents(year: 2026, month: 3, day: 8)))
        let full = DayPlanEngine.makePlan(events: [], now: day, settings: DayPlanSettings(startHour: 0, endHour: 24, bufferMinutes: 0), calendar: local)
        XCTAssertEqual(full.availableMinutes, 23 * 60)
        let work = DayPlanEngine.makePlan(events: [], now: day, calendar: local)
        XCTAssertEqual(local.component(.hour, from: work.window.start), 9)
        XCTAssertEqual(local.component(.hour, from: work.window.end), 18)
        XCTAssertEqual(work.availableMinutes, 9 * 60)
    }

    func testInvalidSettingsCannotInvertWindowOrBuffer() {
        let settings = DayPlanSettings(startHour: 100, endHour: -2, bufferMinutes: -10)
        XCTAssertEqual(settings.startHour, 23)
        XCTAssertEqual(settings.endHour, 24)
        XCTAssertEqual(settings.bufferMinutes, 0)
    }

    private func time(_ hour: Double, _ minutes: Int = 0) -> Date {
        let midnight = calendar.date(from: DateComponents(year: 2026, month: 9, day: 5))!
        return midnight.addingTimeInterval(hour * 3_600 + Double(minutes) * 60)
    }

    private func event(_ id: String, _ start: Double, _ end: Double) -> CalendarEvent {
        CalendarEvent(id: id, title: id, startDate: time(start), endDate: time(end), calendarName: "Work", calendarColor: nil, location: nil, meetingLink: nil, isAllDay: false)
    }
}
