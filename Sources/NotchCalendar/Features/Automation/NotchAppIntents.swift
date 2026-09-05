import AppIntents

struct OpenNotchTodayIntent: AppIntent {
    static let title: LocalizedStringResource = "Open Today"
    static let description = IntentDescription("Open your daily calendar and focus plan in Notch Calendar.")
    static let openAppWhenRun = true
    @MainActor func perform() async throws -> some IntentResult {
        let runtime = try await WorkspaceAutomation.ready()
        runtime.navigate(.today)
        return .result()
    }
}

struct StartNotchFocusIntent: AppIntent {
    static let title: LocalizedStringResource = "Start Focus"
    static let description = IntentDescription("Start a focus session with an optional task label. An unfinished timer is preserved.")
    static let openAppWhenRun = true
    @Parameter(title: "Minutes", default: 25) var minutes: Int
    @Parameter(title: "Task label") var taskLabel: String?
    static var parameterSummary: some ParameterSummary { Summary("Focus for \(\.$minutes) minutes on \(\.$taskLabel)") }
    @MainActor func perform() async throws -> some IntentResult {
        let runtime = try await WorkspaceAutomation.ready()
        try runtime.startFocus(minutes: minutes, taskLabel: taskLabel)
        return .result()
    }
}

struct AppendNotchScratchpadIntent: AppIntent {
    static let title: LocalizedStringResource = "Append to Scratchpad"
    static let description = IntentDescription("Append text to your local scratchpad without replacing existing notes.")
    static let openAppWhenRun = true
    @Parameter(title: "Text") var text: String
    static var parameterSummary: some ParameterSummary { Summary("Append \(\.$text) to the scratchpad") }
    @MainActor func perform() async throws -> some IntentResult {
        let runtime = try await WorkspaceAutomation.ready()
        try runtime.appendScratchpad(text: text)
        return .result()
    }
}

struct JoinNotchMeetingIntent: AppIntent {
    static let title: LocalizedStringResource = "Join Next Meeting"
    static let description = IntentDescription("Open the current or next eligible meeting link from your selected calendars.")
    static let openAppWhenRun = true
    @MainActor func perform() async throws -> some IntentResult {
        let runtime = try await WorkspaceAutomation.ready()
        try await runtime.joinMeeting()
        return .result()
    }
}

struct NotchAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: OpenNotchTodayIntent(), phrases: ["Open today in \(.applicationName)"], shortTitle: "Open Today", systemImageName: "calendar")
        AppShortcut(intent: StartNotchFocusIntent(), phrases: ["Start focus in \(.applicationName)"], shortTitle: "Start Focus", systemImageName: "timer")
        AppShortcut(intent: AppendNotchScratchpadIntent(), phrases: ["Take a note in \(.applicationName)"], shortTitle: "Append Note", systemImageName: "note.text")
        AppShortcut(intent: JoinNotchMeetingIntent(), phrases: ["Join my meeting with \(.applicationName)"], shortTitle: "Join Meeting", systemImageName: "video")
    }
}
