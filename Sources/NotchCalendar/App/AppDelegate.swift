import AppKit
import Darwin
import AppIntents

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let state = AppState()
    private var controller: NotchWindowController?
    private var mainWindowController: MainCalendarWindowController?
    private var instanceLockFileDescriptors: [Int32] = []
    private var pendingWidgetDestination: WorkspaceDestination?

    private let launchedByUpdateHandoff =
        ProcessInfo.processInfo.environment["NOTCH_CALENDAR_UPDATE_TOKEN"] != nil

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
            focusTimer: state.focusTimer,
            updateChecker: state.updateChecker,
            notesStore: state.notesStore,
            meetingAssistant: state.meetingAssistant
        )
        state.meetingAssistant.start()
        WorkspaceAutomation.shared = WorkspaceAutomation(
            focusTimer: state.focusTimer,
            notes: state.notesStore,
            navigate: { [weak self] destination in
                self?.revealMainWindow(destination: destination, intent: .deepLink, reason: "explicit-shortcut")
            },
            joinMeeting: { [weak self] in
                guard let self else { throw WorkspaceAutomationError("Open Notch Calendar and try the shortcut again.") }
                _ = try await self.state.meetingAssistant.joinNextMeeting()
            }
        )
        NotchAppShortcuts.updateAppShortcutParameters()
        if let pendingWidgetDestination {
            revealMainWindow(
                destination: pendingWidgetDestination,
                intent: .deepLink,
                reason: "widget-deep-link"
            )
            self.pendingWidgetDestination = nil
        }
        Task { await state.updateChecker.checkForUpdates() }
        confirmSuccessfulUpdateLaunchIfNeeded()
        let launchIntent: WindowPresentationIntent = launchedByUpdateHandoff
            ? .updateHandoff
            : .passiveColdLaunch
        PresentationDiagnostics.event(
            "cold-launch intent=\(String(describing: launchIntent)) main-window=quiet"
        )
    }

    /// This callback does not carry launch provenance: LaunchServices, session
    /// restoration, or a person may all produce it. Default to quiet so an
    /// unverified cold-start path can never raise a window over another app.
    func applicationOpenUntitledFile(_ sender: NSApplication) -> Bool {
        let intent: WindowPresentationIntent = launchedByUpdateHandoff
            ? .updateHandoff
            : .provenanceFreeOpen
        PresentationDiagnostics.event(
            "main-window suppressed reason=\(String(describing: intent))"
        )
        return true
    }

    func applicationShouldHandleReopen(
        _ sender: NSApplication,
        hasVisibleWindows flag: Bool
    ) -> Bool {
        revealMainWindow(intent: .dockReopen, reason: "dock-reopen")
        return false
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        guard let destination = urls.lazy.compactMap(widgetDestination).first else { return }
        if mainWindowController != nil {
            revealMainWindow(
                destination: destination,
                intent: .deepLink,
                reason: "widget-deep-link"
            )
        } else {
            pendingWidgetDestination = destination
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationWillTerminate(_ notification: Notification) {
        state.meetingAssistant.stop()
        WorkspaceAutomation.shared = nil
        for fileDescriptor in instanceLockFileDescriptors {
            close(fileDescriptor)
        }
        instanceLockFileDescriptors.removeAll()
    }

    private func revealMainWindow(
        destination: WorkspaceDestination? = nil,
        intent: WindowPresentationIntent,
        reason: String
    ) {
        guard WindowPresentationPolicy.revealsMainWindow(for: intent) else {
            PresentationDiagnostics.event("main-window suppressed reason=\(reason)")
            return
        }
        mainWindowController?.reveal(
            destination: destination,
            activateApplication: WindowPresentationPolicy.activatesApplication(for: intent),
            reason: reason
        )
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

    private func widgetDestination(for url: URL) -> WorkspaceDestination? {
        guard url.scheme?.lowercased() == "notchcalendar" else { return nil }
        let route = url.host?.lowercased()
            ?? url.pathComponents.dropFirst().first?.lowercased()
        guard let route else { return nil }
        return WorkspaceDestination(rawValue: route)
    }
}
