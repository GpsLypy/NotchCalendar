import AppKit

final class NotchPanel: NSPanel {
    init(contentRect: NSRect) {
        super.init(contentRect: contentRect, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        level = .statusBar
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        hidesOnDeactivate = false
        isMovableByWindowBackground = false
        acceptsMouseMovedEvents = true
        becomesKeyOnlyIfNeeded = true
    }

    // The non-activating style prevents a hover from switching applications,
    // while allowing the explicitly expanded controls to participate in full
    // keyboard access when the person chooses to interact with them.
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}
