import AppKit

enum ScreenGeometry {
    static let compactPanelHeight: CGFloat = 30
    static let compactPanelCornerRadius: CGFloat = 9
    static let compactShoulderWidth: CGFloat = 70
    static let compactClickShoulderWidth: CGFloat = 30
    static let fallbackCompactPanelWidth: CGFloat = 226
    private static let defaultExpandedTopInset: CGFloat = 24
    private static let cameraHousingClearance: CGFloat = 12

    struct NotchBounds {
        let centerX: CGFloat
        let width: CGFloat
        /// Screen-space Y coordinate of the bottom edge of the camera housing.
        let bottomY: CGFloat
        /// Exact top-edge depth reported by AppKit for this display.
        let depth: CGFloat
    }

    static func notchBounds(on screen: NSScreen) -> NotchBounds? {
        guard let left = screen.auxiliaryTopLeftArea,
              let right = screen.auxiliaryTopRightArea,
              right.minX > left.maxX else { return nil }

        // The auxiliary areas end at the menu bar's lower edge.  A camera housing
        // can extend below it, so use the lower of that edge and the safe-area edge.
        let auxiliaryBottom = min(left.minY, right.minY)
        let safeAreaBottom = screen.frame.maxY - screen.safeAreaInsets.top

        let bottomY = min(auxiliaryBottom, safeAreaBottom)
        return NotchBounds(
            centerX: (left.maxX + right.minX) / 2,
            width: right.minX - left.maxX,
            bottomY: bottomY,
            depth: max(0, screen.frame.maxY - bottomY)
        )
    }

    static func panelFrame(on screen: NSScreen, size: NSSize, expanded: Bool) -> NSRect {
        let frame = screen.frame
        let notch = notchBounds(on: screen)
        let notchCenter = notch?.centerX ?? frame.midX
        let x = min(max(notchCenter - size.width / 2, frame.minX), frame.maxX - size.width)

        // Both states share the screen's top edge. On a MacBook Pro this makes the
        // black overlay start behind the physical housing and continue downward,
        // rather than rendering a second, detached pill below the menu bar.
        let y = frame.maxY - size.height
        return NSRect(x: x, y: y, width: size.width, height: size.height)
    }

    /// Adds a visible shoulder on each side of the physical camera housing.
    /// The center remains aligned with the hardware notch, while all meaningful
    /// compact content is kept in the unobstructed menu-bar areas beside it.
    static func compactPanelWidth(
        notchWidth: CGFloat?,
        showsMeetingStatus: Bool,
        showsClickTarget: Bool = false
    ) -> CGFloat {
        guard let notchWidth, notchWidth > 0 else {
            return fallbackCompactPanelWidth
        }
        let shoulderWidth = max(
            showsMeetingStatus ? compactShoulderWidth : 0,
            showsClickTarget ? compactClickShoulderWidth : 0
        )
        return notchWidth + shoulderWidth * 2
    }

    /// The physical housing is not the same depth on every MacBook model. Use
    /// AppKit's measured obstruction so the compact black surface ends exactly
    /// on the hardware edge instead of leaving a visible menu-bar seam.
    static func compactPanelHeight(notchDepth: CGFloat?) -> CGFloat {
        guard let notchDepth, notchDepth > 0 else { return compactPanelHeight }
        return notchDepth
    }

    static func hoverTriggerFrame(on screen: NSScreen, compactSize: NSSize) -> NSRect {
        let compactFrame = panelFrame(on: screen, size: compactSize, expanded: false)
        return hoverTriggerFrame(
            compactFrame: compactFrame,
            notchWidth: notchBounds(on: screen)?.width
        ).intersection(screen.frame)
    }

    /// Pure counterpart used by tests. A small shoulder remains discoverable,
    /// but no longer spans the nearby menu-bar controls.
    static func hoverTriggerFrame(compactFrame: NSRect, notchWidth: CGFloat?) -> NSRect {
        let availableShoulder = notchWidth.map {
            max(0, ($0 + compactShoulderWidth * 2 - compactFrame.width) / 2)
        } ?? 12
        let horizontalAllowance = min(18, availableShoulder)
        return compactFrame.insetBy(dx: -horizontalAllowance, dy: -4)
    }

    /// Keeps controls below every top-edge obstruction reported by AppKit. The
    /// visible frame accounts for an external display's menu bar even when its
    /// safe-area inset is zero, so this must not depend on notch detection alone.
    static func expandedContentTopInset(on screen: NSScreen) -> CGFloat {
        let housingDepth = notchBounds(on: screen).map {
            max(0, screen.frame.maxY - $0.bottomY)
        }
        return expandedContentTopInset(
            safeAreaTopInset: screen.safeAreaInsets.top,
            visibleFrameTopObstruction: max(0, screen.frame.maxY - screen.visibleFrame.maxY),
            cameraHousingDepth: housingDepth
        )
    }

    /// Pure counterpart used to verify notched and unobscured display layouts.
    static func expandedContentTopInset(
        safeAreaTopInset: CGFloat,
        visibleFrameTopObstruction: CGFloat,
        cameraHousingDepth: CGFloat?
    ) -> CGFloat {
        let obstructionDepth = max(
            max(max(0, safeAreaTopInset), max(0, visibleFrameTopObstruction)),
            max(0, cameraHousingDepth ?? 0)
        )
        guard obstructionDepth > 0 else { return defaultExpandedTopInset }
        return max(defaultExpandedTopInset, obstructionDepth + cameraHousingClearance)
    }
}
