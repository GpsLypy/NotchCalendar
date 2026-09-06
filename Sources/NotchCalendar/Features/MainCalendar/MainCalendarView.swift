import SwiftUI

/// Browsing stays separate from the notch's date. Month and search share the
/// same source selection, exact-duplicate policy and event instance identity.
struct MainCalendarView: View {
    @ObservedObject var calendar: CalendarManager
    @ObservedObject var presentation: MainCalendarPresentation
    @Binding var selectedDate: Date
    var onSelectEvent: ((CalendarEvent) -> Void)? = nil
    @Environment(\.appLanguage) private var language
    @Environment(\.openSettings) private var openSettings
    @AppStorage(CalendarTimeZoneTools.secondaryStorageKey) private var secondaryTimeZone = ""
    @State private var isSearching = false
    @State private var showsComposer = false
    @State private var showsTimeZones = false
    @ObservedObject private var creationDraft: CalendarDraftSession
    @State private var savedMessage: String?
    @State private var dayEvents: [CalendarEvent] = []
    @State private var monthEvents: [CalendarEvent] = []

    init(calendar: CalendarManager, presentation: MainCalendarPresentation,
         selectedDate: Binding<Date>, onSelectEvent: ((CalendarEvent) -> Void)? = nil) {
        self.calendar = calendar
        self.presentation = presentation
        self._selectedDate = selectedDate
        self.onSelectEvent = onSelectEvent
        self.creationDraft = calendar.creationDraft
    }

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            if let savedMessage {
                HStack {
                    Label(savedMessage, systemImage: "checkmark.circle.fill")
                    Spacer()
                    Button { self.savedMessage = nil } label: { Image(systemName: "xmark") }
                        .buttonStyle(.plain)
                        .accessibilityLabel(t("Dismiss"))
                }
                .font(.system(size: 12))
                .foregroundStyle(WorkspacePalette.success)
                .padding(.horizontal, 30)
                .padding(.bottom, 14)
            }
            if isSearching {
                CalendarSearchView(calendar: calendar, secondaryTimeZone: secondaryTimeZone,
                                   onSelectEvent: onSelectEvent, onCreate: beginDraft)
            } else {
                GeometryReader { geometry in
                    if geometry.size.width >= 720 {
                        HStack(alignment: .top, spacing: 24) {
                            ScrollView {
                                MonthCalendarView(selectedDate: $selectedDate, events: monthEvents, workspaceStyle: true,
                                                  workspaceDayHeight: min(72, max(42, (geometry.size.height - 200) / 6)))
                            }
                            .frame(maxWidth: .infinity, alignment: .top)
                            Rectangle().fill(WorkspacePalette.stroke).frame(width: 1)
                            ScrollView { selectedDayAgenda }
                                .frame(width: 240)
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .background(WorkspacePalette.elevated.opacity(0.40), in: RoundedRectangle(cornerRadius: 18))
                        .overlay { RoundedRectangle(cornerRadius: 18).stroke(WorkspacePalette.stroke, lineWidth: 1) }
                        .padding(.horizontal, 28)
                        .padding(.bottom, 24)
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 24) {
                                MonthCalendarView(selectedDate: $selectedDate, events: monthEvents, workspaceStyle: true, workspaceDayHeight: 42)
                                Divider().overlay(WorkspacePalette.stroke)
                                selectedDayAgenda
                            }
                            .padding(24)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            .background(WorkspacePalette.elevated.opacity(0.40), in: RoundedRectangle(cornerRadius: 18))
                            .overlay { RoundedRectangle(cornerRadius: 18).stroke(WorkspacePalette.stroke, lineWidth: 1) }
                            .padding(.horizontal, 28)
                            .padding(.bottom, 24)
                        }
                    }
                }
            }
        }
        .foregroundStyle(WorkspacePalette.primaryText)
        .background(WorkspacePalette.canvas)
        .sheet(isPresented: $showsComposer) {
            CalendarEventComposer(calendar: calendar, draft: $creationDraft.draft) { event in
                selectedDate = event.startDate
                savedMessage = calendar.isCalendarSelected(event.calendarID)
                    ? t("Saved to %@", event.calendarName)
                    : t("Saved to %@ · this calendar is hidden", event.calendarName)
                creationDraft.draft = CalendarEventDraft()
            }
        }
        .task(id: DayScope(day: selectedDate, revision: calendar.contentRevision, isActive: presentation.isActive)) {
            guard presentation.isActive else { return }
            dayEvents = calendar.events(for: selectedDate)
            monthEvents = calendar.events(inMonthContaining: selectedDate)
        }
    }

    private var selectedDayAgenda: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 7) {
                Text(selectedDate.formatted(.dateTime.weekday(.wide).locale(language.locale)))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(WorkspacePalette.secondaryText)
                Text(selectedDate.formatted(.dateTime.month(.wide).day().locale(language.locale)))
                    .font(.system(size: 25, weight: .semibold, design: .rounded))
                    .accessibilityAddTraits(.isHeader)
            }
            if let message = calendar.authorizationMessage {
                agendaNotice(message, symbol: "lock", actionTitle: "Open System Settings", action: calendar.openPrivacySettings)
            } else if let message = calendar.availabilityMessage {
                agendaNotice(message, symbol: "calendar.badge.exclamationmark", actionTitle: "Calendar Sources", action: { openSettings() })
            } else if dayEvents.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Image(systemName: "calendar.badge.checkmark")
                        .font(.system(size: 24, weight: .light))
                        .foregroundStyle(WorkspacePalette.secondaryText)
                        .accessibilityHidden(true)
                    Text(t("No events on this day."))
                        .font(.system(size: 14, weight: .medium))
                    Text(t("Leave room in your day, or add something to look forward to."))
                        .font(.system(size: 12))
                        .foregroundStyle(WorkspacePalette.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                    Button(action: beginDraft) {
                        Label(t("New event"), systemImage: "plus")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .padding(.top, 4)
                }
                .padding(.top, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text(t("%@ events", "\(dayEvents.count)"))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(WorkspacePalette.secondaryText)
                ForEach(dayEvents, id: \.occurrenceStableID) { event in
                    CalendarEventRow(event: event, secondaryTimeZone: secondaryTimeZone,
                                     onSelectEvent: onSelectEvent, compactActions: true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    private func agendaNotice(_ message: String, symbol: String, actionTitle: String, action: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(t(message), systemImage: symbol)
                .font(.system(size: 12))
                .foregroundStyle(WorkspacePalette.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
            Button(t(actionTitle), action: action).buttonStyle(.bordered).controlSize(.small)
        }
    }

    private var toolbar: some View {
        HStack(spacing: 12) {
            Picker(t("Calendar view"), selection: $isSearching) {
                Text(t("Month")).tag(false)
                Text(t("Search")).tag(true)
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .frame(width: 186)
            Spacer(minLength: 8)
            Button { showsTimeZones.toggle() } label: {
                Label(secondaryTimeZone.isEmpty ? t("Second time zone")
                      : String(secondaryTimeZone.split(separator: "/").last ?? "").replacingOccurrences(of: "_", with: " "), systemImage: "globe")
                    .font(.system(size: 11, weight: .medium))
                    .lineLimit(1)
            }
            .buttonStyle(.bordered)
            .popover(isPresented: $showsTimeZones) {
                CalendarTimeZonePicker(selection: $secondaryTimeZone, allowsNone: true)
            }
            Button(action: beginDraft) {
                Label(t("New event"), systemImage: "plus")
                    .font(.system(size: 12, weight: .semibold))
            }
            .buttonStyle(.borderedProminent)
            .tint(WorkspacePalette.accent)
            .keyboardShortcut("n", modifiers: .command)
            Button { isSearching = true } label: { EmptyView() }
                .keyboardShortcut("f", modifiers: .command)
                .hidden().frame(width: 0, height: 0)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 30)
        .padding(.top, 42)
        .padding(.bottom, 24)
    }

    private func beginDraft() {
        if creationDraft.draft.title.isEmpty && creationDraft.draft.calendarID.isEmpty {
            var start = selectedDate
            if Calendar.current.isDateInToday(selectedDate) {
                start = Date().addingTimeInterval(15 * 60)
            } else {
                start = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: selectedDate) ?? selectedDate
            }
            let preferred = calendar.writableCalendars.first(where: { calendar.isCalendarSelected($0.id) })
                ?? calendar.writableCalendars.first
            creationDraft.draft = CalendarEventDraft(startDate: start, calendarID: preferred?.id ?? "")
        }
        showsComposer = true
    }

    private struct DayScope: Hashable { let day: Date; let revision: Int; let isActive: Bool }
    private func t(_ key: String, _ arguments: CVarArg...) -> String { L10n.string(key, language: language, arguments: arguments) }
}
