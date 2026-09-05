import AppKit
import SwiftUI
import XCTest
@testable import NotchCalendar

/// Explicitly opt in to offline native captures. Every model uses demo records,
/// isolated preferences, fake Calendar access, fake notifications and fake keys.
final class WorkflowCaptureTests: XCTestCase {
    @MainActor
    func testRenderCompleteWorkflow() async throws {
        guard let path = ProcessInfo.processInfo.environment["NOTCH_WORKFLOW_CAPTURE_PATH"] else {
            throw XCTSkip("Set NOTCH_WORKFLOW_CAPTURE_PATH for offline workflow layout captures.")
        }
        let destination = URL(fileURLWithPath: path, isDirectory: true)
        try FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true)
        let suite = "WorkflowCapture.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        defaults.set("America/New_York", forKey: CalendarTimeZoneTools.secondaryStorageKey)
        let clock = Date()
        let day = Calendar.current.startOfDay(for: clock)
        func time(_ hour: Int, _ minute: Int = 0) -> Date {
            Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: day)!
        }
        func demoEvent(_ id: String, _ title: String, _ start: Date, _ minutes: Int, calendarID: String = "work", recurring: Bool = false) -> CalendarEvent {
            CalendarEvent(id: "demo-\(id)", title: title, startDate: start,
                          endDate: start.addingTimeInterval(TimeInterval(minutes * 60)),
                          calendarName: calendarID == "work" ? "演示 · 工作 / Demo work" : "演示 · 订阅 / Demo subscription",
                          calendarColor: calendarID == "work" ? .systemPink : .systemBlue,
                          location: "演示 · 301 会议室 / Demo room 301",
                          meetingLink: MeetingLink(url: URL(string: "https://meet.google.com/abc-defg-hij")!, provider: .googleMeet),
                          isAllDay: false, calendarID: calendarID,
                          originalOccurrenceDate: recurring ? start : nil,
                          seriesIdentifier: "demo-series-\(id)", isRecurring: recurring)
        }
        let review = demoEvent("review", "演示 · 产品评审 / Demo product review", time(10), 45, recurring: true)
        let design = demoEvent("design", "演示 · 设计同步 / Demo design sync", time(14, 30), 30)
        let next = demoEvent("join", "演示 · 接下来的线上会议 / Demo next meeting", clock.addingTimeInterval(600), 45)
        let copy = demoEvent("review-copy", review.title, time(10), 45, calendarID: "subscribed", recurring: true)
        let provider = CalendarSelectionTestDataSource(
            eventsByCalendarID: ["work": [review, design, next], "subscribed": [copy]],
            calendars: [
                CalendarSource(id: "work", title: "演示 · 工作 / Demo work", sourceTitle: "演示账户 / Demo account", color: .systemPink, allowsContentModifications: true),
                CalendarSource(id: "subscribed", title: "演示 · 订阅 / Demo subscription", sourceTitle: "演示账户 / Demo account", color: .systemBlue)
            ]
        )
        let manager = CalendarManager(dataSource: provider, defaults: defaults)
        let notes = MeetingNotesStore(defaults: defaults)
        XCTAssertTrue(notes.saveScratchpad("演示数据 / DEMO DATA\n\n今天要完成的事\n• 整理评审结论\n• 给设计稿留出 45 分钟专注时间\n• 把会议行动项写进对应日程的笔记\n\n这里的文字和日历都来自离线测试样例。", now: clock))
        XCTAssertTrue(notes.save(event: review, text: "演示数据 / DEMO DATA\n\n决定\n本周先完成日历搜索与快捷入会体验。\n\n行动项\n• 设计：周五前确认空状态文案\n• 开发：补齐跨时区边界测试\n• 下次例会：回顾实际使用反馈", now: clock))
        XCTAssertTrue(notes.save(event: design, text: "演示数据 / DEMO DATA\n界面使用现有珊瑚色点缀，保留紧凑的原生交互。", now: clock.addingTimeInterval(-600)))
        let presentation = MainCalendarPresentation()
        presentation.isActive = true
        let week = try XCTUnwrap(Calendar.current.dateInterval(of: .weekOfYear, for: clock))
        let labels = ["演示 · 产品设计", "演示 · 深度开发", "演示 · 文档整理"]
        var records: [FocusHistoryRecord] = []
        for offset in 0..<7 {
            let completed = Calendar.current.date(byAdding: .day, value: offset, to: week.start)!.addingTimeInterval(10 * 3_600)
            guard completed <= clock else { continue }
            records.append(FocusHistoryRecord(id: UUID(), completedAt: completed, minutes: [25, 45, 60, 30, 90, 50, 25][offset], kind: .focus, taskLabel: labels[offset % labels.count]))
            if offset < 4 {
                records.append(FocusHistoryRecord(id: UUID(), completedAt: completed.addingTimeInterval(3_600), minutes: 25, kind: .focus, taskLabel: labels[(offset + 1) % labels.count]))
            }
        }
        // Monday morning should still show a real retained demo completion.
        if records.isEmpty {
            records = [FocusHistoryRecord(id: UUID(), completedAt: clock.addingTimeInterval(-60), minutes: 25, kind: .focus, taskLabel: labels[0])]
        }
        let preferences = MeetingPreferences(defaults: defaults)
        preferences.remindersEnabled = true
        preferences.hotKeyEnabled = true
        let fakeNotifications = WorkflowNotificationFixture()
        let assistant = MeetingAssistant(calendar: manager, preferences: preferences,
                                         notifications: fakeNotifications, hotKey: WorkflowHotKeyFixture(),
                                         now: { clock }, openURL: { _ in XCTFail("Capture must not open a real meeting."); return false },
                                         showError: { _ in XCTFail("Capture must not open a system alert.") })
        assistant.start()
        defer { assistant.stop() }
        await assistant.refreshNow()

        var captures: [[String: Any]] = []
        for language: AppLanguage in [.simplifiedChinese, .english] {
            for width: CGFloat in [647, 860] {
                let suffix = "\(language.rawValue)-\(Int(width))"
                captures.append(try await render(MainCalendarView(calendar: manager, presentation: presentation, selectedDate: .constant(day), onSelectEvent: { _ in }), name: "calendar-month-\(suffix)", to: destination, defaults: defaults, language: language, width: width, height: 960))
                captures.append(try await render(CalendarSearchView(calendar: manager, secondaryTimeZone: "America/New_York", onSelectEvent: { _ in }, onCreate: {}), name: "calendar-search-\(suffix)", to: destination, defaults: defaults, language: language, width: width, height: 620))
                captures.append(try await render(FocusWeeklyReviewView(records: records, now: clock).padding(30).background(WorkspacePalette.canvas), name: "weekly-review-\(suffix)", to: destination, defaults: defaults, language: language, width: width, height: 580))
                captures.append(try await render(ScratchpadWorkspaceView(notesStore: notes), name: "scratchpad-\(suffix)", to: destination, defaults: defaults, language: language, width: width, height: 650))
                captures.append(try await render(meetingPanel(event: review, notes: notes, language: language), name: "meeting-notes-\(suffix)", to: destination, defaults: defaults, language: language, width: width, height: 410))
                captures.append(try await render(MeetingControlsView(assistant: assistant).padding(30).background(WorkspacePalette.canvas), name: "meeting-controls-\(suffix)", to: destination, defaults: defaults, language: language, width: width, height: 260))
                captures.append(try await render(CalendarToolsSettingsView(calendar: manager).padding(30).background(WorkspacePalette.canvas), name: "duplicate-settings-\(suffix)", to: destination, defaults: defaults, language: language, width: width, height: 200))
            }
            var draft = CalendarEventDraft(startDate: time(15), calendarID: "work")
            draft.title = "演示 · 每周项目同步 / Demo weekly sync"
            draft.location = "演示 · 301 会议室 / Demo room 301"
            draft.link = "https://meet.google.com/abc-defg-hij"
            draft.repeatRule = .weekly
            draft.timeZoneIdentifier = "Asia/Shanghai"
            captures.append(try await render(CalendarEventComposer(calendar: manager, draft: .constant(draft), onSaved: { _ in XCTFail("Capture must not save an event.") }), name: "event-composer-\(language.rawValue)", to: destination, defaults: defaults, language: language, width: 580, height: 690))
            captures.append(try await render(CalendarTimeZonePicker(selection: .constant("America/New_York"), allowsNone: true), name: "time-zone-picker-\(language.rawValue)", to: destination, defaults: defaults, language: language, width: 340, height: 430))
        }
        XCTAssertEqual(provider.accessRequestCount, 0)
        XCTAssertEqual(fakeNotifications.authorizationRequests, 0)
        let provenance: [String: Any] = [
            "generatedAt": ISO8601DateFormatter().string(from: Date()),
            "method": "Native NSHostingView/AppKit bitmap rendering of production SwiftUI views",
            "data": "All titles, accounts, notes, links, records, reminders and preferences are isolated synthetic demo fixtures. No real calendars or user notes are read; no events are saved, links opened, notifications posted or shortcuts registered.",
            "coverage": "Simplified Chinese and English; workspace content widths 647 and 860; fixed 580-point event composer; exact duplicate badge, recurring event indicator, search results, second-zone conversion, meeting notes, local scratchpad, task-tagged weekly review and meeting controls.",
            "limits": "Layout capture is not a physical keyboard/mouse acceptance test. Captures do not verify live account sync, real notification delivery, sleep/wake or the system save panel.",
            "captures": captures
        ]
        try JSONSerialization.data(withJSONObject: provenance, options: [.prettyPrinted, .sortedKeys]).write(to: destination.appendingPathComponent("provenance.json"), options: .atomic)
    }

    @MainActor
    private func meetingPanel(event: CalendarEvent, notes: MeetingNotesStore, language: AppLanguage) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(event.displayTitle(language: language)).font(.system(size: 19, weight: .semibold, design: .rounded))
            Text(event.startDate.formatted(.dateTime.year().month().day().hour().minute().locale(language.locale)))
                .font(.system(size: 11)).foregroundStyle(WorkspacePalette.secondaryText)
            MeetingNotesPanel(event: event, store: notes)
        }
        .padding(30)
        .foregroundStyle(WorkspacePalette.primaryText)
        .background(WorkspacePalette.canvas)
    }

    @MainActor
    private func render<V: View>(_ view: V, name: String, to destination: URL, defaults: UserDefaults, language: AppLanguage, width: CGFloat, height: CGFloat) async throws -> [String: Any] {
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

@MainActor
private final class WorkflowNotificationFixture: MeetingNotificationScheduling {
    var authorizationRequests = 0
    private var plans: [String: String] = [:]
    func authorization() async -> MeetingNotificationAuthorization { .allowed }
    func requestAuthorization() async throws -> Bool { authorizationRequests += 1; return true }
    func prepare(language: AppLanguage) {}
    func pending() async -> [String: String] { plans }
    func delivered() async -> [MeetingDeliveredReminder] { [] }
    func removePending(_ identifiers: [String]) { identifiers.forEach { plans.removeValue(forKey: $0) } }
    func removeDelivered(_ identifiers: [String]) {}
    func add(_ plan: MeetingReminderPlan, language: AppLanguage) async throws { plans[plan.identifier] = plan.fingerprint }
}

@MainActor
private final class WorkflowHotKeyFixture: MeetingHotKeyRegistering {
    func register(letter: String, modifiers: MeetingHotKeyModifiers, action: @escaping @MainActor () -> Void) -> Bool { true }
    func unregister() {}
}
