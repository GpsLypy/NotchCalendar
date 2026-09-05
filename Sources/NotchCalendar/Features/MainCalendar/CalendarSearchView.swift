import SwiftUI

struct CalendarSearchView: View {
    @ObservedObject var calendar: CalendarManager
    var secondaryTimeZone: String
    var onSelectEvent: ((CalendarEvent) -> Void)? = nil
    var onCreate: () -> Void
    @Environment(\.appLanguage) private var language
    @Environment(\.openSettings) private var openSettings
    @State private var query = ""
    @State private var firstDay = CalendarSearchEngine.defaultRange().start
    @State private var lastDay = CalendarSearchEngine.defaultRange().end.addingTimeInterval(-1)
    @State private var loadedEvents: [CalendarEvent] = []
    @State private var isLoading = true
    @State private var rangeError = false
    @FocusState private var searchFocused: Bool

    var body: some View {
        let result = CalendarSearchEngine.search(loadedEvents, query: query)
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass").foregroundStyle(WorkspacePalette.secondaryText)
                TextField(t("Search title, location or calendar"), text: $query)
                    .textFieldStyle(.plain)
                    .focused($searchFocused)
                    .font(.system(size: 15))
                if !query.isEmpty {
                    Button { query = "" } label: { Image(systemName: "xmark.circle.fill") }
                        .buttonStyle(.plain)
                        .accessibilityLabel(t("Clear search"))
                }
            }
            .padding(14)
            .background(WorkspacePalette.elevated, in: RoundedRectangle(cornerRadius: 12))
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 16) { rangeFields }
                VStack(alignment: .leading, spacing: 10) { rangeFields }
            }
            if let message = calendar.availabilityMessage {
                emptyState(message, icon: "calendar.badge.exclamationmark") {
                    if calendar.isCalendarAccessGranted {
                        Button(t("Calendar Sources")) { openSettings() }
                    } else {
                        Button(t("Open System Settings")) { calendar.openPrivacySettings() }
                    }
                }
            } else if rangeError {
                emptyState("Choose a date range of 1 to 366 days.", icon: "calendar.badge.exclamationmark") {
                    Button(t("Reset date range")) {
                        let range = CalendarSearchEngine.defaultRange()
                        firstDay = range.start
                        lastDay = range.end.addingTimeInterval(-1)
                    }
                }
            } else if isLoading {
                ProgressView().frame(maxWidth: .infinity, minHeight: 160)
            } else if result.events.isEmpty {
                emptyState(query.isEmpty ? "No events in this date range." : "No matching events. Try fewer words or a wider date range.", icon: "magnifyingglass") {
                    Button(t("New event"), action: onCreate)
                        .disabled(calendar.writableCalendars.isEmpty)
                }
            } else {
                HStack {
                    Text(t("%@ events", "\(result.totalCount)"))
                    Spacer()
                    if result.isTruncated { Text(t("Showing the first 200. Narrow the date range or search.")) }
                }
                .font(.system(size: 11))
                .foregroundStyle(WorkspacePalette.secondaryText)
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(result.events, id: \.occurrenceStableID) { event in
                            CalendarEventRow(event: event, secondaryTimeZone: secondaryTimeZone,
                                             showsDate: true, onSelectEvent: onSelectEvent)
                        }
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 30)
        .padding(.bottom, 24)
        .task(id: QueryScope(first: firstDay, last: lastDay, revision: calendar.contentRevision)) {
            isLoading = true
            await Task.yield()
            guard !Task.isCancelled else { return }
            guard let interval = CalendarSearchEngine.interval(from: firstDay, through: lastDay) else {
                rangeError = true
                loadedEvents = []
                isLoading = false
                return
            }
            rangeError = false
            loadedEvents = calendar.events(from: interval.start, to: interval.end)
            isLoading = false
        }
        .onAppear { searchFocused = true }
    }

    @ViewBuilder private var rangeFields: some View {
        DatePicker(t("From"), selection: $firstDay, displayedComponents: .date)
            .datePickerStyle(.field)
        DatePicker(t("Through"), selection: $lastDay, displayedComponents: .date)
            .datePickerStyle(.field)
        Button { calendar.refresh() } label: { Image(systemName: "arrow.clockwise") }
            .buttonStyle(.borderless)
            .help(t("Refresh calendars"))
            .accessibilityLabel(t("Refresh calendars"))
    }

    private func emptyState<Actions: View>(_ message: String, icon: String, @ViewBuilder actions: () -> Actions) -> some View {
        VStack(spacing: 14) {
            Image(systemName: icon).font(.system(size: 26)).foregroundStyle(WorkspacePalette.accent)
            Text(t(message)).font(.system(size: 13)).multilineTextAlignment(.center)
                .foregroundStyle(WorkspacePalette.secondaryText)
            actions().buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, minHeight: 190)
    }

    private struct QueryScope: Hashable { let first: Date; let last: Date; let revision: Int }
    private func t(_ key: String, _ arguments: CVarArg...) -> String { L10n.string(key, language: language, arguments: arguments) }
}
