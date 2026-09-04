import SwiftUI

/// The desktop workspace keeps the notch calendar's coral accent while using
/// quieter graphite surfaces for the expandable, multi-tool shell.
enum WorkspacePalette {
    static let canvas = Color(red: 0.027, green: 0.027, blue: 0.033)       // #070708
    static let sidebar = Color(red: 0.052, green: 0.052, blue: 0.061)      // #0D0D10
    static let elevated = Color(red: 0.074, green: 0.074, blue: 0.086)     // #131316
    static let hover = Color.white.opacity(0.055)
    static let stroke = Color.white.opacity(0.085)
    static let primaryText = Color.white.opacity(0.94)
    static let secondaryText = Color.white.opacity(0.55)
    static let accent = AlcovePalette.accent
    static let success = Color(red: 0.40, green: 0.84, blue: 0.58)         // #66D694
}

enum WorkspaceDestination: String, CaseIterable, Identifiable {
    case today
    case calendar
    case focus
    case scratchpad
    case radar

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .today: "Today"
        case .calendar: "Calendar"
        case .focus: "Focus"
        case .scratchpad: "Scratchpad"
        case .radar: "Radar"
        }
    }

    var systemImage: String {
        switch self {
        case .today: "sparkles.rectangle.stack"
        case .calendar: "calendar"
        case .focus: "timer"
        case .scratchpad: "note.text"
        case .radar: "antenna.radiowaves.left.and.right"
        }
    }
}

struct WorkspaceCard<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .background(WorkspacePalette.elevated, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(WorkspacePalette.stroke, lineWidth: 1)
            }
            .accessibilityElement(children: .contain)
    }
}
