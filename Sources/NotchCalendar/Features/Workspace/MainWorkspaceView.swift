import SwiftUI

/// Desktop-only shell. The notch panel deliberately bypasses this view and
/// continues to present the compact calendar surface on its own.
struct MainWorkspaceView: View {
    @ObservedObject var calendar: CalendarManager
    @ObservedObject var focusTimer: FocusTimerModel
    @ObservedObject var updateChecker: UpdateChecker
    @ObservedObject var presentation: MainCalendarPresentation

    @State private var selectedCalendarDate = Date()
    @State private var calendarFollowsToday = true
    @State private var now = Date()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: 0) {
            WorkspaceSidebar(
                selection: $presentation.selectedDestination,
                calendar: calendar,
                focusTimer: focusTimer,
                updateChecker: updateChecker
            )
            .frame(width: 212)

            Rectangle()
                .fill(WorkspacePalette.stroke)
                .frame(width: 1)

            pageContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .id(presentation.selectedDestination)
                .transition(.opacity)
        }
        .background(WorkspacePalette.canvas)
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
        .animation(
            reduceMotion ? nil : .easeOut(duration: 0.16),
            value: presentation.selectedDestination
        )
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { date in
            guard presentation.isActive else { return }
            synchronizeWorkspace(to: date)
        }
        .onChange(of: presentation.isActive) { _, isActive in
            guard isActive else { return }
            synchronizeWorkspace(to: Date())
        }
    }

    @ViewBuilder private var pageContent: some View {
        switch presentation.selectedDestination {
        case .today:
            TodayWorkspaceView(
                calendar: calendar,
                focusTimer: focusTimer,
                isActive: presentation.isActive,
                navigate: navigate
            )
        case .calendar:
            MainCalendarView(
                calendar: calendar,
                presentation: presentation,
                selectedDate: calendarDateBinding
            )
        case .focus:
            FocusWorkspaceView(timer: focusTimer, calendar: calendar, now: now)
        case .scratchpad:
            ScratchpadWorkspaceView()
        }
    }

    private func navigate(to destination: WorkspaceDestination) {
        presentation.selectedDestination = destination
    }

    private func synchronizeWorkspace(to date: Date) {
        if !Calendar.current.isDate(now, inSameDayAs: date), calendarFollowsToday {
            selectedCalendarDate = date
        }
        now = date
        focusTimer.synchronize(now: date)
    }

    private var calendarDateBinding: Binding<Date> {
        Binding(
            get: { selectedCalendarDate },
            set: { date in
                selectedCalendarDate = date
                calendarFollowsToday = Calendar.current.isDateInToday(date)
            }
        )
    }
}
