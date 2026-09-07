import AppKit
import SwiftUI

enum MainCalendarWindowLayout {
    static let preferredContentSize = NSSize(width: 1120, height: 780)

    /// Grow a legacy window once, then preserve later user sizes. Keep the
    /// entire frame reachable on the current display, including its title bar.
    static func fittedFrame(_ frame: NSRect, visibleFrame: NSRect, expandTo preferredSize: NSSize? = nil) -> NSRect {
        let available = visibleFrame.insetBy(dx: 16, dy: 16)
        let size = NSSize(
            width: min(available.width, max(frame.width, preferredSize?.width ?? frame.width)),
            height: min(available.height, max(frame.height, preferredSize?.height ?? frame.height))
        )
        return NSRect(
            x: min(max(frame.midX - size.width / 2, available.minX), available.maxX - size.width),
            y: min(max(frame.maxY - size.height, available.minY), available.maxY - size.height),
            width: size.width,
            height: size.height
        )
    }
}

@MainActor
final class MainCalendarPresentation: ObservableObject {
    @Published var isActive = false
    @Published var selectedDestination = WorkspaceDestination.calendar
}

@MainActor
final class MainCalendarWindowController: NSWindowController, NSWindowDelegate {
    private static let legacyFrameAutosaveName = "NotchCalendarMainWindow"
    private static let frameAutosaveName = "NotchCalendarMainWindow.WideLayout"
    private let presentation = MainCalendarPresentation()

    init(
        calendar: CalendarManager,
        focusTimer: FocusTimerModel,
        updateChecker: UpdateChecker,
        notesStore: MeetingNotesStore = MeetingNotesStore(),
        meetingAssistant: MeetingAssistant? = nil
    ) {
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
        let presentation = self.presentation
        let workspaceView = MainWorkspaceView(
            calendar: calendar,
            focusTimer: focusTimer,
            updateChecker: updateChecker,
            presentation: presentation,
            notesStore: notesStore,
            meetingAssistant: meetingAssistant
        )
        window.contentViewController = NSHostingController(
            rootView: AppLanguageHost {
                WorkspaceVisibilityHost(presentation: presentation) { workspaceView }
            }
        )
        window.setContentSize(MainCalendarWindowLayout.preferredContentSize)
        let preferredFrameSize = window.frame.size
        window.contentMinSize = NSSize(width: 860, height: 520)
        window.isReleasedWhenClosed = false
        window.tabbingMode = .disallowed
        window.animationBehavior = .documentWindow

        let restoredSavedFrame = window.setFrameUsingName(Self.frameAutosaveName)
        let restoredLegacyFrame = !restoredSavedFrame && window.setFrameUsingName(Self.legacyFrameAutosaveName)
        if !restoredSavedFrame && !restoredLegacyFrame {
            window.center()
        }
        if let screen = window.screen ?? NSScreen.main {
            window.setFrame(MainCalendarWindowLayout.fittedFrame(
                window.frame, visibleFrame: screen.visibleFrame,
                expandTo: restoredSavedFrame ? nil : preferredFrameSize
            ), display: false)
        }
        window.setFrameAutosaveName(Self.frameAutosaveName)
        window.saveFrame(usingName: Self.frameAutosaveName)

        super.init(window: window)
        window.delegate = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func reveal(
        destination: WorkspaceDestination? = nil,
        activateApplication: Bool = true,
        reason: String = "explicit"
    ) {
        if let destination {
            presentation.selectedDestination = destination
        }
        presentation.isActive = true
        if window?.isMiniaturized == true {
            window?.deminiaturize(nil)
        }
        showWindow(nil)
        window?.makeKeyAndOrderFront(nil)
        if activateApplication {
            NSApp.activate()
        }
        PresentationDiagnostics.event(
            "main-window reveal reason=\(reason) activate=\(activateApplication)"
        )
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
