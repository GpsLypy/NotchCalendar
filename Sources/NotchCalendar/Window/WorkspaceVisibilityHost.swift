import SwiftUI

/// Detach the hidden window's reactive page tree. Keeping an invisible hosting
/// controller alive must not rebuild calendar layouts on every focus tick.
struct WorkspaceVisibilityHost<Content: View>: View {
    @ObservedObject var presentation: MainCalendarPresentation
    @ViewBuilder let content: () -> Content

    var body: some View {
        if presentation.isActive { content() }
        else { Color.clear }
    }
}
