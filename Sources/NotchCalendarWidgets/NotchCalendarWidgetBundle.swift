import SwiftUI
import WidgetKit

@main
struct NotchCalendarWidgetBundle: WidgetBundle {
    var body: some Widget {
        MonthCalendarWidget()
        FocusTimerWidget()
        TodayAgendaWidget()
    }
}
