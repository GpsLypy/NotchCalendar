import SwiftUI

struct BackupSettingsSection: View {
    @ObservedObject var store: LocalBackupStore
    @Environment(\.appLanguage) private var appLanguage
    @State private var confirmsUndo = false

    var body: some View {
        Section(t("Backup and restore")) {
            Text(t("Back up your scratchpad, meeting notes, focus history, and app settings to a JSON file."))
            HStack {
                Button(t("Export backup")) { store.chooseExport(language: appLanguage) }
                Button(t("Restore backup…")) { store.chooseImport(language: appLanguage) }
                if store.canUndo {
                    Button(t("Undo last restore…")) { confirmsUndo = true }
                }
            }
            Text(t("Calendar events, account credentials, API keys, and downloaded content are excluded. Backups contain readable notes; store them privately."))
                .font(.caption)
                .foregroundStyle(.secondary)
            if let preview = store.preview {
                restorePreview(preview)
            }
            if let message = store.statusMessage {
                Label(t(message), systemImage: store.hasError ? "exclamationmark.triangle" : "checkmark.circle")
                    .foregroundStyle(store.hasError ? Color.orange : Color.secondary)
                    .font(.caption)
            }
        }
        .confirmationDialog(t("Undo the last restore?"), isPresented: $confirmsUndo, titleVisibility: .visible) {
            Button(t("Undo restore"), role: .destructive) { store.confirmUndo() }
            Button(t("Cancel"), role: .cancel) {}
        } message: {
            Text(t("This replaces local notes and app settings with the automatic copy from before your last restore. Changes made since then will be replaced."))
        }
    }

    private func restorePreview(_ preview: LocalBackupPreview) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(t("Review before restoring"), systemImage: "doc.text.magnifyingglass")
                .font(.headline)
            Text(t("Backup created %@", preview.exportedAt.formatted(.dateTime.year().month().day().hour().minute().locale(appLanguage.locale))))
                .font(.caption)
                .foregroundStyle(.secondary)
            Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 5) {
                previewRow("Scratchpad characters", count: preview.scratchpadCharacters)
                previewRow("Meeting notes", count: preview.meetingNotes)
                previewRow("Focus records", count: preview.focusRecords)
                previewRow("App settings", count: preview.settings)
            }
            Text(t("Restoring replaces all backed-up categories, including empty ones. A recovery copy is saved first. Timers stay paused and system permissions stay as they are."))
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack {
                Button(t("Cancel")) { store.cancelImport() }
                Spacer()
                Button(t("Replace local data and restore"), role: .destructive) { store.confirmRestore() }
            }
        }
        .padding(12)
        .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 10))
    }

    private func previewRow(_ title: String, count: Int) -> some View {
        GridRow {
            Text(t(title))
            Text("\(count)").monospacedDigit()
        }
    }
    private func t(_ key: String, _ arguments: CVarArg...) -> String {
        L10n.string(key, language: appLanguage, arguments: arguments)
    }
}
