import AppKit
import SwiftUI
import Combine
import Darwin

private enum NotchExpansionOrigin: Equatable {
    case intentionalHover
    case explicitInteraction
}

@MainActor
final class NotchWindowController: NSObject, ObservableObject {
    private let state: AppState
    private let panel: NotchPanel
    private let layoutMetrics: NotchLayoutMetrics
    private nonisolated(unsafe) var stateObserver: AnyCancellable?
    private nonisolated(unsafe) var preferencesObserver: AnyCancellable?
    private nonisolated(unsafe) var globalMouseMonitor: Any?
    private nonisolated(unsafe) var localMouseMonitor: Any?
    // Alcove-like glanceable layout: wide enough for agenda + month, but shallow
    // enough to feel attached to the camera housing rather than a modal window.
    private let expandedSize = NSSize(width: 600, height: 390)
    private var expandTask: Task<Void, Never>?
    private var collapseTask: Task<Void, Never>?
    private var expandedCardHeight: CGFloat?
    private var pointerEvaluationQueued = false
    private var compactMeetingIsActive: Bool
    private var pointerWasInsideTrigger = false
    private var hoverAnchor: NSPoint?
    private var pendingExpansionOrigin: NotchExpansionOrigin?
    private let hoverDwell = Duration.milliseconds(350)
    private let hoverMovementTolerance: CGFloat = 8

    init(state: AppState) {
        self.state = state
        let screen = NSScreen.main ?? NSScreen.screens[0]
        let notchBounds = ScreenGeometry.notchBounds(on: screen)
        let compactMeetingIsActive = state.presentationPreferences.showsMeetingStatus && UpcomingEventEngine.status(
            now: Date(),
            events: state.calendar.todayEvents
        ).isActive
        self.compactMeetingIsActive = compactMeetingIsActive
        layoutMetrics = NotchLayoutMetrics(
            expandedContentTopInset: ScreenGeometry.expandedContentTopInset(on: screen),
            compactNotchWidth: notchBounds?.width,
            compactNotchDepth: notchBounds?.depth,
            showsCompactMeetingStatus: state.presentationPreferences.showsMeetingStatus,
            showsClickTarget: state.presentationPreferences.notchInteractionMode == .clickOnly
        )
        panel = NotchPanel(
            contentRect: ScreenGeometry.panelFrame(
                on: screen,
                size: Self.compactSize(
                    on: screen,
                    showsMeetingStatus: compactMeetingIsActive,
                    showsClickTarget: state.presentationPreferences.notchInteractionMode == .clickOnly
                ),
                expanded: false
            )
        )
        super.init()
        let hostingView = NSHostingView(
            rootView: AppLanguageHost {
                NotchRootView(
                    state: state,
                    layoutMetrics: layoutMetrics,
                    onExplicitExpansion: { [weak self] in
                        self?.requestExpansion(origin: .explicitInteraction)
                    },
                    onExpandedCardHeightChange: { [weak self] height in
                        self?.updateExpandedCardHeight(height)
                    },
                    onCompactMeetingActivityChange: { [weak self] isActive in
                        self?.updateCompactMeetingActivity(isActive)
                    }
                )
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
        preferencesObserver = state.presentationPreferences.$notchInteractionMode
            .combineLatest(state.presentationPreferences.$showsMeetingStatus)
            .dropFirst()
            .sink { [weak self] _, _ in
                DispatchQueue.main.async { [weak self] in
                    self?.applyPresentationPreferences()
                }
            }
        NotificationCenter.default.addObserver(self, selector: #selector(reposition), name: NSApplication.didChangeScreenParametersNotification, object: nil)
        // A global monitor is required because this non-activating panel does not
        // own the active application's event stream.
        globalMouseMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved]) { [weak self] _ in
            Task { @MainActor in self?.queuePointerEvaluation() }
        }
        // Compact shoulder content is hover-driven. Let menu-bar controls beneath
        // the transparent panel keep receiving clicks. Click-only mode opts back
        // into panel hit testing explicitly.
        if globalMouseMonitor == nil {
            PresentationDiagnostics.event(
                "global mouse monitor unavailable; notch interaction fell back to click-only"
            )
        }
        state.presentationPreferences.setHoverMonitorAvailable(globalMouseMonitor != nil)
        applyPresentationPreferences(animated: false)
        localMouseMonitor = NSEvent.addLocalMonitorForEvents(
            matching: [.mouseMoved, .mouseEntered, .mouseExited, .leftMouseDown]
        ) { [weak self] event in
            let windowNumber = event.windowNumber
            if event.type == .leftMouseDown {
                Task { @MainActor in
                    self?.promoteExpandedInteractionToKeyboard(windowNumber: windowNumber)
                }
            } else {
                Task { @MainActor in self?.queuePointerEvaluation() }
            }
            return event
        }
        trace("hover monitors installed")
    }

    deinit {
        stateObserver?.cancel()
        preferencesObserver?.cancel()
        if let globalMouseMonitor { NSEvent.removeMonitor(globalMouseMonitor) }
        if let localMouseMonitor { NSEvent.removeMonitor(localMouseMonitor) }
        NotificationCenter.default.removeObserver(self)
    }

    func show() { panel.orderFrontRegardless() }

    @objc private func reposition() {
        cancelPendingHover()
        collapseTask?.cancel()
        collapseTask = nil
        if state.isExpanded {
            state.isExpanded = false
            resize(expanded: false, animated: false)
        } else {
            resize(expanded: false, animated: false)
        }
        PresentationDiagnostics.event("notch collapsed after screen change")
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
            guard effectiveInteractionMode == .intentionalHover else {
                cancelPendingHover()
                return
            }
            let triggerFrame = ScreenGeometry.hoverTriggerFrame(
                on: screen,
                compactSize: Self.compactSize(
                    on: screen,
                    showsMeetingStatus: compactMeetingIsActive,
                    showsClickTarget: false
                )
            )
            let isInside = triggerFrame.contains(pointer)
            if isInside {
                if !pointerWasInsideTrigger {
                    beginHoverCandidate(at: pointer)
                } else if let hoverAnchor,
                          pointerDistance(from: hoverAnchor, to: pointer) > hoverMovementTolerance {
                    beginHoverCandidate(at: pointer)
                }
            } else {
                cancelPendingHover()
            }
            pointerWasInsideTrigger = isInside
        }
    }

    private func beginHoverCandidate(at pointer: NSPoint) {
        expandTask?.cancel()
        hoverAnchor = pointer
        expandTask = Task { @MainActor [weak self] in
            guard let self else { return }
            try? await Task.sleep(for: self.hoverDwell)
            guard !Task.isCancelled else { return }
            self.expandTask = nil
            guard !self.state.isExpanded else { return }
            let pointer = NSEvent.mouseLocation
            guard let screen = self.panel.screen ?? NSScreen.main,
                  let hoverAnchor = self.hoverAnchor,
                  self.pointerDistance(from: hoverAnchor, to: pointer) <= self.hoverMovementTolerance,
                  ScreenGeometry.hoverTriggerFrame(
                    on: screen,
                    compactSize: Self.compactSize(
                        on: screen,
                        showsMeetingStatus: self.compactMeetingIsActive,
                        showsClickTarget: false
                    )
                  ).contains(pointer) else { return }
            self.trace("expand confirmed at (\(Int(pointer.x)), \(Int(pointer.y)))")
            PresentationDiagnostics.event("notch expanded reason=intentional-hover")
            self.requestExpansion(origin: .intentionalHover)
        }
    }

    private func requestExpansion(origin: NotchExpansionOrigin) {
        guard !state.isExpanded else {
            if origin == .explicitInteraction { panel.makeKey() }
            return
        }
        pendingExpansionOrigin = origin
        state.isExpanded = true
    }

    private func promoteExpandedInteractionToKeyboard(windowNumber: Int) {
        guard state.isExpanded, panel.windowNumber == windowNumber else { return }
        panel.makeKey()
        PresentationDiagnostics.event("notch keyboard focus reason=expanded-click")
    }

    private func applyExpansionState(_ expanded: Bool) {
        if expanded {
            let expansionOrigin = pendingExpansionOrigin ?? .intentionalHover
            pendingExpansionOrigin = nil
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
                if expansionOrigin == .explicitInteraction {
                    self.panel.makeKey()
                    PresentationDiagnostics.event("notch keyboard focus reason=explicit-interaction")
                }
            }
        } else {
            pendingExpansionOrigin = nil
            // Keep the detailed view alive until the panel has visibly folded
            // back into the notch. Replacing it before the frame animation was
            // the source of the previous abrupt, empty-card collapse.
            resize(expanded: false)
        }
    }

    private func updateExpandedCardHeight(_ height: CGFloat) {
        // Preference removal reports zero as the compact view replaces the card;
        // retain the last expanded measurement until the next expansion reports.
        guard height > ScreenGeometry.compactPanelHeight else { return }
        expandedCardHeight = height
    }

    private func updateCompactMeetingActivity(_ isActive: Bool) {
        let effectiveActivity = state.presentationPreferences.showsMeetingStatus && isActive
        guard compactMeetingIsActive != effectiveActivity else { return }
        compactMeetingIsActive = effectiveActivity
        guard !state.isExpanded else { return }
        resize(expanded: false)
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
        if !expanded, panel.isKeyWindow {
            panel.resignKey()
            PresentationDiagnostics.debug("notch keyboard focus released")
        }
        let notchBounds = ScreenGeometry.notchBounds(on: screen)
        if !expanded {
            compactMeetingIsActive = state.presentationPreferences.showsMeetingStatus
                && UpcomingEventEngine.status(
                    now: Date(),
                    events: state.calendar.todayEvents
                ).isActive
        }
        layoutMetrics.expandedContentTopInset = ScreenGeometry.expandedContentTopInset(on: screen)
        layoutMetrics.compactNotchWidth = notchBounds?.width
        layoutMetrics.compactNotchDepth = notchBounds?.depth
        layoutMetrics.showsCompactMeetingStatus = state.presentationPreferences.showsMeetingStatus
        layoutMetrics.showsClickTarget = effectiveInteractionMode == .clickOnly
        let newFrame = ScreenGeometry.panelFrame(
            on: screen,
            size: expanded
                ? expandedSize
                : Self.compactSize(
                    on: screen,
                    showsMeetingStatus: compactMeetingIsActive,
                    showsClickTarget: effectiveInteractionMode == .clickOnly
                ),
            expanded: expanded
        )
        if expanded {
            panel.ignoresMouseEvents = false
        }
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
                            self.applyCompactMousePassthrough()
                        }
                    }
                }
            }
        } else {
            panel.setFrame(newFrame, display: true)
            if !expanded {
                state.isPresentationExpanded = false
                applyCompactMousePassthrough()
            }
        }
    }

    private static func compactSize(
        on screen: NSScreen,
        showsMeetingStatus: Bool,
        showsClickTarget: Bool
    ) -> NSSize {
        let notchBounds = ScreenGeometry.notchBounds(on: screen)
        return NSSize(
            width: min(
                ScreenGeometry.compactPanelWidth(
                    notchWidth: notchBounds?.width,
                    showsMeetingStatus: showsMeetingStatus,
                    showsClickTarget: showsClickTarget
                ),
                screen.frame.width
            ),
            height: ScreenGeometry.compactPanelHeight(notchDepth: notchBounds?.depth)
        )
    }

    private func applyCompactMousePassthrough() {
        switch effectiveInteractionMode {
        case .intentionalHover:
            // Never cover menu-bar controls if global monitoring is unavailable.
            panel.ignoresMouseEvents = true
        case .clickOnly:
            panel.ignoresMouseEvents = false
        }
    }

    private func applyPresentationPreferences(animated: Bool = true) {
        cancelPendingHover()
        collapseTask?.cancel()
        collapseTask = nil
        compactMeetingIsActive = state.presentationPreferences.showsMeetingStatus && UpcomingEventEngine.status(
            now: Date(),
            events: state.calendar.todayEvents
        ).isActive
        layoutMetrics.showsCompactMeetingStatus = state.presentationPreferences.showsMeetingStatus
        layoutMetrics.showsClickTarget = effectiveInteractionMode == .clickOnly
        if !state.isExpanded {
            resize(expanded: false, animated: animated)
            applyCompactMousePassthrough()
        }
        PresentationDiagnostics.event(
            "notch preferences mode=\(state.presentationPreferences.notchInteractionMode.rawValue) meeting-status=\(state.presentationPreferences.showsMeetingStatus)"
        )
    }

    private var effectiveInteractionMode: NotchInteractionMode {
        NotchInteractionPolicy.effectiveMode(
            requestedMode: state.presentationPreferences.notchInteractionMode,
            isGlobalMouseMonitorAvailable: globalMouseMonitor != nil
        )
    }

    private func cancelPendingHover() {
        expandTask?.cancel()
        expandTask = nil
        hoverAnchor = nil
        pointerWasInsideTrigger = false
    }

    private func pointerDistance(from first: NSPoint, to second: NSPoint) -> CGFloat {
        let dx = first.x - second.x
        let dy = first.y - second.y
        return (dx * dx + dy * dy).squareRoot()
    }

    private func trace(_ message: String) {
        PresentationDiagnostics.debug(message)
    }
}
