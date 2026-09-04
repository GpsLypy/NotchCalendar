import Foundation
import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable, Sendable {
    static let storageKey = "app.language"

    case system
    case simplifiedChinese = "zh-Hans"
    case english = "en"

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .system: "Follow System"
        case .simplifiedChinese: "Simplified Chinese"
        case .english: "English"
        }
    }

    var locale: Locale {
        switch self {
        case .system:
            .autoupdatingCurrent
        case .simplifiedChinese, .english:
            Self.formattingLocale(languageIdentifier: localizationIdentifier)
        }
    }

    var localizationIdentifier: String {
        switch self {
        case .system:
            Self.supportedSystemLocalization()
        case .simplifiedChinese:
            "zh-Hans"
        case .english:
            "en"
        }
    }

    static func persisted(in defaults: UserDefaults = .standard) -> AppLanguage {
        guard let rawValue = defaults.string(forKey: storageKey),
              let language = AppLanguage(rawValue: rawValue) else {
            return .system
        }
        return language
    }

    static func supportedSystemLocalization(
        preferredLanguages: [String] = Locale.preferredLanguages
    ) -> String {
        for preferredLanguage in preferredLanguages {
            let identifier = preferredLanguage.lowercased()
            if identifier == "zh" || identifier.hasPrefix("zh-") || identifier.hasPrefix("zh_") {
                return "zh-Hans"
            }
            if identifier == "en" || identifier.hasPrefix("en-") || identifier.hasPrefix("en_") {
                return "en"
            }
        }
        return "en"
    }

    private static func formattingLocale(languageIdentifier: String) -> Locale {
        guard let region = Locale.autoupdatingCurrent.region?.identifier else {
            return Locale(identifier: languageIdentifier)
        }
        return Locale(identifier: "\(languageIdentifier)_\(region)")
    }
}

private struct AppLanguageEnvironmentKey: EnvironmentKey {
    static let defaultValue = AppLanguage.persisted()
}

extension EnvironmentValues {
    var appLanguage: AppLanguage {
        get { self[AppLanguageEnvironmentKey.self] }
        set { self[AppLanguageEnvironmentKey.self] = newValue }
    }
}

/// Every independently hosted SwiftUI surface observes the same preference so
/// changing the language in Settings refreshes the main window and notch panel
/// without restarting the app.
struct AppLanguageHost<Content: View>: View {
    @AppStorage(AppLanguage.storageKey) private var storedLanguage = AppLanguage.system.rawValue
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    private var language: AppLanguage {
        AppLanguage(rawValue: storedLanguage) ?? .system
    }

    var body: some View {
        content
            .environment(\.appLanguage, language)
            .environment(\.locale, language.locale)
    }
}

enum L10n {
    static func string(
        _ key: String,
        language: AppLanguage,
        _ arguments: CVarArg...
    ) -> String {
        string(key, language: language, arguments: arguments)
    }

    static func string(
        _ key: String,
        language: AppLanguage,
        arguments: [CVarArg]
    ) -> String {
        let format = localizedFormat(key, language: language)
        guard !arguments.isEmpty else { return format }
        return String(format: format, locale: language.locale, arguments: arguments)
    }

    private static func localizedFormat(_ key: String, language: AppLanguage) -> String {
        let localization = language.localizationIdentifier
        if let bundle = localizedLanguageBundle(in: .main, localization: localization) {
            return bundle.localizedString(forKey: key, value: key, table: "Localizable")
        }
        guard let bundle = localizedLanguageBundle(
            in: .module,
            localization: localization
        ) else {
            return key
        }
        return bundle.localizedString(forKey: key, value: key, table: "Localizable")
    }

    private static func localizedLanguageBundle(
        in resourceBundle: Bundle,
        localization: String
    ) -> Bundle? {
        guard let stringsPath = resourceBundle.path(
            forResource: "Localizable",
            ofType: "strings",
            inDirectory: nil,
            forLocalization: localization
        ), let bundle = Bundle(
            path: URL(fileURLWithPath: stringsPath).deletingLastPathComponent().path
        ) else {
            return nil
        }
        return bundle
    }
}
