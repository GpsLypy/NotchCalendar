import Foundation
import XCTest
@testable import NotchCalendar

final class LocalBackupTests: XCTestCase {
    @MainActor
    func testRoundTripPreviewRestorePauseAndUndoPreserveUnrelatedData() throws {
        try withContext { defaults, directory in
            let store = LocalBackupStore(defaults: defaults, recoveryDirectory: directory.appendingPathComponent("recovery"))
            defaults.set("Original note", forKey: "workspace.scratchpad.text")
            defaults.set("zh-Hans", forKey: "app.language")
            defaults.set("DO NOT EXPORT", forKey: "api.secret")
            defaults.set(Data("CACHED ACCOUNT EVENTS".utf8), forKey: "calendar.rawEvents")
            let timer = FocusTimerModel(defaults: defaults, now: Date())
            timer.toggle()
            let file = directory.appendingPathComponent("backup.json")
            try store.export(to: file)
            let encoded = try String(contentsOf: file, encoding: .utf8)
            XCTAssertFalse(encoded.contains("DO NOT EXPORT"))
            XCTAssertFalse(encoded.contains("calendar.rawEvents"))
            defaults.set("Current note", forKey: "workspace.scratchpad.text")
            defaults.set("en", forKey: "app.language")
            try store.prepareImport(from: file)
            XCTAssertEqual(store.preview?.scratchpadCharacters, "Original note".count)
            XCTAssertEqual(defaults.string(forKey: "workspace.scratchpad.text"), "Current note")
            try store.restorePreview()
            XCTAssertEqual(defaults.string(forKey: "workspace.scratchpad.text"), "Original note")
            XCTAssertEqual(defaults.string(forKey: "app.language"), "zh-Hans")
            XCTAssertTrue(store.canUndo)
            let restoredTimer = FocusTimerModel(defaults: defaults)
            XCTAssertFalse(restoredTimer.isRunning)
            XCTAssertTrue(restoredTimer.history.isEmpty)
            XCTAssertEqual(defaults.string(forKey: "api.secret"), "DO NOT EXPORT")
            try store.undoRestore()
            XCTAssertEqual(defaults.string(forKey: "workspace.scratchpad.text"), "Current note")
            XCTAssertEqual(defaults.string(forKey: "app.language"), "en")
            XCTAssertFalse(store.canUndo)
        }
    }

    @MainActor
    func testMaximumTaskLabelRemainsValidAcrossBackupAndRestore() throws {
        try withContext { defaults, directory in
            let timer = FocusTimerModel(defaults: defaults)
            let label = String(repeating: "中", count: 200)
            timer.setTaskLabel(label)
            let store = LocalBackupStore(defaults: defaults, recoveryDirectory: directory.appendingPathComponent("recovery"))
            let file = directory.appendingPathComponent("label.json")
            try store.export(to: file)
            timer.setTaskLabel("Changed")
            try store.prepareImport(from: file)
            try store.restorePreview()
            XCTAssertEqual(FocusTimerModel(defaults: defaults).taskLabel, label)
        }
    }

    @MainActor
    func testMalformedVersionSensitiveKeyAndWrongTypesFailWithoutChanges() throws {
        try withContext { defaults, directory in
            defaults.set("Untouched", forKey: "workspace.scratchpad.text")
            let store = LocalBackupStore(defaults: defaults, recoveryDirectory: directory)
            var wrongVersion = LocalBackupDocument(exportedAt: Date(), values: [:])
            wrongVersion.version = 99
            let samples = [
                Data("not JSON".utf8),
                try JSONEncoder().encode(wrongVersion),
                try JSONEncoder().encode(LocalBackupDocument(exportedAt: Date(), values: ["api.key": .string("secret")])),
                try JSONEncoder().encode(LocalBackupDocument(exportedAt: Date(), values: ["meetings.remindersEnabled": .string("true")])),
                try JSONEncoder().encode(LocalBackupDocument(exportedAt: Date(), values: ["workspace.planning.startHour": .integer(23), "workspace.planning.endHour": .integer(8)])),
                try JSONEncoder().encode(LocalBackupDocument(exportedAt: Date(), values: ["calendar.secondaryTimeZone": .string("Mars/Olympus")])),
                Data(repeating: 32, count: LocalBackupPolicy.maximumFileBytes + 1)
            ]
            for (index, sample) in samples.enumerated() {
                let url = directory.appendingPathComponent("invalid-\(index).json")
                try sample.write(to: url)
                XCTAssertThrowsError(try store.prepareImport(from: url), "Sample \(index)")
                XCTAssertNil(store.preview)
                XCTAssertThrowsError(try store.restorePreview())
                XCTAssertEqual(defaults.string(forKey: "workspace.scratchpad.text"), "Untouched")
            }
        }
    }

    @MainActor
    func testFailedRecoveryWriteNeverAppliesIncomingValues() throws {
        try withContext { defaults, directory in
            defaults.set("Current", forKey: "workspace.scratchpad.text")
            let notDirectory = directory.appendingPathComponent("file-instead-of-directory")
            try Data().write(to: notDirectory)
            let store = LocalBackupStore(defaults: defaults, recoveryDirectory: notDirectory)
            let incoming = LocalBackupDocument(exportedAt: Date(), values: ["workspace.scratchpad.text": .string("Imported")])
            let url = directory.appendingPathComponent("incoming.json")
            try incoming.encoded().write(to: url)
            try store.prepareImport(from: url)
            XCTAssertThrowsError(try store.restorePreview())
            XCTAssertEqual(defaults.string(forKey: "workspace.scratchpad.text"), "Current")
            XCTAssertFalse(store.canUndo)
        }
    }

    @MainActor
    func testValidBackupCanRepairDamagedNotesAndUndoPreservesOriginalBytes() throws {
        try withContext { defaults, directory in
            let malformed = Data("damaged existing local data".utf8)
            defaults.set(malformed, forKey: "meeting.notes.v1")
            let oldTimer = FocusTimerModel(defaults: defaults)
            oldTimer.toggle()
            let store = LocalBackupStore(defaults: defaults, recoveryDirectory: directory.appendingPathComponent("recovery"))
            let incoming = LocalBackupDocument(exportedAt: Date(), values: ["workspace.scratchpad.text": .string("Recovered")])
            let url = directory.appendingPathComponent("valid.json")
            try incoming.encoded().write(to: url)
            try store.prepareImport(from: url)
            try store.restorePreview()
            XCTAssertNil(defaults.data(forKey: "meeting.notes.v1"))
            XCTAssertTrue(MeetingNotesStore(defaults: defaults).canEditMeetingNotes)
            try store.undoRestore()
            XCTAssertEqual(defaults.data(forKey: "meeting.notes.v1"), malformed)
            XCTAssertFalse(FocusTimerModel(defaults: defaults).isRunning)
        }
    }

    func testOversizedNotesDuplicateIDsAndInvalidFocusHistoryAreRejected() throws {
        let note = MeetingNote(id: UUID(), occurrenceKey: "one", occurrenceAliases: nil, eventTitle: "Call",
                               eventStart: Date(), calendarName: "Work", text: "Text", createdAt: Date(), updatedAt: Date())
        let duplicate = try JSONEncoder().encode(MeetingNotesDocument(notes: [note, note]))
        let document = LocalBackupDocument(exportedAt: Date(), values: ["meeting.notes.v1": .data(duplicate)])
        XCTAssertThrowsError(try document.validated())
        let oversized = LocalBackupDocument(exportedAt: Date(), values: ["workspace.scratchpad.text": .string(String(repeating: "x", count: 200_001))])
        XCTAssertThrowsError(try oversized.validated())
        let invalidHistory = Data("{\"selectedMinutes\":25,\"selectedKind\":\"focus\",\"remainingSeconds\":1500,\"isRunning\":false,\"completedSessions\":0,\"history\":[{\"id\":\"\(UUID().uuidString)\",\"completedAt\":0,\"minutes\":-1,\"kind\":\"focus\"}]}".utf8)
        XCTAssertThrowsError(try BackupFocusSnapshot.decode(invalidHistory))
    }

    @MainActor
    private func withContext(_ body: (UserDefaults, URL) throws -> Void) throws {
        let name = "NotchCalendarTests.LocalBackup.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(name)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer {
            defaults.removePersistentDomain(forName: name)
            try? FileManager.default.removeItem(at: directory)
        }
        try body(defaults, directory)
    }
}
