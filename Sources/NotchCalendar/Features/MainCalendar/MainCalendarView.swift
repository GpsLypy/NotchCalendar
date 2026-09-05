import SwiftUI

/// Browsing stays separate from the notch's date. Month and search share the
/// same source selection, exact-duplicate policy and event instance identity.
struct MainCalendarView: View {
    @ObservedObject var calendar: CalendarManager
    @ObservedObject var presentation: MainCalendarPresentation
    @Binding var selectedDate: Date
    var onSelectEvent: ((CalendarEvent) -> Void)? = nil
    @Environment(\.appLanguage) private var language
    @AppStorage(CalendarTimeZoneTools.secondaryStorageKey) private var secondaryTimeZone = ""
    @State private var isSearching = false
    @State private var showsComposer = false
    @State private var showsTimeZones = false
    @ObservedObject private var creationDraft: CalendarDraftSession
    @State private var savedMessage: String?
    @State private var dayEvents: [CalendarEvent] = []

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
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        CalendarDashboardView(
                            calendar: calendar, selectedDate: $selectedDate, contentTopInset: 12,
                            surface: .window, isActive: presentation.isActive, onClose: nil
                        )
                        if !dayEvents.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text(t("Full day agenda")).font(.system(size: 14, weight: .semibold))
                                    Spacer()
                                    Text(t("%@ events", "\(dayEvents.count)"))
                                        .font(.system(size: 11)).foregroundStyle(WorkspacePalette.secondaryText)
                                }
                                ForEach(dayEvents, id: \.occurrenceStableID) { event in
                                    CalendarEventRow(event: event, secondaryTimeZone: secondaryTimeZone,
                                                     onSelectEvent: onSelectEvent)
                                }
                            }
                            .padding(.horizontal, 30)
                            .padding(.bottom, 28)
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
        }
    }

    private var toolbar: some View {
        HStack(spacing: 12) {
            Picker(t("Calendar view"), selection: $isSearching) {
                Text(t("Month")).tag(false)
                Text(t("Search")).tag(true)
            }
            .pickerStyle(.segmented)
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
        .padding(.top, 48)
        .padding(.bottom, 22)
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
