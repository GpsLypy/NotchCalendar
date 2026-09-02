import AppKit

enum ScreenGeometry {
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

    /// Keeps controls below the physical camera housing. The extra 12pt gives
    /// buttons a reliable click target instead of placing them under the notch.
    static func expandedContentTopInset(on screen: NSScreen) -> CGFloat {
        guard let notch = notchBounds(on: screen) else { return 24 }
        let housingDepth = screen.frame.maxY - notch.bottomY
        return max(24, housingDepth + 12)
    }
}
