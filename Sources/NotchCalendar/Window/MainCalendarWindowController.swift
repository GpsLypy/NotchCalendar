import AppKit
import SwiftUI

@MainActor
final class MainCalendarPresentation: ObservableObject {
    @Published var isActive = false
}

@MainActor
final class MainCalendarWindowController: NSWindowController, NSWindowDelegate {
    private static let frameAutosaveName = "NotchCalendarMainWindow"
    private let presentation = MainCalendarPresentation()

    init(calendar: CalendarManager, updateChecker: UpdateChecker) {
        let window = NSWindow(
            contentRect: .zero,
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.title = "Notch Calendar"
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.appearance = NSAppearance(named: .darkAqua)
        window.backgroundColor = NSColor(
            calibratedRed: 0.025,
            green: 0.025,
            blue: 0.03,
            alpha: 1
        )
        let workspaceView = MainWorkspaceView(
            calendar: calendar,
            updateChecker: updateChecker,
            presentation: presentation
        )
        window.contentViewController = NSHostingController(
            rootView: AppLanguageHost {
                workspaceView
            }
        )
        window.setContentSize(NSSize(width: 980, height: 620))
        window.contentMinSize = NSSize(width: 860, height: 520)
        window.isReleasedWhenClosed = false
        window.tabbingMode = .disallowed
        window.animationBehavior = .documentWindow

        let restoredSavedFrame = window.setFrameUsingName(Self.frameAutosaveName)
        window.setFrameAutosaveName(Self.frameAutosaveName)
        if !restoredSavedFrame {
            window.center()
        }

        super.init(window: window)
        window.delegate = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func reveal() {
        presentation.isActive = true
        if window?.isMiniaturized == true {
            window?.deminiaturize(nil)
        }
        showWindow(nil)
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate()
    }

    func windowWillClose(_ notification: Notification) {
        presentation.isActive = false
    }

    func windowDidMiniaturize(_ notification: Notification) {
        presentation.isActive = false
    }

    func windowDidDeminiaturize(_ notification: Notification) {
        presentation.isActive = true
    }

    func windowDidBecomeKey(_ notification: Notification) {
        presentation.isActive = window?.isMiniaturized == false
    }
}
