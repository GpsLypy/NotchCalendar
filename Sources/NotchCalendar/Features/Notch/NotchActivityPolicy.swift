import Foundation

enum NotchActivity: Equatable {
    case calendar
    case focus
}

enum NotchActivityPolicy {
    /// An explicitly enabled active meeting takes precedence in compact mode.
    /// `hasFocusSession` is the model's presentation eligibility for this launch,
    /// not merely the existence of a saved timer. Both activities remain
    /// available in the expanded surface.
    static func compactActivity(showsMeetings: Bool, meetingIsActive: Bool,
                                showsFocus: Bool, hasFocusSession: Bool) -> NotchActivity {
        if showsMeetings && meetingIsActive { return .calendar }
        return showsFocus && hasFocusSession ? .focus : .calendar
    }

    static func showsShoulders(showsMeetings: Bool, meetingIsActive: Bool,
                               showsFocus: Bool, hasFocusSession: Bool) -> Bool {
        (showsMeetings && meetingIsActive) || (showsFocus && hasFocusSession)
    }
}
