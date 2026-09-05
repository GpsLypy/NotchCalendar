import AppKit
import Foundation
import SwiftUI
import XCTest
@testable import NotchCalendar

final class MeetingNotesTests: XCTestCase {
    @MainActor
    func testScratchpadMigrationKeepsOldKeyAndShortcutReadsLatestText() throws {
        try withDefaults { defaults in
            defaults.set("旧的便笺\n日本語メモ", forKey: MeetingNotesStore.scratchpadKey)
            let store = MeetingNotesStore(defaults: defaults)
            XCTAssertEqual(store.scratchpadText, "旧的便笺\n日本語メモ")
            XCTAssertTrue(store.notes.isEmpty)
            defaults.set("Edited elsewhere", forKey: MeetingNotesStore.scratchpadKey)
            XCTAssertTrue(store.appendScratchpad(text: "快捷指令追加"))
            XCTAssertEqual(store.scratchpadText, "Edited elsewhere\n快捷指令追加")
            XCTAssertEqual(defaults.string(forKey: MeetingNotesStore.scratchpadKey), store.scratchpadText)
            XCTAssertNotNil(defaults.object(forKey: MeetingNotesStore.scratchpadEditedKey) as? Date)
            XCTAssertTrue(store.appendScratchpad(text: "  "))
            XCTAssertEqual(store.scratchpadText, "Edited elsewhere\n快捷指令追加")
        }
    }

    @MainActor
    func testMeetingNotesAssociateByOccurrenceNotTitleAndSurviveRelaunch() throws {
        try withDefaults { defaults in
            let store = MeetingNotesStore(defaults: defaults)
            let first = event(id: "series", start: 100)
            let second = event(id: "series", start: 86_500)
            XCTAssertTrue(store.save(event: first, text: "决定 A", now: Date(timeIntervalSince1970: 200)))
            XCTAssertTrue(store.save(event: second, text: "决定 B", now: Date(timeIntervalSince1970: 86_600)))
            XCTAssertEqual(store.notes.count, 2)
            XCTAssertEqual(store.note(for: first)?.text, "决定 A")
            XCTAssertEqual(store.note(for: second)?.text, "决定 B")
            let restored = MeetingNotesStore(defaults: defaults)
            XCTAssertEqual(restored.notes, store.notes)
            XCTAssertEqual(restored.matching("决定 A").count, 1)
            XCTAssertEqual(restored.matching("Work").count, 2)
            XCTAssertEqual(restored.matching("does not exist").count, 0)
            XCTAssertTrue(restored.update(noteID: restored.note(for: first)!.id, text: "Renamed action"))
            XCTAssertEqual(restored.note(for: first)?.text, "Renamed action")
        }
    }

    @MainActor
    func testMergedCalendarAliasKeepsNotesWhenPrimarySourceChanges() throws {
        try withDefaults { defaults in
            let store = MeetingNotesStore(defaults: defaults)
            var primary = event(id: "source-a", start: 100)
            let secondary = event(id: "source-b", start: 100)
            primary.relatedOccurrenceIDs = [secondary.occurrenceStableID]
            XCTAssertTrue(store.save(event: primary, text: "Shared meeting decision"))
            XCTAssertEqual(store.note(for: secondary)?.text, "Shared meeting decision")
            XCTAssertTrue(store.save(event: secondary, text: "Updated after hiding source A"))
            XCTAssertEqual(store.notes.count, 1)
            XCTAssertEqual(store.note(for: primary)?.text, "Updated after hiding source A")
            XCTAssertEqual(MeetingNotesStore(defaults: defaults).note(for: secondary)?.text, "Updated after hiding source A")
        }
    }

    @MainActor
    func testBlankEventDoesNotCreatePlaceholderNoteAndRemoveIsLocal() throws {
        try withDefaults { defaults in
            let store = MeetingNotesStore(defaults: defaults)
            let meeting = event(id: "meeting", start: 100)
            XCTAssertTrue(store.save(event: meeting, text: ""))
            XCTAssertTrue(store.notes.isEmpty)
            XCTAssertTrue(store.save(event: meeting, text: "Follow up"))
            let note = try XCTUnwrap(store.note(for: meeting))
            XCTAssertTrue(store.remove(noteID: note.id))
            XCTAssertTrue(MeetingNotesStore(defaults: defaults).notes.isEmpty)
            XCTAssertEqual(meeting.title, "Daily meeting")
        }
    }

    @MainActor
    func testCorruptNotesRemainUntouchedAndOversizedEditsNeverReplaceSavedContent() throws {
        try withDefaults { defaults in
            let malformed = Data("not JSON".utf8)
            defaults.set(malformed, forKey: MeetingNotesStore.storageKey)
            let damaged = MeetingNotesStore(defaults: defaults)
            XCTAssertFalse(damaged.canEditMeetingNotes)
            XCTAssertNotNil(damaged.errorMessage)
            XCTAssertFalse(damaged.save(event: event(id: "a", start: 10), text: "Do not overwrite"))
            XCTAssertEqual(defaults.data(forKey: MeetingNotesStore.storageKey), malformed)
            defaults.removeObject(forKey: MeetingNotesStore.storageKey)
            damaged.reload()
            XCTAssertTrue(damaged.canEditMeetingNotes)
            XCTAssertTrue(damaged.saveScratchpad("Original"))
            XCTAssertFalse(damaged.saveScratchpad(String(repeating: "中", count: 200_001)))
            XCTAssertEqual(damaged.scratchpadText, "Original")
            XCTAssertEqual(defaults.string(forKey: MeetingNotesStore.scratchpadKey), "Original")
        }
    }

    func testMarkdownRetainsUnicodeAndCalendarMetadata() {
        let note = MeetingNote(id: UUID(), occurrenceKey: "event/date", occurrenceAliases: nil,
                               eventTitle: "Planning\nmeeting", eventStart: Date(timeIntervalSince1970: 0), calendarName: "工作",
                               text: "- [ ] 跟进事项\n\n**Decision**", createdAt: Date(), updatedAt: Date())
        let markdown = NotesMarkdown.all(scratchpad: "想法", notes: [note])
        XCTAssertTrue(markdown.contains("# Scratchpad\n\n想法"))
        XCTAssertTrue(markdown.contains("# Planning meeting"))
        XCTAssertTrue(markdown.contains("1970-01-01T00:00:00Z · 工作"))
        XCTAssertTrue(markdown.contains("- [ ] 跟进事项\n\n**Decision**"))
    }

    @MainActor
    func testEditorDoesNotPublishMarkedTextAndMergesExternalAppendAtCommit() {
        var saved = "Hello "
        let coordinator = CompositionSafeTextEditor.Coordinator(text: Binding(get: { saved }, set: { saved = $0 }))
        coordinator.lastAppliedText = "Hello "
        let editor = NSTextView()
        editor.string = "Hello "
        editor.setSelectedRange(NSRange(location: 6, length: 0))
        editor.setMarkedText("zhong", selectedRange: NSRange(location: 5, length: 0), replacementRange: NSRange(location: NSNotFound, length: 0))
        coordinator.textDidChange(Notification(name: NSText.didChangeNotification, object: editor))
        XCTAssertEqual(saved, "Hello ")
        coordinator.pendingExternalText = "Hello \nShortcut"
        editor.insertText("中", replacementRange: editor.markedRange())
        editor.unmarkText()
        coordinator.textDidChange(Notification(name: NSText.didChangeNotification, object: editor))
        XCTAssertEqual(saved, "Hello 中\nShortcut")
    }

    @MainActor
    private func withDefaults(_ body: (UserDefaults) throws -> Void) throws {
        let name = "NotchCalendarTests.MeetingNotes.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name) }
        try body(defaults)
    }

    private func event(id: String, start: TimeInterval) -> CalendarEvent {
        CalendarEvent(id: id, title: "Daily meeting", startDate: Date(timeIntervalSince1970: start),
                      endDate: Date(timeIntervalSince1970: start + 3_600), calendarName: "Work", calendarColor: nil,
                      location: nil, meetingLink: nil, isAllDay: false, calendarID: "work", originalOccurrenceDate: Date(timeIntervalSince1970: start),
                      seriesIdentifier: id, isRecurring: true)
    }
}
