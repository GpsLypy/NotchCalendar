import Foundation
import XCTest
@testable import NotchCalendar

final class PresentationPolicyTests: XCTestCase {
    func testPassiveLaunchNeverRevealsMainWindow() {
        XCTAssertFalse(
            WindowPresentationPolicy.revealsMainWindow(for: .passiveColdLaunch)
        )
        XCTAssertFalse(
            WindowPresentationPolicy.activatesApplication(for: .passiveColdLaunch)
        )
    }

    func testUpdateHandoffNeverRevealsMainWindow() {
        XCTAssertFalse(
            WindowPresentationPolicy.revealsMainWindow(for: .updateHandoff)
        )
        XCTAssertFalse(
            WindowPresentationPolicy.activatesApplication(for: .updateHandoff)
        )
    }

    func testProvenanceFreeOpenNeverRevealsMainWindow() {
        XCTAssertFalse(
            WindowPresentationPolicy.revealsMainWindow(for: .provenanceFreeOpen)
        )
        XCTAssertFalse(
            WindowPresentationPolicy.activatesApplication(for: .provenanceFreeOpen)
        )
    }

    func testVerifiableExplicitIntentsRevealAndActivateWorkspace() {
        for intent in [
            WindowPresentationIntent.dockReopen,
            .deepLink
        ] {
            XCTAssertTrue(WindowPresentationPolicy.revealsMainWindow(for: intent))
            XCTAssertTrue(WindowPresentationPolicy.activatesApplication(for: intent))
        }
    }

    func testHoverFallsBackToClickWhenGlobalMonitorIsUnavailable() {
        XCTAssertEqual(
            NotchInteractionPolicy.effectiveMode(
                requestedMode: .intentionalHover,
                isGlobalMouseMonitorAvailable: false
            ),
            .clickOnly
        )
        XCTAssertEqual(
            NotchInteractionPolicy.effectiveMode(
                requestedMode: .intentionalHover,
                isGlobalMouseMonitorAvailable: true
            ),
            .intentionalHover
        )
    }

    @MainActor
    func testPresentationPreferencesDefaultToQuietMeetingChanges() throws {
        let suiteName = "PresentationPolicyTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let preferences = PresentationPreferences(defaults: defaults)

        XCTAssertEqual(preferences.notchInteractionMode, .intentionalHover)
        XCTAssertEqual(preferences.hoverResponse, .balanced)
        XCTAssertFalse(preferences.showsMeetingStatus)
    }

    @MainActor
    func testPresentationPreferencesPersistExplicitChoices() throws {
        let suiteName = "PresentationPolicyTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let preferences = PresentationPreferences(defaults: defaults)
        preferences.notchInteractionMode = .clickOnly
        preferences.hoverResponse = .fast
        preferences.showsMeetingStatus = true

        let restored = PresentationPreferences(defaults: defaults)
        XCTAssertEqual(restored.notchInteractionMode, .clickOnly)
        XCTAssertEqual(restored.hoverResponse, .fast)
        XCTAssertTrue(restored.showsMeetingStatus)
    }

    func testHoverResponsePresetsIncreaseDelayAndAnimationInOrder() {
        XCTAssertLessThan(NotchHoverResponse.fast.dwell, NotchHoverResponse.balanced.dwell)
        XCTAssertLessThan(NotchHoverResponse.balanced.dwell, NotchHoverResponse.deliberate.dwell)
        XCTAssertLessThan(NotchHoverResponse.fast.expansionDuration, NotchHoverResponse.balanced.expansionDuration)
        XCTAssertLessThan(NotchHoverResponse.balanced.expansionDuration, NotchHoverResponse.deliberate.expansionDuration)
    }
}
