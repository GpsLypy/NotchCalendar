import SwiftUI

struct CalendarEventComposer: View {
    @ObservedObject var calendar: CalendarManager
    @Binding var draft: CalendarEventDraft
    var onSaved: (CalendarEvent) -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appLanguage) private var language
    @State private var errorMessage: String?
    @State private var saving = false
    @State private var showsTimeZones = false
    @FocusState private var titleFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(t("New event")).font(.system(size: 24, weight: .bold, design: .rounded))
                    Text(t("Save directly to your system calendar."))
                        .font(.system(size: 12))
                        .foregroundStyle(WorkspacePalette.secondaryText)
                }
                Spacer()
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 27))
                    .foregroundStyle(WorkspacePalette.accent)
            }
            .padding(24)
            Divider().overlay(WorkspacePalette.stroke)
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    field(t("Title")) {
                        TextField(t("What are you planning?"), text: $draft.title)
                            .textFieldStyle(.roundedBorder)
                            .focused($titleFocused)
                    }
                    field(t("Calendar")) {
                        if calendar.writableCalendars.isEmpty {
                            Text(t(calendar.isCalendarAccessGranted
                                ? "Choose a writable calendar. Read-only calendars cannot save events."
                                : "Allow Calendar access in System Settings to create events."))
                                .font(.system(size: 12))
                                .foregroundStyle(WorkspacePalette.secondaryText)
                            if !calendar.isCalendarAccessGranted {
                                Button(t("Open System Settings")) { calendar.openPrivacySettings() }
                            }
                        } else {
                            Picker(t("Calendar"), selection: $draft.calendarID) {
                                Text(t("Choose calendar")).tag("")
                                ForEach(calendar.writableCalendars) { source in
                                    Text("\(source.title) · \(source.sourceTitle)").tag(source.id)
                                }
                            }
                            .labelsHidden()
                            if !draft.calendarID.isEmpty && !calendar.isCalendarSelected(draft.calendarID) {
                                Text(t("This calendar is hidden. The saved event will appear in the system Calendar app."))
                                    .font(.system(size: 11))
                                    .foregroundStyle(WorkspacePalette.accent)
                            }
                        }
                    }
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle(t("All day"), isOn: $draft.isAllDay)
                        DatePicker(t("Starts"), selection: startBinding,
                                   displayedComponents: draft.isAllDay ? [.date] : [.date, .hourAndMinute])
                        DatePicker(t(draft.isAllDay ? "Last day (inclusive)" : "Ends"), selection: $draft.endDate,
                                   displayedComponents: draft.isAllDay ? [.date] : [.date, .hourAndMinute])
                        if !draft.isAllDay {
                            HStack(spacing: 6) {
                                Text(t("Duration")).font(.system(size: 11)).foregroundStyle(WorkspacePalette.secondaryText)
                                ForEach([15, 30, 45, 60, 90], id: \.self) { minutes in
                                    Button(t("%@ min", "\(minutes)")) {
                                        draft.endDate = draft.startDate.addingTimeInterval(TimeInterval(minutes * 60))
                                    }
                                    .buttonStyle(.bordered)
                                    .controlSize(.small)
                                }
                            }
                        }
                        Button { showsTimeZones.toggle() } label: {
                            Label(CalendarTimeZoneTools.label(draft.timeZoneIdentifier, at: draft.startDate, locale: language.locale), systemImage: "globe")
                                .font(.system(size: 12))
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(WorkspacePalette.accent)
                        .popover(isPresented: $showsTimeZones) {
                            CalendarTimeZonePicker(selection: $draft.timeZoneIdentifier)
                        }
                        .help(t("Time zone for the dates you enter"))
                    }
                    .environment(\.timeZone, draft.timeZone ?? .current)
                    field(t("Repeat")) {
                        Picker(t("Repeat"), selection: $draft.repeatRule) {
                            ForEach(CalendarRepeatRule.allCases) { rule in Text(t(rule.titleKey)).tag(rule) }
                        }
                        .labelsHidden()
                        if draft.repeatRule != .never {
                            DatePicker(t("Repeat through"), selection: $draft.repeatThrough, displayedComponents: .date)
                                .environment(\.timeZone, draft.timeZone ?? .current)
                            if draft.repeatRule == .monthly {
                                Text(t("Monthly events on the 29th–31st skip months without that date."))
                                    .font(.system(size: 11)).foregroundStyle(WorkspacePalette.secondaryText)
                            }
                        }
                    }
                    field(t("Location (optional)")) {
                        TextField(t("Room or address"), text: $draft.location).textFieldStyle(.roundedBorder)
                    }
                    field(t("Meeting link (optional)")) {
                        TextField("https://", text: $draft.link).textFieldStyle(.roundedBorder)
                    }
                    if let errorMessage {
                        Label(t(errorMessage), systemImage: "exclamationmark.circle")
                            .font(.system(size: 12))
                            .foregroundStyle(WorkspacePalette.accent)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(24)
            }
            Divider().overlay(WorkspacePalette.stroke)
            HStack {
                Text(t("Closing keeps your draft until you save or restart the app."))
                    .font(.system(size: 10))
                    .foregroundStyle(WorkspacePalette.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Button(t("Cancel")) { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button(t(saving ? "Saving…" : "Save event"), action: save)
                    .buttonStyle(.borderedProminent)
                    .tint(WorkspacePalette.accent)
                    .keyboardShortcut(.defaultAction)
                    .disabled(saving || calendar.writableCalendars.isEmpty || !calendar.isCalendarAccessGranted)
            }
            .padding(20)
        }
        .frame(width: 580, height: 690)
        .foregroundStyle(WorkspacePalette.primaryText)
        .background(WorkspacePalette.canvas)
        .preferredColorScheme(.dark)
        .onAppear { titleFocused = true }
    }

    private var startBinding: Binding<Date> {
        Binding(get: { draft.startDate }, set: { newStart in
            if draft.isAllDay {
                var dateCalendar = Calendar(identifier: .gregorian)
                dateCalendar.timeZone = draft.timeZone ?? .current
                let days = dateCalendar.dateComponents([.day], from: dateCalendar.startOfDay(for: draft.startDate),
                                                       to: dateCalendar.startOfDay(for: draft.endDate)).day ?? 0
                draft.endDate = dateCalendar.date(byAdding: .day, value: max(0, days), to: newStart) ?? newStart
            } else {
                let duration = max(60, draft.endDate.timeIntervalSince(draft.startDate))
                draft.endDate = newStart.addingTimeInterval(duration)
            }
            draft.startDate = newStart
        })
    }

    private func field<Content: View>(_ label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).font(.system(size: 11, weight: .semibold)).foregroundStyle(WorkspacePalette.secondaryText)
            content()
        }
    }

    private func save() {
        guard !saving else { return }
        saving = true
        defer { saving = false }
        do {
            let event = try calendar.createEvent(draft)
            errorMessage = nil
            onSaved(event)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func t(_ key: String, _ arguments: CVarArg...) -> String { L10n.string(key, language: language, arguments: arguments) }
}
