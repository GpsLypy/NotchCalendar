import SwiftUI

/// Slate surfaces, silver type, and blue controls form the personal desk.
/// Coral is reserved for calendar activity; mint marks available time.
enum WorkspacePalette {
    static let canvas = Color(red: 0.063, green: 0.090, blue: 0.133)      // #101722
    static let sidebar = Color(red: 0.082, green: 0.122, blue: 0.176)     // #151F2D
    static let elevated = Color(red: 0.110, green: 0.157, blue: 0.220)    // #1C2838
    static let hover = Color.white.opacity(0.055)
    static let stroke = Color.white.opacity(0.085)
    static let primaryText = Color(red: 0.929, green: 0.949, blue: 0.969) // #EDF2F7
    static let secondaryText = Color(red: 0.624, green: 0.686, blue: 0.761) // #9FAFC2
    static let accent = Color(red: 0.565, green: 0.722, blue: 0.973)      // #90B8F8
    static let success = Color(red: 0.510, green: 0.784, blue: 0.690)     // #82C8B0
}

enum WorkspaceDestination: String, CaseIterable, Identifiable {
    case today
    case calendar
    case focus
    case scratchpad
    case radar
    case markets
    case discussion
    case briefing

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .today: "Today"
        case .calendar: "Calendar"
        case .focus: "Focus"
        case .scratchpad: "Scratchpad"
        case .radar: "Radar"
        case .markets: "Markets"
        case .discussion: "Discussion Room"
        case .briefing: "Briefing"
        }
    }

    var systemImage: String {
        switch self {
        case .today: "sparkles.rectangle.stack"
        case .calendar: "calendar"
        case .focus: "timer"
        case .scratchpad: "note.text"
        case .radar: "antenna.radiowaves.left.and.right"
        case .markets: "chart.xyaxis.line"
        case .discussion: "bubble.left.and.bubble.right"
        case .briefing: "newspaper"
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
