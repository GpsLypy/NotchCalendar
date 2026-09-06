import XCTest
@testable import NotchCalendar

@MainActor final class WorkspaceCommandTests: XCTestCase {
    func testSearchSupportsBothLanguagesAndAllWords() {
        let commands = WorkspaceCommandCatalog.commands(events: [], language: .english, hasSession: false, isRunning: false)
        XCTAssertEqual(WorkspaceCommandCatalog.matching("专注", in: commands).map(\.id), ["page:focus"])
        XCTAssertEqual(WorkspaceCommandCatalog.matching("  FoCuS  ", in: commands).map(\.id), ["page:focus"])
        XCTAssertTrue(WorkspaceCommandCatalog.matching("focus missing", in: commands).isEmpty)
        XCTAssertEqual(WorkspaceCommandCatalog.matching(" \n ", in: commands).count, WorkspaceDestination.allCases.count)
    }

    func testEventSearchIncludesCalendarAndLocationAndDeduplicates() {
        var event = CalendarEvent(id: "review", title: "Design review", startDate: .now, endDate: .now.addingTimeInterval(600), calendarName: "Team", calendarColor: nil, location: "Studio", meetingLink: nil, isAllDay: false)
        event.calendarID = "work"
        let commands = WorkspaceCommandCatalog.commands(events: [event, event], language: .simplifiedChinese, hasSession: false, isRunning: false)
        let matches = WorkspaceCommandCatalog.matching(event.title, in: commands)
        XCTAssertEqual(matches.count, 1)
        XCTAssertEqual(WorkspaceCommandCatalog.matching("team studio", in: commands).count, 1)
        guard case .inspectEvent(let resolved) = matches[0].action else { return XCTFail("Must open this occurrence") }
        XCTAssertEqual(resolved.occurrenceStableID, event.occurrenceStableID)
    }

    func testTimerActionOnlyExistsForUnfinishedSession() {
        let idle = WorkspaceCommandCatalog.commands(events: [], language: .english, hasSession: false, isRunning: false)
        XCTAssertFalse(idle.contains { $0.id == "focus:toggle" })
        let paused = WorkspaceCommandCatalog.commands(events: [], language: .english, hasSession: true, isRunning: false)
        XCTAssertEqual(paused.first?.title, "Resume timer")
        let running = WorkspaceCommandCatalog.commands(events: [], language: .english, hasSession: true, isRunning: true)
        XCTAssertEqual(running.first?.title, "Pause timer")
    }
}
