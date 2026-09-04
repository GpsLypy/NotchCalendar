import Foundation

public enum WidgetSnapshotStore {
    public static let calendarKey = "widgets.calendar.snapshot.v1"
    public static let focusKey = "widgets.focus.snapshot.v1"

    public static func readCalendar(
        from defaults: UserDefaults? = nil
    ) -> WidgetCalendarSnapshot? {
        decode(
            WidgetCalendarSnapshot.self,
            key: calendarKey,
            defaults: defaults ?? hostDefaults()
        )
    }

    public static func readFocus(
        from defaults: UserDefaults? = nil
    ) -> WidgetFocusSnapshot? {
        decode(
            WidgetFocusSnapshot.self,
            key: focusKey,
            defaults: defaults ?? hostDefaults()
        )
    }

    @discardableResult
    public static func writeCalendar(
        _ snapshot: WidgetCalendarSnapshot,
        to defaults: UserDefaults = .standard
    ) -> Bool {
        write(snapshot, key: calendarKey, defaults: defaults)
    }

    @discardableResult
    public static func writeFocus(
        _ snapshot: WidgetFocusSnapshot,
        to defaults: UserDefaults = .standard
    ) -> Bool {
        write(snapshot, key: focusKey, defaults: defaults)
    }

    private static func hostDefaults() -> UserDefaults {
        UserDefaults(suiteName: WidgetConstants.hostBundleIdentifier) ?? .standard
    }

    private static func decode<Value: Decodable>(
        _ type: Value.Type,
        key: String,
        defaults: UserDefaults
    ) -> Value? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? decoder.decode(type, from: data)
    }

    private static func write<Value: Encodable>(
        _ value: Value,
        key: String,
        defaults: UserDefaults
    ) -> Bool {
        guard let data = try? encoder.encode(value), defaults.data(forKey: key) != data else {
            return false
        }
        defaults.set(data, forKey: key)
        return true
    }

    private static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }

    private static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        return decoder
    }
}
