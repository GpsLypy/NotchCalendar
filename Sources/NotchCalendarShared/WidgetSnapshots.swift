import Foundation

public enum WidgetConstants {
    public static let hostBundleIdentifier = "com.codex.notch-calendar"
    public static let widgetBundleIdentifier = "com.codex.notch-calendar.widgets"
    public static let monthKind = "com.codex.notch-calendar.widget.month"
    public static let focusKind = "com.codex.notch-calendar.widget.focus"
    public static let agendaKind = "com.codex.notch-calendar.widget.agenda"
}

public enum WidgetCalendarAuthorization: String, Codable, Sendable {
    case available
    case needsPermission
}

public struct WidgetRGBAColor: Codable, Equatable, Sendable {
    public let red: Double
    public let green: Double
    public let blue: Double
    public let alpha: Double

    public init(red: Double, green: Double, blue: Double, alpha: Double) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
}

public struct WidgetEventSnapshot: Codable, Equatable, Identifiable, Sendable {
    public let id: String
    public let title: String
    public let startDate: Date
    public let endDate: Date
    public let calendarName: String
    public let calendarColor: WidgetRGBAColor?
    public let isAllDay: Bool

    public init(
        id: String,
        title: String,
        startDate: Date,
        endDate: Date,
        calendarName: String,
        calendarColor: WidgetRGBAColor?,
        isAllDay: Bool
    ) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.calendarName = calendarName
        self.calendarColor = calendarColor
        self.isAllDay = isAllDay
    }

    public func occurs(on date: Date, calendar: Calendar) -> Bool {
        let dayStart = calendar.startOfDay(for: date)
        guard let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else {
            return false
        }
        return startDate < dayEnd && endDate > dayStart
    }
}

public struct WidgetCalendarSnapshot: Codable, Equatable, Sendable {
    public let authorization: WidgetCalendarAuthorization
    public let events: [WidgetEventSnapshot]
    public let localizationIdentifier: String
    public let timeZoneIdentifier: String

    public init(
        authorization: WidgetCalendarAuthorization,
        events: [WidgetEventSnapshot],
        localizationIdentifier: String,
        timeZoneIdentifier: String
    ) {
        self.authorization = authorization
        self.events = events
        self.localizationIdentifier = localizationIdentifier
        self.timeZoneIdentifier = timeZoneIdentifier
    }
}

public enum WidgetFocusPhase: Equatable, Sendable {
    case ready
    case running
    case paused
    case complete
}

public struct WidgetFocusSnapshot: Codable, Equatable, Sendable {
    public let selectedMinutes: Int
    public let remainingSecondsAtWrite: Int
    public let isRunning: Bool
    public let targetDate: Date?
    public let completedSessions: Int
    public let localizationIdentifier: String
    private let storedIsBreak: Bool?
    private let storedHasUnfinishedSession: Bool?

    private enum CodingKeys: String, CodingKey {
        case selectedMinutes, remainingSecondsAtWrite, isRunning, targetDate
        case completedSessions, localizationIdentifier
        case storedIsBreak = "isBreak"
        case storedHasUnfinishedSession = "hasUnfinishedSession"
    }

    public init(
        selectedMinutes: Int,
        remainingSecondsAtWrite: Int,
        isRunning: Bool,
        targetDate: Date?,
        completedSessions: Int,
        localizationIdentifier: String,
        isBreak: Bool? = nil,
        hasUnfinishedSession: Bool? = nil
    ) {
        self.selectedMinutes = selectedMinutes
        self.remainingSecondsAtWrite = remainingSecondsAtWrite
        self.isRunning = isRunning
        self.targetDate = targetDate
        self.completedSessions = completedSessions
        self.localizationIdentifier = localizationIdentifier
        storedIsBreak = isBreak
        storedHasUnfinishedSession = hasUnfinishedSession
    }

    /// Older app snapshots used the five-minute preset exclusively for breaks.
    public var isBreak: Bool { storedIsBreak ?? (selectedMinutes == 5) }

    /// Explicit session state also identifies a timer paused before its first tick.
    public var hasUnfinishedSession: Bool {
        storedHasUnfinishedSession
            ?? (isRunning || (remainingSecondsAtWrite > 0 && remainingSecondsAtWrite < totalSeconds))
    }

    public var totalSeconds: Int {
        max(1, selectedMinutes * 60)
    }

    public func remainingSeconds(at date: Date) -> Int {
        guard isRunning, let targetDate else {
            return min(totalSeconds, max(0, remainingSecondsAtWrite))
        }
        return min(
            totalSeconds,
            max(0, remainingSecondsAtWrite),
            max(0, Int(ceil(targetDate.timeIntervalSince(date))))
        )
    }

    public func progress(at date: Date) -> Double {
        1 - Double(remainingSeconds(at: date)) / Double(totalSeconds)
    }

    public func phase(at date: Date) -> WidgetFocusPhase {
        let remaining = remainingSeconds(at: date)
        if remaining == 0 { return .complete }
        if isRunning { return .running }
        if hasUnfinishedSession { return .paused }
        return .ready
    }
}
