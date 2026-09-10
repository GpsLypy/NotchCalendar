import AppKit
import CoreGraphics
import XCTest
@testable import NotchCalendar

final class NotchScreenSelectionTests: XCTestCase {
    private let builtIn = NotchScreenSelection.Display(id: 1, isBuiltIn: true)
    private let external = NotchScreenSelection.Display(id: 2, isBuiltIn: false)
    private let secondExternal = NotchScreenSelection.Display(id: 3, isBuiltIn: false)

    func testNativeScreenResolverPrefersConnectedBuiltInOverCurrentExternal() async throws {
        try await MainActor.run {
            func isBuiltIn(_ screen: NSScreen) -> Bool {
                guard let number = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber else {
                    return false
                }
                return CGDisplayIsBuiltin(number.uint32Value) != 0
            }
            guard let builtInScreen = NSScreen.screens.first(where: isBuiltIn),
                  let externalScreen = NSScreen.screens.first(where: { !isBuiltIn($0) }) else {
                throw XCTSkip("Requires a connected built-in display and external monitor.")
            }
            let selected = try XCTUnwrap(ScreenGeometry.preferredNotchScreen(current: externalScreen))
            XCTAssertEqual(selected, builtInScreen)
            XCTAssertEqual(ScreenGeometry.preferredNotchScreen(), builtInScreen)
            let frame = ScreenGeometry.panelFrame(
                on: selected, size: NSSize(width: 600, height: 460), expanded: true
            )
            XCTAssertTrue(builtInScreen.frame.contains(frame))
            XCTAssertEqual(frame.maxY, builtInScreen.frame.maxY)
        }
    }

    func testLaunchPrefersBuiltInEvenWhenExternalDisplayIsMainAndFirst() {
        XCTAssertEqual(NotchScreenSelection.preferredDisplayID(
            displays: [external, builtIn], mainDisplayID: external.id
        ), builtIn.id)
    }

    func testReopeningLidMovesPanelFromExternalBackToBuiltIn() {
        let closedLid = NotchScreenSelection.preferredDisplayID(
            displays: [external], currentDisplayID: builtIn.id, mainDisplayID: external.id
        )
        XCTAssertEqual(closedLid, external.id)
        XCTAssertEqual(NotchScreenSelection.preferredDisplayID(
            displays: [external, builtIn], currentDisplayID: closedLid, mainDisplayID: external.id
        ), builtIn.id)
    }

    func testExternalOnlyLaunchUsesMainDisplay() {
        XCTAssertEqual(NotchScreenSelection.preferredDisplayID(
            displays: [external, secondExternal], mainDisplayID: secondExternal.id
        ), secondExternal.id)
    }

    func testExternalOnlyPanelDoesNotFollowKeyboardFocusToAnotherDisplay() {
        XCTAssertEqual(NotchScreenSelection.preferredDisplayID(
            displays: [secondExternal, external], currentDisplayID: external.id,
            mainDisplayID: secondExternal.id
        ), external.id)
    }

    func testDisconnectingSelectedExternalDisplayFallsBackToAvailableScreen() {
        XCTAssertEqual(NotchScreenSelection.preferredDisplayID(
            displays: [secondExternal], currentDisplayID: external.id, mainDisplayID: external.id
        ), secondExternal.id)
    }

    func testDisconnectingExternalDisplayReturnsToBuiltIn() {
        XCTAssertEqual(NotchScreenSelection.preferredDisplayID(
            displays: [builtIn], currentDisplayID: external.id, mainDisplayID: external.id
        ), builtIn.id)
    }

    func testNoAvailableScreensDoesNotReturnStaleDisplay() {
        XCTAssertNil(NotchScreenSelection.preferredDisplayID(
            displays: [], currentDisplayID: builtIn.id, mainDisplayID: external.id
        ))
    }
}
