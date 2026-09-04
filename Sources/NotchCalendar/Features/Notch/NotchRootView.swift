import SwiftUI

@MainActor
final class NotchLayoutMetrics: ObservableObject {
    @Published var expandedContentTopInset: CGFloat
    @Published var compactNotchWidth: CGFloat?
    @Published var compactNotchDepth: CGFloat?
    @Published var showsCompactMeetingStatus: Bool
    @Published var showsClickTarget: Bool

    init(
        expandedContentTopInset: CGFloat,
        compactNotchWidth: CGFloat?,
        compactNotchDepth: CGFloat?,
        showsCompactMeetingStatus: Bool,
        showsClickTarget: Bool
    ) {
        self.expandedContentTopInset = expandedContentTopInset
        self.compactNotchWidth = compactNotchWidth
        self.compactNotchDepth = compactNotchDepth
        self.showsCompactMeetingStatus = showsCompactMeetingStatus
        self.showsClickTarget = showsClickTarget
    }
}

private struct ExpandedCardHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct NotchRootView: View {
    @ObservedObject var state: AppState
    @ObservedObject var layoutMetrics: NotchLayoutMetrics
    let onExplicitExpansion: () -> Void
    let onExpandedCardHeightChange: (CGFloat) -> Void
    let onCompactMeetingActivityChange: (Bool) -> Void
    @Environment(\.appLanguage) private var appLanguage

    var body: some View {
        Group {
            if state.isPresentationExpanded {
                ExpandedCalendarView(
                    state: state,
                    contentTopInset: layoutMetrics.expandedContentTopInset
                )
                    // The panel reserves room for calendars with an event card,
                    // but the drawn card is shorter on quiet days. Report the
                    // actual visual height so transparent reserved space does not
                    // keep the hover session alive.
                    .background(
                        GeometryReader { proxy in
                            Color.clear.preference(key: ExpandedCardHeightKey.self, value: proxy.size.height)
                        }
                    )
            } else {
                Button {
                    onExplicitExpansion()
                } label: {
                    CompactNotchView(
                        events: state.calendar.todayEvents,
                        notchWidth: layoutMetrics.compactNotchWidth,
                        notchDepth: layoutMetrics.compactNotchDepth,
                        showsMeetingStatus: layoutMetrics.showsCompactMeetingStatus,
                        showsClickTarget: layoutMetrics.showsClickTarget,
                        onMeetingActivityChange: onCompactMeetingActivityChange
                    )
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(
                    L10n.string("Open Notch Calendar", language: appLanguage)
                )
                .accessibilityHint(
                    L10n.string(
                        "Shows today's agenda and month calendar",
                        language: appLanguage
                    )
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .animation(.easeInOut(duration: 0.24), value: state.isPresentationExpanded)
        .onPreferenceChange(ExpandedCardHeightKey.self, perform: onExpandedCardHeightChange)
    }
}
