import Foundation
import SwiftUI

extension Notification.Name {
    static let localBackupDidRestore = Notification.Name("NotchCalendar.localBackupDidRestore")
}

struct MeetingNote: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    let occurrenceKey: String
    var occurrenceAliases: [String]?
    var eventTitle: String
    var eventStart: Date
    var calendarName: String
    var text: String
    let createdAt: Date
    var updatedAt: Date
}

struct MeetingNotesDocument: Codable, Equatable, Sendable {
    var version = 1
    var notes: [MeetingNote]

    static let maximumBytes = 6 * 1_024 * 1_024
    static let maximumNotes = 1_000
    static let maximumTextCharacters = 200_000

    static func decode(_ data: Data) throws -> Self {
        guard data.count <= maximumBytes else { throw LocalNotesError.tooLarge }
        let document: Self
        do { document = try JSONDecoder().decode(Self.self, from: data) }
        catch { throw LocalNotesError.invalidData }
        guard document.version == 1 else { throw LocalNotesError.unsupportedVersion }
        guard document.notes.count <= maximumNotes else { throw LocalNotesError.tooManyNotes }
        guard Set(document.notes.map(\.id)).count == document.notes.count,
              Set(document.notes.map(\.occurrenceKey)).count == document.notes.count,
              document.notes.allSatisfy({ note in
                  !note.occurrenceKey.isEmpty && note.occurrenceKey.count <= 4_096 &&
                  (note.occurrenceAliases ?? []).count <= 32 && (note.occurrenceAliases ?? []).allSatisfy { !$0.isEmpty && $0.count <= 4_096 } &&
                  note.eventTitle.count <= 4_096 && note.calendarName.count <= 1_024 &&
                  note.text.count <= maximumTextCharacters &&
                  [note.eventStart, note.createdAt, note.updatedAt].allSatisfy { $0.timeIntervalSince1970.isFinite }
              }) else { throw LocalNotesError.invalidData }
        return document
    }
}

enum LocalNotesError: Error, LocalizedError {
    case invalidData, unsupportedVersion, tooLarge, tooManyNotes, saveFailed
    var errorDescription: String? {
        switch self {
        case .invalidData: "Saved notes could not be read. Restore a valid backup before editing."
        case .unsupportedVersion: "These notes were created by a newer version of the app. Update the app to open them."
        case .tooLarge: "Notes are too large. Keep each note below 200,000 characters and all meeting notes below 6 MB."
        case .tooManyNotes: "You have reached 1,000 meeting notes. Export and remove older notes to continue."
        case .saveFailed: "Changes could not be saved. Keep this window open and try again."
        }
    }
}

@MainActor
final class MeetingNotesStore: ObservableObject {
    static let storageKey = "meeting.notes.v1"
    static let scratchpadKey = "workspace.scratchpad.text"
    static let scratchpadEditedKey = "workspace.scratchpad.lastEdited"

    @Published private(set) var notes: [MeetingNote] = []
    @Published private(set) var scratchpadText = ""
    @Published private(set) var errorMessage: String?
    @Published private(set) var canEditMeetingNotes = true
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        reload()
    }

    /// The original scratchpad remains in its original key: migration never copies or deletes it.
    func reload() {
        scratchpadText = defaults.string(forKey: Self.scratchpadKey) ?? ""
        do {
            if let raw = defaults.object(forKey: Self.storageKey) {
                guard let data = raw as? Data else { throw LocalNotesError.invalidData }
                notes = try MeetingNotesDocument.decode(data).notes.sorted { $0.updatedAt > $1.updatedAt }
            } else { notes = [] }
            canEditMeetingNotes = true
            errorMessage = nil
        } catch {
            canEditMeetingNotes = false
            errorMessage = error.localizedDescription
        }
    }

    func note(for event: CalendarEvent) -> MeetingNote? {
        let keys = Set(event.allOccurrenceStableIDs)
        return notes.first { !keys.isDisjoint(with: [$0.occurrenceKey] + ($0.occurrenceAliases ?? [])) }
    }

    static func occurrenceKey(for event: CalendarEvent) -> String {
        // An occurrence is never identified by its title. Recurring dates keep separate notes.
        event.occurrenceStableID
    }

    @discardableResult
    func save(event: CalendarEvent, text: String, now: Date = Date()) -> Bool {
        guard canEditMeetingNotes else { return false }
        var updated = notes
        let key = Self.occurrenceKey(for: event)
        let aliases = Set(event.allOccurrenceStableIDs)
        if let index = updated.firstIndex(where: { !aliases.isDisjoint(with: [$0.occurrenceKey] + ($0.occurrenceAliases ?? [])) }) {
            updated[index].occurrenceAliases = Array(Set(updated[index].occurrenceAliases ?? []).union(aliases)).sorted()
            updated[index].eventTitle = event.title
            updated[index].eventStart = event.startDate
            updated[index].calendarName = event.calendarName
            updated[index].text = text
            updated[index].updatedAt = now
        } else if !text.isEmpty {
            updated.append(MeetingNote(id: UUID(), occurrenceKey: key, occurrenceAliases: event.allOccurrenceStableIDs, eventTitle: event.title,
                                       eventStart: event.startDate, calendarName: event.calendarName,
                                       text: text, createdAt: now, updatedAt: now))
        } else { return true }
        return persist(updated)
    }

    @discardableResult
    func update(noteID: UUID, text: String, now: Date = Date()) -> Bool {
        guard canEditMeetingNotes, let index = notes.firstIndex(where: { $0.id == noteID }) else { return false }
        var updated = notes
        updated[index].text = text
        updated[index].updatedAt = now
        return persist(updated)
    }

    @discardableResult
    func remove(noteID: UUID) -> Bool {
        guard canEditMeetingNotes else { return false }
        return persist(notes.filter { $0.id != noteID })
    }

    func matching(_ query: String) -> [MeetingNote] {
        let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return notes }
        return notes.filter { note in
            [note.eventTitle, note.calendarName, note.text].contains { $0.localizedStandardContains(query) }
        }
    }

    @discardableResult
    func saveScratchpad(_ text: String, now: Date = Date()) -> Bool {
        guard text.count <= MeetingNotesDocument.maximumTextCharacters else {
            errorMessage = LocalNotesError.tooLarge.localizedDescription
            return false
        }
        defaults.set(text, forKey: Self.scratchpadKey)
        guard defaults.string(forKey: Self.scratchpadKey) == text else {
            errorMessage = LocalNotesError.saveFailed.localizedDescription
            return false
        }
        defaults.set(now, forKey: Self.scratchpadEditedKey)
        scratchpadText = text
        if canEditMeetingNotes { errorMessage = nil }
        return true
    }

    /// Always starts from the latest persisted content, including edits from the workspace.
    @discardableResult
    func appendScratchpad(text: String, now: Date = Date()) -> Bool {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return true }
        let existing = defaults.string(forKey: Self.scratchpadKey) ?? ""
        let separator = existing.isEmpty || existing.hasSuffix("\n") ? "" : "\n"
        return saveScratchpad(existing + separator + text, now: now)
    }

    private func persist(_ updated: [MeetingNote]) -> Bool {
        do {
            let document = MeetingNotesDocument(notes: updated)
            let data = try JSONEncoder().encode(document)
            _ = try MeetingNotesDocument.decode(data)
            defaults.set(data, forKey: Self.storageKey)
            guard defaults.data(forKey: Self.storageKey) == data else { throw LocalNotesError.saveFailed }
            notes = updated.sorted { $0.updatedAt > $1.updatedAt }
            errorMessage = nil
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}

enum NotesMarkdown {
    static func meeting(_ note: MeetingNote) -> String {
        let stamp = ISO8601DateFormatter().string(from: note.eventStart)
        let title = note.eventTitle.isEmpty ? "Untitled event" : note.eventTitle
        return "# \(title.replacingOccurrences(of: "\n", with: " "))\n\n\(stamp) · \(note.calendarName)\n\n\(note.text)\n"
    }

    static func all(scratchpad: String, notes: [MeetingNote]) -> String {
        (["# Scratchpad\n\n\(scratchpad)\n"] + notes.sorted { $0.eventStart > $1.eventStart }.map(meeting))
            .joined(separator: "\n---\n\n")
    }
}
