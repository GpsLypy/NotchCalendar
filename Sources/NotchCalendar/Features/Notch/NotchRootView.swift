import SwiftUI

private struct ExpandedCardHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct NotchRootView: View {
    @ObservedObject var state: AppState
    let expandedContentTopInset: CGFloat
    let onExpandedCardHeightChange: (CGFloat) -> Void

    var body: some View {
        Group {
            if state.isPresentationExpanded {
                ExpandedCalendarView(state: state, contentTopInset: expandedContentTopInset)
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
                CompactNotchView(events: state.calendar.todayEvents)
                    .contentShape(Rectangle())
                    .onTapGesture { state.isExpanded = true }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .animation(.easeInOut(duration: 0.24), value: state.isPresentationExpanded)
        .onPreferenceChange(ExpandedCardHeightKey.self, perform: onExpandedCardHeightChange)
    }
}
