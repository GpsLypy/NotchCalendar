import Foundation
import XCTest
@testable import NotchCalendar

final class AppLanguageTests: XCTestCase {
    func testPersistedLanguageDefaultsSafely() throws {
        let suiteName = "AppLanguageTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        XCTAssertEqual(AppLanguage.persisted(in: defaults), .system)

        defaults.set("unsupported", forKey: AppLanguage.storageKey)
        XCTAssertEqual(AppLanguage.persisted(in: defaults), .system)

        defaults.set(AppLanguage.simplifiedChinese.rawValue, forKey: AppLanguage.storageKey)
        XCTAssertEqual(AppLanguage.persisted(in: defaults), .simplifiedChinese)
    }

    func testSystemLanguageResolvesToSupportedLocalization() {
        XCTAssertEqual(
            AppLanguage.supportedSystemLocalization(
                preferredLanguages: ["fr-FR", "zh-Hans-CN", "en-US"]
            ),
            "zh-Hans"
        )
        XCTAssertEqual(
            AppLanguage.supportedSystemLocalization(
                preferredLanguages: ["fr-FR", "en-GB"]
            ),
            "en"
        )
        XCTAssertEqual(
            AppLanguage.supportedSystemLocalization(
                preferredLanguages: ["fr-FR"]
            ),
            "en"
        )
    }

    func testEnglishAndSimplifiedChineseResourcesAreAvailable() {
        XCTAssertEqual(L10n.string("Settings", language: .english), "Settings")
        XCTAssertEqual(L10n.string("Settings", language: .simplifiedChinese), "设置")
        XCTAssertEqual(
            L10n.string(
                "%@ events today",
                language: .simplifiedChinese,
                "3"
            ),
            "今天有 3 项日程"
        )
        XCTAssertEqual(
            L10n.string(
                "%@ percent",
                language: .simplifiedChinese,
                "78"
            ),
            "78%"
        )
    }

    func testMissingTranslationFallsBackToKey() {
        let key = "A translation key that does not exist"
        XCTAssertEqual(L10n.string(key, language: .simplifiedChinese), key)
    }
}
