import SwiftUI

@main
struct NotchCalendarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings { SettingsView() }
    }
}
