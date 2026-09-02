import AppKit
import Darwin

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let state = AppState()
    private var controller: NotchWindowController?
    private var instanceLockFileDescriptor: Int32 = -1

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
    }

    func applicationWillTerminate(_ notification: Notification) {
        if instanceLockFileDescriptor >= 0 {
            close(instanceLockFileDescriptor)
            instanceLockFileDescriptor = -1
        }
    }

    private func acquireSingleInstanceLock() -> Bool {
        let lockPath = (NSTemporaryDirectory() as NSString).appendingPathComponent("com.claend.NotchCalendar.lock")
        let fileDescriptor = lockPath.withCString { path in
            open(path, O_CREAT | O_RDWR, S_IRUSR | S_IWUSR)
        }
        guard fileDescriptor >= 0 else { return false }
        guard flock(fileDescriptor, LOCK_EX | LOCK_NB) == 0 else {
            close(fileDescriptor)
            return false
        }
        instanceLockFileDescriptor = fileDescriptor
        return true
    }
}
