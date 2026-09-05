import Foundation
import CoreFoundation

/// An explicit list prevents secrets, account data, cached feeds, and OS permissions from entering a backup.
enum LocalBackupPolicy {
    static let format = "app.notchcalendar.local-backup"
    static let version = 1
    static let maximumFileBytes = 10 * 1_024 * 1_024
    static let dataKeys: Set<String> = ["meeting.notes.v1", "workspace.focus.snapshot.v1"]
    static let stringKeys: Set<String> = [
        "workspace.scratchpad.text", "app.language", "presentation.notchInteractionMode",
        "calendar.secondaryTimeZone", "meetings.hotKeyModifiers", "meetings.hotKeyLetter"
    ]
    static let boolKeys: Set<String> = [
        "presentation.showsMeetingStatus", "calendar.deduplicatesEvents",
        "meetings.remindersEnabled", "meetings.hotKeyEnabled", "workspace.focus.isRunning"
    ]
    static let integerKeys: Set<String> = [
        "workspace.planning.startHour", "workspace.planning.endHour", "workspace.planning.bufferMinutes",
        "meetings.leadMinutes", "workspace.focus.completedSessions", "workspace.focus.selectedMinutes",
        "workspace.focus.remainingSeconds"
    ]
    static let allowedKeys = dataKeys.union(stringKeys).union(boolKeys).union(integerKeys).union([
        "calendar.excludedCalendarIDs", "workspace.scratchpad.lastEdited", "workspace.focus.targetDate"
    ])
}

enum LocalBackupValue: Codable, Equatable, Sendable {
    case string(String), bool(Bool), integer(Int), number(Double), date(Date), strings([String]), data(Data)

    var propertyListValue: Any {
        switch self {
        case .string(let value): value
        case .bool(let value): value
        case .integer(let value): value
        case .number(let value): value
        case .date(let value): value
        case .strings(let value): value
        case .data(let value): value
        }
    }

    static func from(_ value: Any) throws -> Self {
        if let data = value as? Data { return .data(data) }
        if let date = value as? Date { return .date(date) }
        if let string = value as? String { return .string(string) }
        if let strings = value as? [String] { return .strings(strings) }
        if let number = value as? NSNumber {
            if CFGetTypeID(number) == CFBooleanGetTypeID() { return .bool(number.boolValue) }
            let double = number.doubleValue
            guard double.isFinite else { throw LocalBackupError.invalidData }
            if double.rounded() == double, double >= Double(Int.min), double < Double(Int.max) {
                return .integer(number.intValue)
            }
            return .number(double)
        }
        throw LocalBackupError.invalidData
    }
}

struct LocalBackupDocument: Codable, Equatable, Sendable {
    var format = LocalBackupPolicy.format
    var version = LocalBackupPolicy.version
    let exportedAt: Date
    var values: [String: LocalBackupValue]

    static func decode(_ data: Data) throws -> Self {
        guard data.count <= LocalBackupPolicy.maximumFileBytes else { throw LocalBackupError.tooLarge }
        let document: Self
        do { document = try JSONDecoder().decode(Self.self, from: data) }
        catch { throw LocalBackupError.invalidData }
        return try document.validated()
    }

    func encoded() throws -> Data {
        let checked = try validated()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(checked)
        guard data.count <= LocalBackupPolicy.maximumFileBytes else { throw LocalBackupError.tooLarge }
        return data
    }

    /// Validation also canonicalizes nested documents, so unknown fields cannot smuggle unrelated data.
    func validated() throws -> Self {
        guard format == LocalBackupPolicy.format else { throw LocalBackupError.invalidData }
        guard version == LocalBackupPolicy.version else { throw LocalBackupError.unsupportedVersion }
        guard exportedAt.timeIntervalSince1970.isFinite,
              values.keys.allSatisfy(LocalBackupPolicy.allowedKeys.contains) else { throw LocalBackupError.unexpectedSettings }
        var result = self
        for (key, value) in values {
            switch (key, value) {
            case ("workspace.scratchpad.text", .string(let text)):
                guard text.count <= MeetingNotesDocument.maximumTextCharacters else { throw LocalBackupError.tooLarge }
            case ("app.language", .string(let language)):
                guard ["system", "en", "zh-Hans"].contains(language) else { throw LocalBackupError.invalidData }
            case ("presentation.notchInteractionMode", .string(let mode)):
                guard ["intentionalHover", "clickOnly"].contains(mode) else { throw LocalBackupError.invalidData }
            case ("calendar.secondaryTimeZone", .string(let zone)):
                guard zone.isEmpty || TimeZone(identifier: zone) != nil else { throw LocalBackupError.invalidData }
            case ("meetings.hotKeyModifiers", .string(let modifiers)):
                guard ["controlOption", "commandShift", "commandOption", "controlCommand"].contains(modifiers) else { throw LocalBackupError.invalidData }
            case ("meetings.hotKeyLetter", .string(let letter)):
                guard letter.count == 1, let scalar = letter.unicodeScalars.first, (65...90).contains(Int(scalar.value)) else { throw LocalBackupError.invalidData }
            case ("calendar.excludedCalendarIDs", .strings(let ids)):
                guard ids.count <= 500, ids.allSatisfy({ !$0.isEmpty && $0.count <= 1_024 }) else { throw LocalBackupError.invalidData }
            case ("workspace.scratchpad.lastEdited", .date(let date)):
                guard date.timeIntervalSince1970.isFinite else { throw LocalBackupError.invalidData }
            case ("workspace.focus.targetDate", .number(let number)):
                guard number.isFinite else { throw LocalBackupError.invalidData }
            case ("workspace.focus.targetDate", .integer): break
            case ("meeting.notes.v1", .data(let data)):
                result.values[key] = .data(try JSONEncoder().encode(MeetingNotesDocument.decode(data)))
            case ("workspace.focus.snapshot.v1", .data(let data)):
                let focus = try BackupFocusSnapshot.decode(data)
                result.values[key] = .data(try JSONEncoder().encode(focus))
            case let (key, .bool) where LocalBackupPolicy.boolKeys.contains(key): break
            case let (key, .integer(value)) where LocalBackupPolicy.integerKeys.contains(key):
                guard Self.validInteger(value, key: key) else { throw LocalBackupError.invalidData }
            default: throw LocalBackupError.invalidData
            }
        }
        if case let .integer(start)? = result.values["workspace.planning.startHour"],
           case let .integer(end)? = result.values["workspace.planning.endHour"], start >= end {
            throw LocalBackupError.invalidData
        }
        return result
    }

    /// Imported timers always resume paused; historical completion records are retained verbatim.
    func preparedForRestore() throws -> Self {
        var result = try validated()
        if case .data(let data)? = result.values["workspace.focus.snapshot.v1"] {
            var focus = try BackupFocusSnapshot.decode(data)
            focus.isRunning = false
            focus.targetDate = nil
            result.values["workspace.focus.snapshot.v1"] = .data(try JSONEncoder().encode(focus))
        }
        if result.values["workspace.focus.isRunning"] != nil { result.values["workspace.focus.isRunning"] = .bool(false) }
        result.values.removeValue(forKey: "workspace.focus.targetDate")
        return result
    }

    private static func validInteger(_ value: Int, key: String) -> Bool {
        switch key {
        case "workspace.planning.startHour": (0...23).contains(value)
        case "workspace.planning.endHour": (1...24).contains(value)
        case "workspace.planning.bufferMinutes": (0...30).contains(value)
        case "meetings.leadMinutes": [1, 3, 5, 10, 15, 30, 60].contains(value)
        case "workspace.focus.completedSessions": (0...10_000_000).contains(value)
        case "workspace.focus.selectedMinutes": (5...180).contains(value)
        case "workspace.focus.remainingSeconds": (0...10_800).contains(value)
        default: false
        }
    }
}

struct BackupFocusRecord: Codable {
    let id: UUID
    let completedAt: Date
    let minutes: Int
    let kind: String
    let taskLabel: String?
}

/// Deliberately independent of the timer's private persistence type, with a strict import boundary.
struct BackupFocusSnapshot: Codable {
    let selectedMinutes: Int
    let selectedKind: String
    let remainingSeconds: Int
    var isRunning: Bool
    var targetDate: Date?
    let activeSessionID: UUID?
    let completedSessions: Int
    let history: [BackupFocusRecord]
    let taskLabel: String?

    static func decode(_ data: Data) throws -> Self {
        guard data.count <= 2 * 1_024 * 1_024 else { throw LocalBackupError.tooLarge }
        let value: Self
        do { value = try JSONDecoder().decode(Self.self, from: data) }
        catch { throw LocalBackupError.invalidData }
        guard (5...180).contains(value.selectedMinutes), ["focus", "break"].contains(value.selectedKind),
              (0...(value.selectedMinutes * 60)).contains(value.remainingSeconds),
              (0...10_000_000).contains(value.completedSessions), value.history.count <= 1_000,
              value.taskLabel.map({ $0.count <= 200 }) ?? true,
              value.targetDate.map({ $0.timeIntervalSince1970.isFinite }) ?? true,
              Set(value.history.map(\.id)).count == value.history.count,
              value.history.allSatisfy({ record in
                  (5...180).contains(record.minutes) && ["focus", "break"].contains(record.kind) &&
                  record.completedAt.timeIntervalSince1970.isFinite && (record.taskLabel.map { $0.count <= 200 } ?? true)
              }) else { throw LocalBackupError.invalidData }
        return value
    }
}

enum LocalBackupError: Error, LocalizedError {
    case invalidData, unsupportedVersion, tooLarge, unexpectedSettings, readFailed, writeFailed, recoveryFailed, noPreview
    var errorDescription: String? {
        switch self {
        case .invalidData: "This backup contains invalid or incomplete data. Your current data has not changed."
        case .unsupportedVersion: "This backup uses an unsupported version. Update the app that will restore it."
        case .tooLarge: "This backup is too large. The maximum backup file size is 10 MB."
        case .unexpectedSettings: "This backup contains settings that are not supported. Your current data has not changed."
        case .readFailed: "The backup could not be opened. Choose a readable JSON backup file."
        case .writeFailed: "The backup could not be saved. Choose another location and try again."
        case .recoveryFailed: "A recovery copy could not be saved. Nothing was restored; free some disk space and try again."
        case .noPreview: "Choose and review a backup before restoring it."
        }
    }
}
