import AppKit
import SwiftUI
import Combine
import Darwin

@MainActor
final class NotchWindowController: NSObject, ObservableObject {
    private let state: AppState
    private let panel: NotchPanel
    private nonisolated(unsafe) var stateObserver: AnyCancellable?
    private nonisolated(unsafe) var globalMouseMonitor: Any?
    private nonisolated(unsafe) var localMouseMonitor: Any?
    // Alcove-like glanceable layout: wide enough for agenda + month, but shallow
    // enough to feel attached to the camera housing rather than a modal window.
    private let expandedSize = NSSize(width: 600, height: 390)
    private var expandTask: Task<Void, Never>?
    private var collapseTask: Task<Void, Never>?
    private var expandedCardHeight: CGFloat?
    private var pointerEvaluationQueued = false

    init(state: AppState) {
        self.state = state
        let screen = NSScreen.main ?? NSScreen.screens[0]
        panel = NotchPanel(contentRect: ScreenGeometry.panelFrame(on: screen, size: Self.compactSize(on: screen), expanded: false))
        super.init()
        let hostingView = NSHostingView(
            rootView: NotchRootView(
                state: state,
                expandedContentTopInset: ScreenGeometry.expandedContentTopInset(on: screen)
            ) { [weak self] height in
                self?.updateExpandedCardHeight(height)
            }
        )
        hostingView.wantsLayer = true
        hostingView.layerContentsRedrawPolicy = .onSetNeedsDisplay
        panel.contentView = hostingView
        stateObserver = state.$isExpanded.removeDuplicates().sink { [weak self] expanded in
            // `@Published` sends from `willSet`, so defer until the new value is
            // actually stored. This also coalesces rapid hover re-entry into the
            // latest desired presentation state.
            DispatchQueue.main.async { [weak self] in
                guard let self, self.state.isExpanded == expanded else {
                    self?.trace("drop superseded state update")
                    return
                }
                self.applyExpansionState(expanded)
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(reposition), name: NSApplication.didChangeScreenParametersNotification, object: nil)
        // A global monitor is required because this non-activating panel does not
        // own the active application's event stream.
        globalMouseMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved]) { [weak self] _ in
            Task { @MainActor in self?.queuePointerEvaluation() }
        }
        localMouseMonitor = NSEvent.addLocalMonitorForEvents(
            matching: [.mouseMoved, .mouseEntered, .mouseExited]
        ) { [weak self] event in
            Task { @MainActor in self?.queuePointerEvaluation() }
            return event
        }
        trace("hover monitors installed")
    }

    deinit {
        stateObserver?.cancel()
        if let globalMouseMonitor { NSEvent.removeMonitor(globalMouseMonitor) }
        if let localMouseMonitor { NSEvent.removeMonitor(localMouseMonitor) }
        NotificationCenter.default.removeObserver(self)
    }

    func show() { panel.orderFrontRegardless() }

    @objc private func reposition() {
        resize(expanded: state.isExpanded, animated: false)
        if !state.isExpanded { state.isPresentationExpanded = false }
        evaluatePointer()
    }

    private func evaluatePointer() {
        guard let screen = panel.screen ?? NSScreen.main else { return }
        let pointer = NSEvent.mouseLocation

        if state.isExpanded {
            if expandedHoverFrame().contains(pointer) {
                collapseTask?.cancel()
                collapseTask = nil
            } else {
                scheduleCollapse()
            }
        } else {
            let triggerFrame = ScreenGeometry.hoverTriggerFrame(
                on: screen,
                compactSize: Self.compactSize(on: screen)
            )
            if triggerFrame.contains(pointer) {
                expandTask?.cancel()
                expandTask = nil
                scheduleExpand()
            } else {
                expandTask?.cancel()
                expandTask = nil
            }
        }
    }

    private func scheduleExpand() {
        guard expandTask == nil else { return }
        expandTask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: .milliseconds(90))
            guard let self, !Task.isCancelled else { return }
            self.expandTask = nil
            guard !self.state.isExpanded else { return }
            let pointer = NSEvent.mouseLocation
            guard let screen = self.panel.screen ?? NSScreen.main,
                  ScreenGeometry.hoverTriggerFrame(
                    on: screen,
                    compactSize: Self.compactSize(on: screen)
                  ).contains(pointer) else { return }
            self.trace("expand confirmed at (\(Int(pointer.x)), \(Int(pointer.y)))")
            self.state.isExpanded = true
        }
    }

    private func applyExpansionState(_ expanded: Bool) {
        if expanded {
            // The notch is a glanceable "today" surface. Dates picked from the
            // month grid are temporary exploration and should not persist into
            // the next independent hover session.
            state.selectedDate = Date()
            // Render the detailed view while it is still clipped by the compact
            // panel, then reveal it as the panel unfolds. This avoids stretching
            // the compact pill into a large empty rectangle.
            state.isPresentationExpanded = true
            DispatchQueue.main.async { [weak self] in
                guard let self, self.state.isExpanded else { return }
                self.resize(expanded: true)
            }
        } else {
            // Keep the detailed view alive until the panel has visibly folded
            // back into the notch. Replacing it before the frame animation was
            // the source of the previous abrupt, empty-card collapse.
            resize(expanded: false)
        }
    }

    private func updateExpandedCardHeight(_ height: CGFloat) {
        // Preference removal reports zero as the compact view replaces the card;
        // retain the last expanded measurement until the next expansion reports.
        guard height > 36 else { return }
        expandedCardHeight = height
    }

    private func expandedHoverFrame() -> NSRect {
        guard let expandedCardHeight else { return panel.frame }
        let height = min(expandedCardHeight + 2, panel.frame.height)
        return NSRect(
            x: panel.frame.minX,
            y: panel.frame.maxY - height,
            width: panel.frame.width,
            height: height
        )
    }

    private func queuePointerEvaluation() {
        guard !pointerEvaluationQueued else { return }
        pointerEvaluationQueued = true
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.pointerEvaluationQueued = false
            self.evaluatePointer()
        }
    }

    private func scheduleCollapse() {
        guard collapseTask == nil else { return }
        collapseTask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: .milliseconds(30))
            guard let self, !Task.isCancelled else { return }
            self.collapseTask = nil
            guard self.state.isExpanded, !self.expandedHoverFrame().contains(NSEvent.mouseLocation) else { return }
            self.trace("collapse confirmed")
            self.state.isExpanded = false
        }
    }

    private func resize(expanded: Bool, animated: Bool = true) {
        // Notifications and AppKit animation callbacks may arrive a run-loop late.
        // Never let an obsolete compact request reverse a newer expansion (or vice
        // versa); that was the source of the visible wobble during fast re-entry.
        guard expanded == state.isExpanded else {
            trace("drop stale \(expanded ? "expand" : "collapse") resize")
            return
        }
        guard let screen = panel.screen ?? NSScreen.main else { return }
        let newFrame = ScreenGeometry.panelFrame(
            on: screen,
            size: expanded ? expandedSize : Self.compactSize(on: screen),
            expanded: expanded
        )
        trace("animate \(expanded ? "expand" : "collapse") to \(Int(newFrame.width))×\(Int(newFrame.height))")
        if animated {
            NSAnimationContext.runAnimationGroup { context in
                // AppKit hands this to Core Animation, which is display-synchronised
                // and therefore presents at the ProMotion refresh rate when available.
                context.duration = expanded ? 0.32 : 0.26
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                panel.animator().setFrame(newFrame, display: true)
                if !expanded {
                    context.completionHandler = { [weak self] in
                        Task { @MainActor in
                            guard let self, !self.state.isExpanded else { return }
                            self.state.isPresentationExpanded = false
                        }
                    }
                }
            }
        } else {
            panel.setFrame(newFrame, display: true)
            if !expanded { state.isPresentationExpanded = false }
        }
        DispatchQueue.main.async { [weak self] in self?.evaluatePointer() }
    }

    private static func compactSize(on screen: NSScreen) -> NSSize {
        // On a notched Mac, match the hardware width exactly so the card reads as
        // one continuous shape. The date/time layout fits within M3 Pro's cutout.
        let notchWidth = ScreenGeometry.notchBounds(on: screen)?.width ?? 226
        return NSSize(width: notchWidth, height: 36)
    }

    private func trace(_ message: String) {
        #if DEBUG
        print("[NotchCalendar] \(message)")
        // Xcode flushes stdout for us, but the standalone diagnostic process is
        // connected to a pipe. Flush explicitly so hover timing is observable.
        fflush(stdout)
        #endif
    }
}
