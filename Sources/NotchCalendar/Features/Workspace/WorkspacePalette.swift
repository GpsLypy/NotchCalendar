import SwiftUI

/// Neutral graphite keeps every workspace on the same surface as the calendar.
/// Rose marks dates and intentional actions; green only conveys availability.
enum WorkspacePalette {
    static let canvas = Color(red: 0.078, green: 0.078, blue: 0.086)     // #141416
    static let sidebar = Color(red: 0.102, green: 0.102, blue: 0.110)    // #1A1A1C
    static let elevated = Color(red: 0.133, green: 0.133, blue: 0.145)   // #222225
    static let hover = Color.white.opacity(0.055)
    static let stroke = Color.white.opacity(0.085)
    static let primaryText = Color(red: 0.957, green: 0.953, blue: 0.957) // #F4F3F4
    static let secondaryText = Color(red: 0.667, green: 0.659, blue: 0.686) // #AAA8AF
    static let accent = Color(red: 1.0, green: 0.310, blue: 0.435)       // #FF4F6F
    static let success = Color(red: 0.533, green: 0.733, blue: 0.635)     // #88BBA2
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
