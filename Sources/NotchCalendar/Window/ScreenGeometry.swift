import AppKit

enum ScreenGeometry {
    static let compactPanelHeight: CGFloat = 30
    static let compactPanelCornerRadius: CGFloat = 9
    private static let defaultExpandedTopInset: CGFloat = 24
    private static let cameraHousingClearance: CGFloat = 12

    struct NotchBounds {
        let centerX: CGFloat
        let width: CGFloat
        /// Screen-space Y coordinate of the bottom edge of the camera housing.
        let bottomY: CGFloat
    }

    static func notchBounds(on screen: NSScreen) -> NotchBounds? {
        guard let left = screen.auxiliaryTopLeftArea,
              let right = screen.auxiliaryTopRightArea,
              right.minX > left.maxX else { return nil }

        // The auxiliary areas end at the menu bar's lower edge.  A camera housing
        // can extend below it, so use the lower of that edge and the safe-area edge.
        let auxiliaryBottom = min(left.minY, right.minY)
        let safeAreaBottom = screen.frame.maxY - screen.safeAreaInsets.top

        return NotchBounds(
            centerX: (left.maxX + right.minX) / 2,
            width: right.minX - left.maxX,
            bottomY: min(auxiliaryBottom, safeAreaBottom)
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

    static func hoverTriggerFrame(on screen: NSScreen, compactSize: NSSize) -> NSRect {
        let compactFrame = panelFrame(on: screen, size: compactSize, expanded: false)
        // Alcove-style forgiving hit target: the visual stays exact, while users
        // can approach from either shoulder of the physical notch or from below.
        return compactFrame.insetBy(dx: -18, dy: -10).intersection(screen.frame)
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
