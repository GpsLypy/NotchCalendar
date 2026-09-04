import SwiftUI

@MainActor
final class NotchLayoutMetrics: ObservableObject {
    @Published var expandedContentTopInset: CGFloat

    init(expandedContentTopInset: CGFloat) {
        self.expandedContentTopInset = expandedContentTopInset
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
    let onExpandedCardHeightChange: (CGFloat) -> Void
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
                    state.isExpanded = true
                } label: {
                    CompactNotchView(events: state.calendar.todayEvents)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
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
