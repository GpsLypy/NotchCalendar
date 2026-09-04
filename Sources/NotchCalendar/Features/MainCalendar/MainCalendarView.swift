import SwiftUI

/// The persistent desktop counterpart to the glanceable notch surface.
/// It deliberately owns its date selection while observing the same calendar
/// manager, so browsing here never changes what the next notch glance shows.
struct MainCalendarView: View {
    @ObservedObject var calendar: CalendarManager
    @ObservedObject var presentation: MainCalendarPresentation
    @Binding var selectedDate: Date

    var body: some View {
        CalendarDashboardView(
            calendar: calendar,
            selectedDate: $selectedDate,
            contentTopInset: 52,
            surface: .window,
            isActive: presentation.isActive,
            onClose: nil
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}
