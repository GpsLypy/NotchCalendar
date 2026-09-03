import XCTest
@testable import NotchCalendar

final class ScreenGeometryTests: XCTestCase {
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
