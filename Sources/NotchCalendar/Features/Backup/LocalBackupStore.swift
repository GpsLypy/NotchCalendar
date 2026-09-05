import AppKit
import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct LocalBackupPreview: Identifiable {
    let id = UUID()
    let exportedAt: Date
    let scratchpadCharacters: Int
    let meetingNotes: Int
    let focusRecords: Int
    let settings: Int

    init(document: LocalBackupDocument) throws {
        exportedAt = document.exportedAt
        if case .string(let value)? = document.values["workspace.scratchpad.text"] { scratchpadCharacters = value.count }
        else { scratchpadCharacters = 0 }
        if case .data(let value)? = document.values["meeting.notes.v1"] { meetingNotes = try MeetingNotesDocument.decode(value).notes.count }
        else { meetingNotes = 0 }
        if case .data(let value)? = document.values["workspace.focus.snapshot.v1"] { focusRecords = try BackupFocusSnapshot.decode(value).history.count }
        else { focusRecords = 0 }
        settings = document.values.keys.filter { !$0.hasPrefix("workspace.focus.") && !$0.hasPrefix("workspace.scratchpad.") && $0 != "meeting.notes.v1" }.count
    }
}

@MainActor
final class LocalBackupStore: ObservableObject {
    @Published private(set) var preview: LocalBackupPreview?
    @Published private(set) var canUndo = false
    @Published private(set) var statusMessage: String?
    @Published private(set) var hasError = false
    private var pendingDocument: LocalBackupDocument?
    private let defaults: UserDefaults
    private let recoveryURL: URL

    init(defaults: UserDefaults = .standard, recoveryDirectory: URL? = nil) {
        self.defaults = defaults
        let directory = recoveryDirectory ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("NotchCalendar/Backups", isDirectory: true)
        recoveryURL = directory.appendingPathComponent("Before Last Restore.json")
        canUndo = FileManager.default.fileExists(atPath: recoveryURL.path)
    }

    func capture(now: Date = Date()) throws -> LocalBackupDocument {
        try currentDocument(now: now).validated()
    }

    func export(to url: URL) throws {
        let data = try capture().encoded()
        do { try data.write(to: url, options: .atomic) }
        catch { throw LocalBackupError.writeFailed }
        report("Backup saved. Keep it somewhere private; notes are included as plain text.")
    }

    /// Import is read-only until the user confirms this exact in-memory document's preview.
    func prepareImport(from url: URL) throws {
        pendingDocument = nil
        preview = nil
        let document = try LocalBackupDocument.decode(readBounded(url))
        let preview = try LocalBackupPreview(document: document)
        pendingDocument = document
        self.preview = preview
        statusMessage = nil
        hasError = false
    }

    func cancelImport() {
        pendingDocument = nil
        preview = nil
    }

    func restorePreview() throws {
        guard let pendingDocument else { throw LocalBackupError.noPreview }
        let incoming = try pendingDocument.preparedForRestore()
        // Capture exact old values before touching preferences. A damaged local note is still preserved in this copy.
        let previous = try currentDocument()
        do {
            let directory = recoveryURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            let data = try JSONEncoder().encode(previous)
            guard data.count <= LocalBackupPolicy.maximumFileBytes else { throw LocalBackupError.tooLarge }
            try data.write(to: recoveryURL, options: .atomic)
        } catch { throw LocalBackupError.recoveryFailed }
        apply(incoming)
        canUndo = true
        cancelImport()
        report("Backup restored. Focus timers are paused. You can undo this restore below.")
        NotificationCenter.default.post(name: .localBackupDidRestore, object: nil)
    }

    func undoRestore() throws {
        guard canUndo else { throw LocalBackupError.noPreview }
        let data = try readBounded(recoveryURL)
        // Internal recovery may contain malformed pre-existing note bytes, but never unlisted preference keys.
        let previous: LocalBackupDocument
        do { previous = try JSONDecoder().decode(LocalBackupDocument.self, from: data) }
        catch { throw LocalBackupError.invalidData }
        guard previous.format == LocalBackupPolicy.format, previous.version == LocalBackupPolicy.version,
              previous.values.keys.allSatisfy(LocalBackupPolicy.allowedKeys.contains) else { throw LocalBackupError.invalidData }
        // Even when another category was corrupt before restore, pause any readable focus snapshot independently.
        var pausedPrevious = previous
        if case .data(let bytes)? = pausedPrevious.values["workspace.focus.snapshot.v1"],
           var focus = try? BackupFocusSnapshot.decode(bytes) {
            focus.isRunning = false
            focus.targetDate = nil
            pausedPrevious.values["workspace.focus.snapshot.v1"] = .data(try JSONEncoder().encode(focus))
        }
        if pausedPrevious.values["workspace.focus.isRunning"] != nil {
            pausedPrevious.values["workspace.focus.isRunning"] = .bool(false)
        }
        pausedPrevious.values.removeValue(forKey: "workspace.focus.targetDate")
        apply(pausedPrevious)
        canUndo = false
        try? FileManager.default.removeItem(at: recoveryURL)
        cancelImport()
        report("Restore undone. The data from before your last restore is back.")
        NotificationCenter.default.post(name: .localBackupDidRestore, object: nil)
    }

    func chooseExport(language: AppLanguage) {
        let panel = NSSavePanel()
        panel.title = L10n.string("Export backup", language: language)
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "Notch Calendar Backup \(Date().formatted(.iso8601.year().month().day().dateSeparator(.dash))).json"
        panel.canCreateDirectories = true
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do { try export(to: url) } catch { report(error.localizedDescription, error: true) }
    }

    func chooseImport(language: AppLanguage) {
        let panel = NSOpenPanel()
        panel.title = L10n.string("Choose backup", language: language)
        panel.allowedContentTypes = [.json]
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do { try prepareImport(from: url) } catch { report(error.localizedDescription, error: true) }
    }

    func confirmRestore() {
        do { try restorePreview() } catch { report(error.localizedDescription, error: true) }
    }

    func confirmUndo() {
        do { try undoRestore() } catch { report(error.localizedDescription, error: true) }
    }

    private func currentDocument(now: Date = Date()) throws -> LocalBackupDocument {
        var values: [String: LocalBackupValue] = [:]
        for key in LocalBackupPolicy.allowedKeys {
            if let value = defaults.object(forKey: key) { values[key] = try LocalBackupValue.from(value) }
        }
        return LocalBackupDocument(exportedAt: now, values: values)
    }

    private func readBounded(_ url: URL) throws -> Data {
        do {
            let values = try url.resourceValues(forKeys: [.isRegularFileKey, .fileSizeKey])
            guard values.isRegularFile == true else { throw LocalBackupError.readFailed }
            guard let size = values.fileSize, size <= LocalBackupPolicy.maximumFileBytes else { throw LocalBackupError.tooLarge }
            let data = try Data(contentsOf: url)
            guard data.count <= LocalBackupPolicy.maximumFileBytes else { throw LocalBackupError.tooLarge }
            return data
        } catch let error as LocalBackupError { throw error }
        catch { throw LocalBackupError.readFailed }
    }

    private func apply(_ document: LocalBackupDocument) {
        for key in LocalBackupPolicy.allowedKeys {
            if let value = document.values[key] { defaults.set(value.propertyListValue, forKey: key) }
            else { defaults.removeObject(forKey: key) }
        }
    }

    private func report(_ message: String, error: Bool = false) {
        statusMessage = message
        hasError = error
    }
}
