import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct MeetingNotesPanel: View {
    let event: CalendarEvent
    @ObservedObject var store: MeetingNotesStore
    @State private var text = ""
    @State private var loadedKey: String?
    @Environment(\.appLanguage) private var appLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack {
                Label(t("Meeting notes"), systemImage: "note.text")
                    .font(.headline)
                Spacer()
                Text(t("Only on this Mac"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(t("Decisions, action items, and things to follow up…"))
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .padding(12)
                        .allowsHitTesting(false)
                }
                CompositionSafeTextEditor(text: $text, label: t("Meeting notes"))
                    .disabled(!store.canEditMeetingNotes)
            }
            .frame(minHeight: 130, maxHeight: 210)
            .background(.quaternary.opacity(0.35), in: RoundedRectangle(cornerRadius: 10))
            if let error = store.errorMessage {
                Label(t(error), systemImage: "exclamationmark.triangle")
                    .font(.caption)
                    .foregroundStyle(.orange)
            } else {
                Text(t("Saved automatically. Each occurrence has its own notes."))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .onAppear { load() }
        .onChange(of: event.occurrenceStableID) { _, _ in load() }
        .onChange(of: text) { _, value in
            guard loadedKey == event.occurrenceStableID,
                  value != (store.note(for: event)?.text ?? "") else { return }
            store.save(event: event, text: value)
        }
        .onReceive(store.$notes) { notes in
            let aliases = Set(event.allOccurrenceStableIDs)
            let persisted = notes.first { !aliases.isDisjoint(with: [$0.occurrenceKey] + ($0.occurrenceAliases ?? [])) }?.text ?? ""
            if text != persisted && store.errorMessage == nil { text = persisted }
        }
        .onReceive(NotificationCenter.default.publisher(for: .localBackupDidRestore)) { _ in
            store.reload()
            load()
        }
    }

    private func load() {
        loadedKey = event.occurrenceStableID
        text = store.note(for: event)?.text ?? ""
    }
    private func t(_ key: String) -> String { L10n.string(key, language: appLanguage) }
}

struct MeetingNoteEditor: View {
    let note: MeetingNote
    @ObservedObject var store: MeetingNotesStore
    @State private var text = ""
    @State private var loadedID: UUID?
    @Environment(\.appLanguage) private var appLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 5) {
                Text(note.eventTitle.isEmpty ? t("Untitled event") : note.eventTitle)
                    .font(.system(size: 19, weight: .semibold, design: .rounded))
                    .foregroundStyle(WorkspacePalette.primaryText)
                Text("\(note.eventStart.formatted(.dateTime.year().month().day().hour().minute().locale(appLanguage.locale))) · \(note.calendarName)")
                    .font(.caption)
                    .foregroundStyle(WorkspacePalette.secondaryText)
            }
            .padding(.horizontal, 12)
            .padding(.top, 15)
            Divider()
            CompositionSafeTextEditor(text: $text, label: t("Meeting notes"))
                .disabled(!store.canEditMeetingNotes)
        }
        .onAppear { load() }
        .onChange(of: note.id) { _, _ in load() }
        .onChange(of: note.text) { _, newValue in
            if text != newValue { text = newValue }
        }
        .onChange(of: text) { _, value in
            guard loadedID == note.id, value != note.text else { return }
            store.update(noteID: note.id, text: value)
        }
    }
    private func load() { loadedID = note.id; text = note.text }
    private func t(_ key: String) -> String { L10n.string(key, language: appLanguage) }
}

@MainActor
enum NotesExportPanel {
    static func save(markdown: String, name: String, language: AppLanguage) throws {
        let panel = NSSavePanel()
        panel.title = L10n.string("Export Markdown", language: language)
        panel.allowedContentTypes = [UTType(filenameExtension: "md") ?? .plainText]
        panel.nameFieldStringValue = name + ".md"
        panel.canCreateDirectories = true
        guard panel.runModal() == .OK, let url = panel.url else { return }
        try markdown.write(to: url, atomically: true, encoding: .utf8)
    }
}
