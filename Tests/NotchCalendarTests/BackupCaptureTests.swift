import AppKit
import SwiftUI
import XCTest
@testable import NotchCalendar

/// Opt-in production-view captures. Everything below is isolated demo data; no restore or system file panel is run.
final class BackupCaptureTests: XCTestCase {
    @MainActor
    func testRenderBackupAndMeetingLibrary() async throws {
        guard let path = ProcessInfo.processInfo.environment["NOTCH_WORKFLOW_CAPTURE_PATH"] else {
            throw XCTSkip("Set NOTCH_WORKFLOW_CAPTURE_PATH for offline backup and notes captures.")
        }
        let destination = URL(fileURLWithPath: path, isDirectory: true)
        try FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true)
        let suite = "NotchCalendarTests.BackupCapture.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        let temporary = FileManager.default.temporaryDirectory.appendingPathComponent(suite, isDirectory: true)
        try FileManager.default.createDirectory(at: temporary, withIntermediateDirectories: true)
        defer {
            defaults.removePersistentDomain(forName: suite)
            try? FileManager.default.removeItem(at: temporary)
        }
        defaults.set("zh-Hans", forKey: "app.language")
        defaults.set("America/New_York", forKey: "calendar.secondaryTimeZone")
        defaults.set(true, forKey: "calendar.deduplicatesEvents")
        defaults.set(9, forKey: "workspace.planning.startHour")
        defaults.set(18, forKey: "workspace.planning.endHour")
        defaults.set(5, forKey: "workspace.planning.bufferMinutes")
        defaults.set(true, forKey: "meetings.remindersEnabled")
        defaults.set(5, forKey: "meetings.leadMinutes")
        let now = Date()
        let notes = MeetingNotesStore(defaults: defaults)
        XCTAssertTrue(notes.saveScratchpad("演示数据 / DEMO DATA\n\n今天想记住的事\n• 给产品评审留好准备时间\n• 完成 45 分钟文档专注\n• 周五回顾本周的行动项", now: now))
        func event(_ title: String, hoursAgo: Double) -> CalendarEvent {
            let date = now.addingTimeInterval(-hoursAgo * 3_600)
            return CalendarEvent(id: UUID().uuidString, title: title, startDate: date, endDate: date.addingTimeInterval(2_700),
                                 calendarName: "演示 · 工作日历", calendarColor: .systemPink, location: nil, meetingLink: nil,
                                 isAllDay: false, calendarID: "demo-work")
        }
        let review = event("演示 · 产品评审", hoursAgo: 1)
        let design = event("演示 · 设计同步", hoursAgo: 25)
        let sync = event("演示 · 每周项目同步", hoursAgo: 49)
        XCTAssertTrue(notes.save(event: review, text: "演示数据 / DEMO DATA\n\n本次决定\n先把提醒、入会和会议记录串成完整流程。\n\n行动项\n☐ 周五前补齐跨时区验证\n☐ 下次评审核对用户反馈\n\n下次讨论\n快捷指令可以怎样减少重复操作？", now: now))
        XCTAssertTrue(notes.save(event: design, text: "演示数据 / DEMO DATA\n保留紧凑原生界面，减少弹窗，让保存状态始终清楚可见。", now: now.addingTimeInterval(-3_600)))
        XCTAssertTrue(notes.save(event: sync, text: "演示数据 / DEMO DATA\n本周完成日程搜索与每周专注回顾。", now: now.addingTimeInterval(-7_200)))
        let timer = FocusTimerModel(defaults: defaults, now: now.addingTimeInterval(-6_000))
        timer.setTaskLabel("演示 · 需求文档")
        timer.toggle(now: now.addingTimeInterval(-6_000))
        timer.synchronize(now: now.addingTimeInterval(-4_500))
        timer.select(minutes: 50)
        timer.setTaskLabel("演示 · 产品设计")
        timer.toggle(now: now.addingTimeInterval(-3_100))
        timer.synchronize(now: now.addingTimeInterval(-100))

        let recovery = temporary.appendingPathComponent("recovery", isDirectory: true)
        let store = LocalBackupStore(defaults: defaults, recoveryDirectory: recovery)
        var captures: [[String: Any]] = []
        captures.append(try await render(Form { BackupSettingsSection(store: store) }.formStyle(.grouped),
                                         name: "backup-settings-zh-Hans", to: destination, defaults: defaults, width: 670, height: 370))
        let backup = temporary.appendingPathComponent("Demo Backup.json")
        try store.capture(now: now).encoded().write(to: backup, options: .atomic)
        let originalScratchpad = notes.scratchpadText
        try store.prepareImport(from: backup)
        XCTAssertEqual(store.preview?.meetingNotes, 3)
        XCTAssertEqual(store.preview?.focusRecords, 2)
        XCTAssertFalse(store.canUndo)
        captures.append(try await render(Form { BackupSettingsSection(store: store) }.formStyle(.grouped),
                                         name: "backup-preview-zh-Hans", to: destination, defaults: defaults, width: 670, height: 690))
        let selectedID = try XCTUnwrap(notes.note(for: review)?.id)
        captures.append(try await render(ScratchpadWorkspaceView(notesStore: notes, initialNoteID: selectedID),
                                         name: "meeting-library-zh-Hans", to: destination, defaults: defaults, width: 860, height: 680))
        XCTAssertEqual(defaults.string(forKey: MeetingNotesStore.scratchpadKey), originalScratchpad)
        XCTAssertFalse(FileManager.default.fileExists(atPath: recovery.path))
        let provenance: [String: Any] = [
            "generatedAt": ISO8601DateFormatter().string(from: Date()),
            "method": "Offline AppKit NSHostingView rendering of production BackupSettingsSection and ScratchpadWorkspaceView",
            "data": "All notes, settings, task labels and focus records are isolated synthetic demo fixtures, explicitly labelled in the notes.",
            "safety": "prepareImport reads only a temporary fixture for preview. No restore, undo, system file panel, notification request, real calendar read, real shortcut or user-default domain access is performed.",
            "captures": captures
        ]
        try JSONSerialization.data(withJSONObject: provenance, options: [.prettyPrinted, .sortedKeys])
            .write(to: destination.appendingPathComponent("backup-provenance.json"), options: .atomic)
    }

    @MainActor
    private func render<V: View>(_ view: V, name: String, to destination: URL, defaults: UserDefaults, width: CGFloat, height: CGFloat) async throws -> [String: Any] {
        let language = AppLanguage.simplifiedChinese
        let content = view.defaultAppStorage(defaults)
            .environment(\.appLanguage, language)
            .environment(\.locale, language.locale)
            .environment(\.colorScheme, .dark)
            .preferredColorScheme(.dark)
            .frame(width: width, height: height)
        let hosting = NSHostingView(rootView: content)
        let rect = NSRect(x: 0, y: 0, width: width, height: height)
        let window = NSWindow(contentRect: rect, styleMask: [.borderless], backing: .buffered, defer: false)
        window.appearance = NSAppearance(named: .darkAqua)
        window.contentView = hosting
        hosting.frame = rect
        try await Task.sleep(for: .milliseconds(450))
        hosting.layoutSubtreeIfNeeded()
        let bitmap = try XCTUnwrap(hosting.bitmapImageRepForCachingDisplay(in: rect))
        hosting.cacheDisplay(in: rect, to: bitmap)
        let png = try XCTUnwrap(bitmap.representation(using: .png, properties: [:]))
        try png.write(to: destination.appendingPathComponent(name + ".png"), options: .atomic)
        return ["file": name + ".png", "language": language.rawValue, "widthPoints": width, "heightPoints": height,
                "widthPixels": bitmap.pixelsWide, "heightPixels": bitmap.pixelsHigh]
    }
}
