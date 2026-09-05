import Foundation
import NotchCalendarShared
import XCTest
@testable import NotchCalendar

@MainActor
final class WidgetSnapshotCoordinatorTests: XCTestCase {
    func testBackgroundDefaultsAndLocaleNotificationsRepublishAllWidgetsOnMainThread() async throws {
        let suite = "NotchCalendarTests.WidgetCoordinator.\(UUID())"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        defaults.set(AppLanguage.english.rawValue, forKey: AppLanguage.storageKey)
        let center = NotificationCenter()
        let calendar = CalendarManager(
            dataSource: CalendarSelectionTestDataSource(eventsByCalendarID: ["work": []]),
            defaults: defaults
        )
        let timer = FocusTimerModel(defaults: defaults)
        var reloadedKinds: [String] = []
        let coordinator = WidgetSnapshotCoordinator(
            calendar: calendar, focusTimer: timer, defaults: defaults,
            notificationCenter: center,
            reloadTimelines: { kind in
                XCTAssertTrue(Thread.isMainThread)
                reloadedKinds.append(kind)
            }
        )
        defer { withExtendedLifetime(coordinator) {} }
        try await waitForSnapshots(language: "en", defaults: defaults)

        for (notification, language) in [
            (UserDefaults.didChangeNotification, AppLanguage.simplifiedChinese),
            (NSLocale.currentLocaleDidChangeNotification, AppLanguage.english)
        ] {
            reloadedKinds.removeAll()
            let rawLanguage = language.rawValue
            // Use a separate defaults instance and private notification center so
            // this exercises an actual background caller without changing user data.
            await Task.detached {
                XCTAssertFalse(Thread.isMainThread)
                UserDefaults(suiteName: suite)!.set(rawLanguage, forKey: AppLanguage.storageKey)
                center.post(name: notification, object: nil)
            }.value

            try await waitForSnapshots(language: language.localizationIdentifier, defaults: defaults)
            XCTAssertEqual(Set(reloadedKinds), [
                WidgetConstants.monthKind, WidgetConstants.agendaKind, WidgetConstants.focusKind
            ])
        }
    }

    private func waitForSnapshots(language: String, defaults: UserDefaults) async throws {
        let deadline = Date().addingTimeInterval(3)
        while Date() < deadline {
            if WidgetSnapshotStore.readCalendar(from: defaults)?.localizationIdentifier == language,
               WidgetSnapshotStore.readFocus(from: defaults)?.localizationIdentifier == language {
                return
            }
            try await Task.sleep(for: .milliseconds(10))
        }
        XCTFail("Background language notification did not update both widget snapshots to \(language)")
    }
}
