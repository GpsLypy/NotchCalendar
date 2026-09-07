import AppKit
import XCTest
@testable import NotchCalendar

final class MainCalendarWindowLayoutTests: XCTestCase {
    func testLegacySmallWindowGrowsWithoutMovingOffScreen() {
        let screen = NSRect(x: 0, y: 40, width: 1512, height: 900)
        let oldFrame = NSRect(x: 650, y: 280, width: 860, height: 620)
        let frame = MainCalendarWindowLayout.fittedFrame(
            oldFrame, visibleFrame: screen, expandTo: NSSize(width: 1120, height: 802)
        )
        XCTAssertEqual(frame.size, NSSize(width: 1120, height: 802))
        XCTAssertTrue(screen.contains(frame))
        XCTAssertEqual(frame.maxY, oldFrame.maxY)
    }

    func testLaterUserResizeIsPreserved() {
        let frame = NSRect(x: 100, y: 120, width: 860, height: 620)
        XCTAssertEqual(MainCalendarWindowLayout.fittedFrame(
            frame, visibleFrame: NSRect(x: 0, y: 40, width: 1512, height: 900)
        ), frame)
    }

    func testSmallerDisplayClampsOversizedOrDisconnectedScreenFrame() {
        let screen = NSRect(x: -1024, y: 40, width: 1024, height: 700)
        let frame = MainCalendarWindowLayout.fittedFrame(
            NSRect(x: 1600, y: 300, width: 1400, height: 1000),
            visibleFrame: screen, expandTo: NSSize(width: 1120, height: 802)
        )
        XCTAssertTrue(screen.insetBy(dx: 16, dy: 16).contains(frame))
        XCTAssertEqual(frame.size, NSSize(width: 992, height: 668))
    }
}
