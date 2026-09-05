import AppKit
import SwiftUI

struct ScratchpadWorkspaceView: View {
    @ObservedObject var notesStore: MeetingNotesStore
    // Local state plus committed-only NSTextView binding preserves marked IME text.
    @State private var noteText: String
    @State private var mode = 0
    @State private var query = ""
    @State private var selectedNoteID: UUID?
    @State private var copied = false
    @State private var isConfirmingClear = false
    @State private var isConfirmingDelete = false
    @State private var exportError: String?
    @Environment(\.appLanguage) private var appLanguage

    init(notesStore: MeetingNotesStore = MeetingNotesStore(), initialNoteID: UUID? = nil) {
        self.notesStore = notesStore
        _noteText = State(initialValue: notesStore.scratchpadText)
        _selectedNoteID = State(initialValue: initialNoteID)
        _mode = State(initialValue: initialNoteID == nil ? 0 : 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            pageHeader
            HStack(spacing: 12) {
                Picker(t("Note collection"), selection: $mode) {
                    Text(t("Scratchpad")).tag(0)
                    Text(t("Meeting notes")).tag(1)
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 270)
                Spacer()
                if mode == 1 {
                    TextField(t("Search meeting notes"), text: $query)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 260)
                        .accessibilityLabel(t("Search meeting notes"))
                }
            }

            if mode == 0 { scratchpadEditor } else { meetingLibrary }

            HStack(alignment: .top, spacing: 10) {
                if let message = notesStore.errorMessage ?? exportError {
                    Label(t(message), systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.orange)
                        .textSelection(.enabled)
                } else {
                    Label(t("Saved automatically on this Mac"), systemImage: "checkmark.circle")
                        .foregroundStyle(WorkspacePalette.secondaryText)
                }
                Spacer()
                Text(mode == 0 ? t("%@ characters", "\(noteText.count)") : t("%@ meeting notes", "\(notesStore.notes.count)"))
                    .monospacedDigit()
                    .foregroundStyle(WorkspacePalette.secondaryText)
            }
            .font(.system(size: 10.5, weight: .medium))
        }
        .padding(.horizontal, 30)
        .padding(.top, 52)
        .padding(.bottom, 24)
        .background(WorkspacePalette.canvas)
        .onChange(of: noteText) { _, updatedText in
            copied = false
            if updatedText != notesStore.scratchpadText { notesStore.saveScratchpad(updatedText) }
        }
        .onReceive(notesStore.$scratchpadText) { value in
            if noteText != value { noteText = value }
        }
        .onReceive(NotificationCenter.default.publisher(for: .localBackupDidRestore)) { _ in
            notesStore.reload()
            selectedNoteID = nil
        }
        .alert(t("Clear the scratchpad?"), isPresented: $isConfirmingClear) {
            Button(t("Cancel"), role: .cancel) {}
            Button(t("Clear"), role: .destructive) { noteText = "" }
        } message: {
            Text(t("This removes the locally saved note and cannot be undone."))
        }
        .alert(t("Delete this meeting note?"), isPresented: $isConfirmingDelete) {
            Button(t("Cancel"), role: .cancel) {}
            Button(t("Delete note"), role: .destructive) {
                if let id = selectedNoteID, notesStore.remove(noteID: id) { selectedNoteID = nil }
            }
        } message: {
            Text(t("The calendar event is kept. Export the note first if you want a copy."))
        }
    }

    private var pageHeader: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .bottom, spacing: 16) {
                headerTitle.fixedSize(horizontal: true, vertical: false)
                Spacer()
                headerActions.fixedSize()
            }
            VStack(alignment: .leading, spacing: 12) {
                headerTitle
                headerActions
            }
        }
    }

    private var headerTitle: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(t("Scratchpad"))
                .font(.system(size: 27, weight: .bold, design: .rounded))
                .foregroundStyle(WorkspacePalette.primaryText)
            Text(t("Keep thoughts close and meeting decisions connected."))
                .font(.system(size: 12.5, weight: .medium))
                .foregroundStyle(WorkspacePalette.secondaryText)
        }
    }

    private var headerActions: some View {
        HStack(spacing: 8) {
            if mode == 0 {
                Button { insertTimestamp() } label: { Label(t("Add time"), systemImage: "clock.badge.plus") }
                    .keyboardShortcut("t", modifiers: [.command, .shift])
                Button { copyNote() } label: {
                    Label(copied ? t("Copied") : t("Copy"), systemImage: copied ? "checkmark" : "doc.on.doc")
                }.disabled(noteText.isEmpty)
            }
            Menu {
                Button(t("Export this note")) { exportCurrentNote() }
                    .disabled(mode == 0 ? noteText.isEmpty : selectedNote == nil)
                Button(t("Export all notes")) { exportAllNotes() }
                    .disabled(noteText.isEmpty && notesStore.notes.isEmpty)
            } label: { Label(t("Export Markdown"), systemImage: "square.and.arrow.up") }
            Button {
                if mode == 0 { isConfirmingClear = true } else { isConfirmingDelete = true }
            } label: { Image(systemName: "trash") }
                .disabled(mode == 0 ? noteText.isEmpty : selectedNote == nil)
                .accessibilityLabel(mode == 0 ? t("Clear scratchpad") : t("Delete note"))
                .help(mode == 0 ? t("Clear scratchpad") : t("Delete note"))
        }
        .buttonStyle(.bordered)
        .controlSize(.small)
    }

    private var scratchpadEditor: some View {
        WorkspaceCard {
            ZStack(alignment: .topLeading) {
                if noteText.isEmpty {
                    VStack(alignment: .leading, spacing: 7) {
                        Text(t("Write something to remember…"))
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                        Text(t("A thought, a link, or the next small step."))
                            .font(.system(size: 11.5))
                    }
                    .foregroundStyle(WorkspacePalette.secondaryText)
                    .padding(18)
                    .allowsHitTesting(false)
                }
                CompositionSafeTextEditor(text: $noteText, label: t("Scratchpad"))
                    .padding(6)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var meetingLibrary: some View {
        HStack(spacing: 12) {
            WorkspaceCard {
                ScrollView {
                    LazyVStack(spacing: 3) {
                        if filteredNotes.isEmpty {
                            VStack(alignment: .leading, spacing: 7) {
                                Text(t(query.isEmpty ? "No meeting notes yet" : "No matching notes"))
                                    .font(.headline)
                                Text(t(query.isEmpty ? "Open a calendar event to write its first note." : "Try a title, calendar name, or words from the note."))
                                    .font(.caption)
                                    .foregroundStyle(WorkspacePalette.secondaryText)
                            }
                            .padding(16)
                        }
                        ForEach(filteredNotes) { note in
                            Button { selectedNoteID = note.id } label: {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(note.eventTitle.isEmpty ? t("Untitled event") : note.eventTitle)
                                        .font(.system(size: 12, weight: .semibold))
                                        .lineLimit(2)
                                        .foregroundStyle(WorkspacePalette.primaryText)
                                    Text(note.eventStart.formatted(.dateTime.month().day().hour().minute().locale(appLanguage.locale)))
                                        .font(.system(size: 10, design: .monospaced))
                                        .foregroundStyle(WorkspacePalette.secondaryText)
                                    Text(note.text.replacingOccurrences(of: "\n", with: " "))
                                        .font(.system(size: 10.5))
                                        .lineLimit(2)
                                        .foregroundStyle(WorkspacePalette.secondaryText)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(12)
                                .background(selectedNoteID == note.id ? WorkspacePalette.accent.opacity(0.13) : Color.clear,
                                            in: RoundedRectangle(cornerRadius: 10))
                                .overlay(alignment: .leading) {
                                    if selectedNoteID == note.id {
                                        Capsule().fill(WorkspacePalette.accent).frame(width: 3, height: 28)
                                    }
                                }
                            }.buttonStyle(.plain)
                        }
                    }.padding(6)
                }
            }
            .frame(width: 230)
            WorkspaceCard {
                if let note = selectedNote {
                    MeetingNoteEditor(note: note, store: notesStore)
                } else {
                    VStack(spacing: 10) {
                        Image(systemName: "note.text").font(.system(size: 30, weight: .light))
                        Text(t("Choose a meeting note"))
                        Text(t("Your notes stay available even if the calendar event is removed."))
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                    .foregroundStyle(WorkspacePalette.secondaryText)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(24)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var filteredNotes: [MeetingNote] { notesStore.matching(query) }
    private var selectedNote: MeetingNote? { notesStore.notes.first { $0.id == selectedNoteID } }

    private func insertTimestamp() {
        let stamp = Date().formatted(.dateTime.month(.abbreviated).day().hour().minute().locale(appLanguage.locale))
        noteText += (noteText.isEmpty || noteText.hasSuffix("\n") ? "" : "\n") + "• \(stamp) — "
    }
    private func copyNote() {
        NSPasteboard.general.clearContents()
        copied = NSPasteboard.general.setString(noteText, forType: .string)
    }
    private func exportCurrentNote() {
        let markdown = mode == 0 ? noteText : selectedNote.map(NotesMarkdown.meeting) ?? ""
        export(markdown, name: mode == 0 ? "Scratchpad" : "Meeting Note")
    }
    private func exportAllNotes() {
        export(NotesMarkdown.all(scratchpad: noteText, notes: notesStore.notes), name: "Notch Calendar Notes")
    }
    private func export(_ markdown: String, name: String) {
        do {
            try NotesExportPanel.save(markdown: markdown, name: name, language: appLanguage)
            exportError = nil
        } catch { exportError = t("The note could not be exported. Choose another location and try again.") }
    }
    private func t(_ key: String, _ arguments: CVarArg...) -> String {
        L10n.string(key, language: appLanguage, arguments: arguments)
    }
}
