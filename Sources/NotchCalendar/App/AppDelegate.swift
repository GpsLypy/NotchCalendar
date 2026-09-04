import AppKit
import Darwin

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let state = AppState()
    private var controller: NotchWindowController?
    private var mainWindowController: MainCalendarWindowController?
    private var instanceLockFileDescriptors: [Int32] = []

    func applicationDidFinishLaunching(_ notification: Notification) {
        guard acquireSingleInstanceLock() else {
            // Xcode and a standalone debug launch can otherwise each create an
            // independent non-activating panel, which looks like duplicated UI.
            NSApp.terminate(nil)
            return
        }
        // Regular activation keeps the installed app visible in the Dock. The
        // notch panel remains non-activating, so hovering it still does not steal
        // focus from the current application.
        NSApp.setActivationPolicy(.regular)
        controller = NotchWindowController(state: state)
        controller?.show()
        mainWindowController = MainCalendarWindowController(
            calendar: state.calendar,
            updateChecker: state.updateChecker
        )
        mainWindowController?.reveal()
        Task { await state.updateChecker.checkForUpdates() }
        confirmSuccessfulUpdateLaunchIfNeeded()
    }

    func applicationShouldHandleReopen(
        _ sender: NSApplication,
        hasVisibleWindows flag: Bool
    ) -> Bool {
        mainWindowController?.reveal()
        return false
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationWillTerminate(_ notification: Notification) {
        for fileDescriptor in instanceLockFileDescriptors {
            close(fileDescriptor)
        }
        instanceLockFileDescriptors.removeAll()
    }

    private func acquireSingleInstanceLock() -> Bool {
        let environment = ProcessInfo.processInfo.environment
        let isUpdateHandoff = environment["NOTCH_CALENDAR_UPDATE_TOKEN"] != nil
        let maximumAttempts = isUpdateHandoff ? 50 : 1
        let lockNames = [
            "com.claend.NotchCalendar.lock",
            "com.codex.notch-calendar.lock"
        ]
        var acquiredDescriptors: [Int32] = []

        for lockName in lockNames {
            let lockPath = (NSTemporaryDirectory() as NSString).appendingPathComponent(lockName)
            let fileDescriptor = lockPath.withCString { path in
                open(path, O_CREAT | O_RDWR | O_CLOEXEC, S_IRUSR | S_IWUSR)
            }
            guard fileDescriptor >= 0 else {
                acquiredDescriptors.forEach { close($0) }
                return false
            }

            var acquired = false
            for attempt in 0..<maximumAttempts {
                if flock(fileDescriptor, LOCK_EX | LOCK_NB) == 0 {
                    acquired = true
                    break
                }
                if attempt + 1 < maximumAttempts { usleep(100_000) }
            }
            guard acquired else {
                close(fileDescriptor)
                acquiredDescriptors.forEach { close($0) }
                return false
            }
            acquiredDescriptors.append(fileDescriptor)
        }
        instanceLockFileDescriptors = acquiredDescriptors
        return true
    }

    private func confirmSuccessfulUpdateLaunchIfNeeded() {
        let environment = ProcessInfo.processInfo.environment
        guard let rawMarkerPath = environment["NOTCH_CALENDAR_UPDATE_READY_FILE"],
              let rawToken = environment["NOTCH_CALENDAR_UPDATE_TOKEN"],
              let rawExpectedVersion = environment["NOTCH_CALENDAR_UPDATE_VERSION"],
              let token = UUID(uuidString: rawToken),
              token.uuidString.lowercased() == rawToken,
              let expectedVersion = AppVersion(rawExpectedVersion),
              let runningVersionString = Bundle.main.object(
                forInfoDictionaryKey: "CFBundleShortVersionString"
              ) as? String,
              let runningVersion = AppVersion(runningVersionString),
              runningVersion == expectedVersion else {
            return
        }

        let markerURL = URL(fileURLWithPath: rawMarkerPath, isDirectory: false)
            .standardizedFileURL
        let handoffDirectory = markerURL.deletingLastPathComponent()
        let temporaryRoot = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .resolvingSymlinksInPath()
            .standardizedFileURL
        guard markerURL.lastPathComponent == "launch-ready",
              handoffDirectory.lastPathComponent == "NotchCalendar-update-\(rawToken)",
              handoffDirectory.resolvingSymlinksInPath().deletingLastPathComponent() == temporaryRoot else {
            return
        }

        let confirmation = "\(rawToken)\n\(runningVersion.description)\n\(getpid())\n"
        try? Data(confirmation.utf8).write(to: markerURL, options: [.atomic])
        unsetenv("NOTCH_CALENDAR_UPDATE_READY_FILE")
        unsetenv("NOTCH_CALENDAR_UPDATE_TOKEN")
        unsetenv("NOTCH_CALENDAR_UPDATE_VERSION")
    }
}
