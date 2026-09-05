import SwiftUI

struct MeetingControlsView: View {
    @ObservedObject var assistant: MeetingAssistant
    @ObservedObject private var preferences: MeetingPreferences
    @Environment(\.appLanguage) private var language
    @Environment(\.openSettings) private var openSettings

    init(assistant: MeetingAssistant) {
        self.assistant = assistant
        self.preferences = assistant.preferences
    }

    var body: some View {
        WorkspaceCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label(t("NEXT MEETING"), systemImage: "video")
                        .font(.system(size: 9.5, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(WorkspacePalette.secondaryText)
                    Spacer()
                    Button { openSettings() } label: {
                        Image(systemName: "bell.badge")
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(WorkspacePalette.secondaryText)
                    .help(t("Meeting reminders"))
                    .accessibilityLabel(t("Meeting reminder settings"))
                }
                if let meeting = assistant.nextMeeting {
                    HStack(alignment: .center, spacing: 14) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(meeting.title.isEmpty ? t("Untitled event") : meeting.title)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(WorkspacePalette.primaryText)
                                .lineLimit(2)
                            Text(meeting.start, format: .dateTime.month().day().hour().minute().locale(language.locale))
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                .foregroundStyle(WorkspacePalette.secondaryText)
                        }
                        Spacer(minLength: 0)
                        Button { assistant.joinFromUserAction() } label: {
                            Label(t("Join meeting"), systemImage: "video.fill")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(WorkspacePalette.accent)
                        .disabled(meeting.start > Date().addingTimeInterval(15 * 60) || meeting.end <= Date())
                        .help(t("Join is available during a meeting and 15 minutes before it starts."))
                    }
                    HStack {
                        if preferences.remindersEnabled && assistant.authorization == .allowed {
                            Menu {
                                Button(t("Remind in 5 minutes")) { Task { await assistant.snooze(meeting, minutes: 5) } }
                                    .disabled(meeting.end <= Date().addingTimeInterval(300))
                                Button(t("Remind in 10 minutes")) { Task { await assistant.snooze(meeting, minutes: 10) } }
                                    .disabled(meeting.end <= Date().addingTimeInterval(600))
                                Divider()
                                Button(t("Ignore this occurrence")) { Task { await assistant.ignore(meeting) } }
                            } label: {
                                Label(t("Reminder options"), systemImage: "clock.arrow.circlepath")
                            }
                            .menuStyle(.borderlessButton)
                            .fixedSize()
                            .foregroundStyle(WorkspacePalette.secondaryText)
                        } else {
                            Button(t("Enable reminders in Settings")) { openSettings() }
                                .buttonStyle(.plain)
                                .foregroundStyle(WorkspacePalette.accent)
                        }
                        Spacer()
                        if preferences.hotKeyEnabled && assistant.shortcutMessageKey == nil {
                            Text(preferences.hotKeyModifiers.label + " " + preferences.hotKeyLetter)
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                .foregroundStyle(WorkspacePalette.secondaryText)
                                .help(t("Global meeting shortcut"))
                        }
                    }
                    .font(.system(size: 11))
                } else {
                    Text(t("No upcoming online meetings in your visible calendars."))
                        .font(.system(size: 12))
                        .foregroundStyle(WorkspacePalette.secondaryText)
                }
                if let feedback = assistant.feedbackMessageKey {
                    Text(t(feedback))
                        .font(.system(size: 11))
                        .foregroundStyle(WorkspacePalette.accent)
                        .accessibilityAddTraits(.updatesFrequently)
                }
                if preferences.remindersEnabled, let message = assistant.reminderMessageKey {
                    Text(t(message))
                        .font(.system(size: 11))
                        .foregroundStyle(.orange)
                }
            }
            .padding(18)
        }
    }

    private func t(_ key: String) -> String { L10n.string(key, language: language) }
}
