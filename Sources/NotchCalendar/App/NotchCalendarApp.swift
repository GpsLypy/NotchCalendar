import SwiftUI

@main
struct NotchCalendarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings {
            AppLanguageHost {
                SettingsView(
                    updateChecker: appDelegate.state.updateChecker,
                    presentationPreferences: appDelegate.state.presentationPreferences,
                    calendar: appDelegate.state.calendar,
                    meetingAssistant: appDelegate.state.meetingAssistant,
                    backupStore: appDelegate.state.backupStore
                )
            }
        }
    }
}
