import XCTest
@testable import NotchCalendar

final class ScreenGeometryTests: XCTestCase {
    func testCompactPanelKeepsShortVisualHeight() {
        XCTAssertEqual(ScreenGeometry.compactPanelHeight, 30)
        XCTAssertEqual(ScreenGeometry.compactPanelHeight(notchDepth: nil), 30)
        XCTAssertEqual(ScreenGeometry.compactPanelCornerRadius, 9)
    }

    func testCompactPanelMatchesReportedHardwareDepth() {
        XCTAssertEqual(ScreenGeometry.compactPanelHeight(notchDepth: 32), 32)
        XCTAssertEqual(ScreenGeometry.compactPanelHeight(notchDepth: 38), 38)
    }

    func testCompactPanelAddsVisibleShouldersAroundHardwareNotch() {
        let width = ScreenGeometry.compactPanelWidth(
            notchWidth: 226,
            showsMeetingStatus: true
        )

        XCTAssertEqual(width, 366)
        XCTAssertEqual((width - 226) / 2, ScreenGeometry.compactShoulderWidth)
    }

    func testCompactPanelMatchesHardwareWidthWhileMeetingIsInactive() {
        XCTAssertEqual(
            ScreenGeometry.compactPanelWidth(
                notchWidth: 185,
                showsMeetingStatus: false
            ),
            185
        )
    }

    func testCompactPanelKeepsPillWidthWithoutHardwareNotch() {
        XCTAssertEqual(
            ScreenGeometry.compactPanelWidth(
                notchWidth: nil,
                showsMeetingStatus: false
            ),
            ScreenGeometry.fallbackCompactPanelWidth
        )
    }

    func testExpandedContentUsesBaselineInsetOnUnobscuredDisplay() {
        XCTAssertEqual(
            ScreenGeometry.expandedContentTopInset(
                safeAreaTopInset: 0,
                visibleFrameTopObstruction: 0,
                cameraHousingDepth: nil
            ),
            24
        )
    }

    func testExpandedContentUsesSafeAreaWhenAuxiliaryNotchBoundsAreUnavailable() {
        XCTAssertEqual(
            ScreenGeometry.expandedContentTopInset(
                safeAreaTopInset: 38,
                visibleFrameTopObstruction: 0,
                cameraHousingDepth: nil
            ),
            50
        )
    }

    func testExpandedContentUsesDeepestReportedTopObstruction() {
        XCTAssertEqual(
            ScreenGeometry.expandedContentTopInset(
                safeAreaTopInset: 38,
                visibleFrameTopObstruction: 31,
                cameraHousingDepth: 54
            ),
            66
        )
    }

    func testExpandedContentClearsMenuBarOnDisplayWithoutNotch() {
        XCTAssertEqual(
            ScreenGeometry.expandedContentTopInset(
                safeAreaTopInset: 0,
                visibleFrameTopObstruction: 31,
                cameraHousingDepth: nil
            ),
            43
        )
    }
}
