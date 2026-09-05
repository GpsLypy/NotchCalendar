import Foundation
import Combine

enum MeetingHotKeyModifiers: String, CaseIterable, Identifiable {
    case controlOption, commandShift, commandOption, controlCommand
    var id: String { rawValue }
    var label: String {
        switch self {
        case .controlOption: "⌃ ⌥"
        case .commandShift: "⌘ ⇧"
        case .commandOption: "⌘ ⌥"
        case .controlCommand: "⌃ ⌘"
        }
    }
}

@MainActor
final class MeetingPreferences: ObservableObject {
    static let reminderEnabledKey = "meetings.remindersEnabled"
    static let leadMinutesKey = "meetings.leadMinutes"
    static let hotKeyEnabledKey = "meetings.hotKeyEnabled"
    static let hotKeyModifiersKey = "meetings.hotKeyModifiers"
    static let hotKeyLetterKey = "meetings.hotKeyLetter"
    static let overridesKey = "meetings.overrides"
    static let allowedLeadMinutes = [1, 3, 5, 10, 15, 30, 60]

    private let defaults: UserDefaults
    @Published var remindersEnabled: Bool { didSet { defaults.set(remindersEnabled, forKey: Self.reminderEnabledKey) } }
    @Published var leadMinutes: Int { didSet { defaults.set(leadMinutes, forKey: Self.leadMinutesKey) } }
    @Published var hotKeyEnabled: Bool { didSet { defaults.set(hotKeyEnabled, forKey: Self.hotKeyEnabledKey) } }
    @Published var hotKeyModifiers: MeetingHotKeyModifiers { didSet { defaults.set(hotKeyModifiers.rawValue, forKey: Self.hotKeyModifiersKey) } }
    @Published var hotKeyLetter: String { didSet { defaults.set(hotKeyLetter, forKey: Self.hotKeyLetterKey) } }
    @Published private(set) var overrides: [String: MeetingReminderOverride]

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        remindersEnabled = defaults.bool(forKey: Self.reminderEnabledKey)
        let lead = defaults.integer(forKey: Self.leadMinutesKey)
        leadMinutes = Self.allowedLeadMinutes.contains(lead) ? lead : 5
        hotKeyEnabled = defaults.bool(forKey: Self.hotKeyEnabledKey)
        hotKeyModifiers = MeetingHotKeyModifiers(rawValue: defaults.string(forKey: Self.hotKeyModifiersKey) ?? "") ?? .controlOption
        let letter = defaults.string(forKey: Self.hotKeyLetterKey) ?? "J"
        hotKeyLetter = Self.letters.contains(letter) ? letter : "J"
        overrides = defaults.data(forKey: Self.overridesKey).flatMap {
            try? JSONDecoder().decode([String: MeetingReminderOverride].self, from: $0)
        } ?? [:]
    }

    static var letters: [String] { (65...90).compactMap(UnicodeScalar.init).map(String.init) }

    func setOverride(_ value: MeetingReminderOverride, for key: String) {
        overrides[key] = value
        persistOverrides()
    }

    func pruneOverrides(now: Date) {
        let valid = overrides.filter { $0.value.expiresAt > now }
        guard valid != overrides else { return }
        overrides = valid
        persistOverrides()
    }

    /// Restore is applied without prompting for notification permission.
    func reload() {
        let restored = MeetingPreferences(defaults: defaults)
        remindersEnabled = restored.remindersEnabled
        leadMinutes = restored.leadMinutes
        hotKeyEnabled = restored.hotKeyEnabled
        hotKeyModifiers = restored.hotKeyModifiers
        hotKeyLetter = restored.hotKeyLetter
        overrides = restored.overrides
    }

    private func persistOverrides() {
        if let data = try? JSONEncoder().encode(overrides) { defaults.set(data, forKey: Self.overridesKey) }
    }
}
