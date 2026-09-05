import SwiftUI

/// Native settings keep permission state, the next occurrence, and recovery actions
/// together. This view never starts notifications merely by appearing.
struct MeetingSettingsSection: View {
    @ObservedObject var assistant: MeetingAssistant
    @ObservedObject var preferences: MeetingPreferences
    @Environment(\.appLanguage) private var language
    @State private var isRequestingPermission = false

    init(assistant: MeetingAssistant) {
        self.assistant = assistant
        self.preferences = assistant.preferences
    }

    var body: some View {
        Section(t("Meeting reminders")) {
            Toggle(t("Remind me before online meetings"), isOn: Binding(
                get: { preferences.remindersEnabled },
                set: { value in
                    isRequestingPermission = true
                    Task { @MainActor in
                        await assistant.setRemindersEnabled(value)
                        isRequestingPermission = false
                    }
                }
            ))
            .disabled(isRequestingPermission)

            if preferences.remindersEnabled {
                Picker(t("Remind before start"), selection: $preferences.leadMinutes) {
                    ForEach(MeetingPreferences.allowedLeadMinutes, id: \.self) { minutes in
                        Text(t("%d minutes", minutes)).tag(minutes)
                    }
                }
                if let message = assistant.reminderMessageKey {
                    Label(t(message), systemImage: "bell.badge")
                        .foregroundStyle(.orange)
                    if assistant.authorization != .allowed {
                        Button(t("Open notification settings")) { assistant.openNotificationSettings() }
                    }
                } else {
                    Text(t("%d upcoming reminders scheduled", assistant.scheduledReminderCount))
                        .foregroundStyle(.secondary)
                }
                Button(t("Refresh reminders")) { Task { await assistant.refreshNow() } }
            }
            Text(t("Only online meetings in visible calendars are included. Expired reminders are skipped; future reminders refresh while the app is running."))
                .font(.callout)
                .foregroundStyle(.secondary)
            Text(t("Delivery follows your Mac's notification and Focus settings. Keep Notch Calendar running to follow calendar changes."))
                .font(.callout)
                .foregroundStyle(.secondary)

            if let meeting = assistant.nextMeeting {
                LabeledContent(t("Next online meeting")) {
                    VStack(alignment: .trailing, spacing: 3) {
                        Text(meeting.title.isEmpty ? t("Untitled event") : meeting.title)
                            .lineLimit(2)
                        Text(meeting.start, format: .dateTime.month().day().hour().minute().locale(language.locale))
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                }
                if preferences.remindersEnabled && assistant.authorization == .allowed {
                    HStack {
                        Button(t("Remind in 5 minutes")) { Task { await assistant.snooze(meeting, minutes: 5) } }
                            .disabled(meeting.end <= Date().addingTimeInterval(5 * 60))
                        Button(t("Remind in 10 minutes")) { Task { await assistant.snooze(meeting, minutes: 10) } }
                            .disabled(meeting.end <= Date().addingTimeInterval(10 * 60))
                        Button(t("Ignore this occurrence")) { Task { await assistant.ignore(meeting) } }
                    }
                    .controlSize(.small)
                }
            }
        }

        Section(t("Global meeting shortcut")) {
            Toggle(t("Join the nearest meeting from any app"), isOn: $preferences.hotKeyEnabled)
            if preferences.hotKeyEnabled {
                HStack {
                    Picker(t("Modifiers"), selection: $preferences.hotKeyModifiers) {
                        ForEach(MeetingHotKeyModifiers.allCases) { value in
                            Text(value.label).tag(value)
                        }
                    }
                    Picker(t("Key"), selection: $preferences.hotKeyLetter) {
                        ForEach(MeetingPreferences.letters, id: \.self) { letter in Text(letter).tag(letter) }
                    }
                    .frame(width: 110)
                }
                if let message = assistant.shortcutMessageKey {
                    Label(t(message), systemImage: "keyboard.badge.ellipsis")
                        .foregroundStyle(.orange)
                }
            }
            Button(t("Join meeting now")) { assistant.joinFromUserAction() }
            Text(t("Joins an active online meeting, or the next one within 15 minutes. With overlapping meetings, the most recently started one is selected."))
                .font(.callout)
                .foregroundStyle(.secondary)
            Text(t("Uses the selected letter's US keyboard position. No Accessibility permission is needed."))
                .font(.callout)
                .foregroundStyle(.secondary)
            if let feedback = assistant.feedbackMessageKey {
                Text(t(feedback)).foregroundStyle(.secondary)
            }
        }
    }

    private func t(_ key: String, _ arguments: CVarArg...) -> String {
        L10n.string(key, language: language, arguments: arguments)
    }
}
