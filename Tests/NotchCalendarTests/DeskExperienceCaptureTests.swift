import AppKit
import SwiftUI
import XCTest
@testable import NotchCalendar

/// Opt-in native view review, using disposable preferences and synthetic events.
final class DeskExperienceCaptureTests: XCTestCase {
    @MainActor
    func testKeyboardOpensSearchAndNavigates() async throws {
        guard ProcessInfo.processInfo.environment["NOTCH_DESK_INTERACTION"] == "1" else {
            throw XCTSkip("Set NOTCH_DESK_INTERACTION=1 for a temporary native window keyboard check.")
        }
        let suite = "DeskInteraction.\(UUID())"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let event = CalendarSelectionTestDataSource.event(id: "Keyboard meeting", start: Date(), end: Date().addingTimeInterval(600))
        let manager = CalendarManager(dataSource: CalendarSelectionTestDataSource(eventsByCalendarID: ["work": [event]]), defaults: defaults)
        let timer = FocusTimerModel(defaults: defaults)
        let presentation = MainCalendarPresentation()
        let root = MainWorkspaceView(calendar: manager, focusTimer: timer, updateChecker: UpdateChecker(), presentation: presentation, notesStore: MeetingNotesStore(defaults: defaults))
            .defaultAppStorage(defaults).environment(\.appLanguage, .simplifiedChinese)
        let window = NSWindow(contentRect: NSRect(x: 100, y: 100, width: 980, height: 720), styleMask: [.titled, .closable], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.contentView = NSHostingView(rootView: root)
        window.makeKeyAndOrderFront(nil)
        defer { window.orderOut(nil); window.close() }
        try await Task.sleep(for: .milliseconds(300))
        func key(_ characters: String, code: UInt16, modifiers: NSEvent.ModifierFlags = [], target: NSWindow) throws {
            let event = try XCTUnwrap(NSEvent.keyEvent(with: .keyDown, location: .zero, modifierFlags: modifiers, timestamp: 0, windowNumber: target.windowNumber, context: nil, characters: characters, charactersIgnoringModifiers: characters, isARepeat: false, keyCode: code))
            if modifiers.contains(.command) {
                XCTAssertTrue(target.performKeyEquivalent(with: event))
            } else { target.sendEvent(event) }
        }
        try key("k", code: 40, modifiers: .command, target: window)
        try await Task.sleep(for: .milliseconds(450))
        let sheet = try XCTUnwrap(window.attachedSheet)
        let editor = try XCTUnwrap(sheet.firstResponder as? NSTextView)
        editor.insertText("专注", replacementRange: NSRange(location: NSNotFound, length: 0))
        try await Task.sleep(for: .milliseconds(150))
        try key("\r", code: 36, target: sheet)
        try await Task.sleep(for: .milliseconds(450))
        XCTAssertEqual(presentation.selectedDestination, .focus)
        XCTAssertNil(window.attachedSheet)
        // Reopening must reset the query and keep arrow-key navigation working.
        try key("k", code: 40, modifiers: .command, target: window)
        try await Task.sleep(for: .milliseconds(450))
        let second = try XCTUnwrap(window.attachedSheet)
        try key(String(UnicodeScalar(NSDownArrowFunctionKey)!), code: 125, target: second)
        try key("\r", code: 36, target: second)
        try await Task.sleep(for: .milliseconds(450))
        XCTAssertEqual(presentation.selectedDestination, .calendar)
        XCTAssertNil(window.attachedSheet)
        timer.toggle()
        for (query, expectedRunning) in [("暂停", false), ("继续", true)] {
            try key("k", code: 40, modifiers: .command, target: window)
            try await Task.sleep(for: .milliseconds(450))
            let commandSheet = try XCTUnwrap(window.attachedSheet)
            let field = try XCTUnwrap(commandSheet.firstResponder as? NSTextView)
            field.insertText(query, replacementRange: NSRange(location: NSNotFound, length: 0))
            try await Task.sleep(for: .milliseconds(150))
            try key("\r", code: 36, target: commandSheet)
            try await Task.sleep(for: .milliseconds(450))
            XCTAssertEqual(timer.isRunning, expectedRunning)
            XCTAssertTrue(timer.hasUnfinishedSession)
        }
        try key("k", code: 40, modifiers: .command, target: window)
        try await Task.sleep(for: .milliseconds(450))
        let commandSheet = try XCTUnwrap(window.attachedSheet)
        let field = try XCTUnwrap(commandSheet.firstResponder as? NSTextView)
        field.insertText("Keyboard meeting", replacementRange: NSRange(location: NSNotFound, length: 0))
        try await Task.sleep(for: .milliseconds(150))
        try key("\r", code: 36, target: commandSheet)
        try await Task.sleep(for: .milliseconds(650))
        let noteSheet = try XCTUnwrap(window.attachedSheet, "The command should hand off to meeting notes after dismissing")
        XCTAssertFalse(noteSheet === commandSheet)
        try key(String(UnicodeScalar(27)!), code: 53, target: noteSheet)
        try await Task.sleep(for: .milliseconds(450))
        XCTAssertNil(window.attachedSheet)
    }

    @MainActor
    func testRenderDeskAndActivities() async throws {
        guard let path = ProcessInfo.processInfo.environment["NOTCH_DESK_CAPTURE_PATH"] else {
            throw XCTSkip("Set NOTCH_DESK_CAPTURE_PATH for offline native experience review.")
        }
        let destination = URL(fileURLWithPath: path, isDirectory: true)
        try FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true)
        let suite = "DeskCapture.\(UUID())"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        defaults.set(0, forKey: DayPlanSettings.startHourKey)
        defaults.set(24, forKey: DayPlanSettings.endHourKey)
        let now = Date()
        let start = Calendar.current.startOfDay(for: now)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start)!
        let duration = end.timeIntervalSince(start)
        func event(_ id: String, _ title: String, _ from: Double, _ to: Double) -> CalendarEvent {
            CalendarEvent(id: id, title: title, startDate: start.addingTimeInterval(duration * from), endDate: start.addingTimeInterval(duration * to), calendarName: "演示 · Studio", calendarColor: .systemPink, location: "Studio", meetingLink: nil, isAllDay: false)
        }
        let events = [
            event("morning", "产品评审 · Product review", 0.38, 0.48),
            event("design", "设计同步 · Design sync", 0.43, 0.52),
            event("craft", "开发与打磨 · Craft", 0.60, 0.74),
            event("next", "开源交流 · Open source", 0.90, 0.97)
        ]
        let provider = CalendarSelectionTestDataSource(eventsByCalendarID: ["work": events])
        let calendar = CalendarManager(dataSource: provider, defaults: defaults)
        calendar.refresh(now: now)
        let timer = FocusTimerModel(defaults: defaults, now: now)
        timer.setTaskLabel("打磨时间轨道 · Refine the day track")
        timer.toggle(now: now.addingTimeInterval(-420))
        timer.synchronize(now: now)
        let notes = MeetingNotesStore(defaults: defaults)
        let preferences = PresentationPreferences(defaults: defaults)
        try await render(NotchExpandedActivityView(calendar: calendar, focusTimer: timer, preferences: preferences, selectedDate: .constant(now), contentTopInset: 44, onClose: {}, openFocus: {}).frame(maxHeight: .infinity, alignment: .top),
                         name: "expanded-focus", to: destination, defaults: defaults, language: .simplifiedChinese, width: 600, height: 460)
        preferences.showsFocusStatus = false
        try await render(NotchExpandedActivityView(calendar: calendar, focusTimer: timer, preferences: preferences, selectedDate: .constant(now), contentTopInset: 44, onClose: {}, openFocus: {}).frame(maxHeight: .infinity, alignment: .top),
                         name: "expanded-calendar", to: destination, defaults: defaults, language: .simplifiedChinese, width: 600, height: 460)
        for language: AppLanguage in [.simplifiedChinese, .english] {
            let suffix = language.rawValue
            for (width, height): (CGFloat, CGFloat) in [(1120, 780), (860, 620)] {
                for page in [WorkspaceDestination.calendar, .today, .focus] {
                    let presentation = MainCalendarPresentation()
                    presentation.selectedDestination = page
                    presentation.isActive = true
                    try await render(MainWorkspaceView(calendar: calendar, focusTimer: timer, updateChecker: UpdateChecker(), presentation: presentation, notesStore: notes),
                                     name: "desk-\(page.rawValue)-\(suffix)-\(Int(width))", to: destination, defaults: defaults, language: language, width: width, height: height)
                }
            }
            let august = Calendar.current.date(from: DateComponents(year: 2026, month: 8, day: 31))!
            let compactPresentation = MainCalendarPresentation()
            compactPresentation.isActive = true
            try await render(MainCalendarView(calendar: calendar, presentation: compactPresentation, selectedDate: .constant(august)),
                             name: "six-row-month-\(suffix)", to: destination, defaults: defaults, language: language, width: 747, height: 520)
            let commands = WorkspaceCommandCatalog.commands(events: events, language: language, hasSession: true, isRunning: true)
            try await render(WorkspaceCommandView(commands: commands, perform: { _ in }), name: "commands-\(suffix)", to: destination, defaults: defaults, language: language, width: 580, height: 460)
            try await render(WorkspaceCommandView(commands: [], perform: { _ in }), name: "commands-empty-\(suffix)", to: destination, defaults: defaults, language: language, width: 580, height: 460)
            try await render(FocusNotchView(timer: timer, events: events, openFocus: {}), name: "notch-focus-\(suffix)", to: destination, defaults: defaults, language: language, width: 600, height: 270)
        }
        try await render(FocusCompactNotchView(timer: timer, notchWidth: 180, notchDepth: 32), name: "compact-notched", to: destination, defaults: defaults, language: .simplifiedChinese, width: 320, height: 32)
        try await render(FocusCompactNotchView(timer: timer, notchWidth: nil, notchDepth: nil), name: "compact-external", to: destination, defaults: defaults, language: .english, width: 226, height: 30)
        timer.toggle()
        try await render(FocusNotchView(timer: timer, events: [], openFocus: {}), name: "notch-paused", to: destination, defaults: defaults, language: .simplifiedChinese, width: 600, height: 240)
        let dense = (0..<8).map { event("dense-\($0)", "Overlap \($0)", 0.4, 0.8) }
        try await render(DayTimelineView(events: dense, now: now, window: DayPlanInterval(start: start, end: end)).padding(22).background(WorkspacePalette.canvas),
                         name: "track-dense", to: destination, defaults: defaults, language: .english, width: 500, height: 270)
        calendar.setCalendarSelected("work", isSelected: false)
        try await render(TodayWorkspaceView(calendar: calendar, focusTimer: timer, isActive: false, navigate: { _ in }),
                         name: "today-hidden-sources", to: destination, defaults: defaults, language: .simplifiedChinese, width: 647, height: 800)
        XCTAssertEqual(provider.accessRequestCount, 0)
        try "Native SwiftUI views; synthetic calendar events, isolated local preferences, no Calendar permission requests or real event writes. Captures verify appearance, not physical notch, focus routing, or real account behavior.".write(to: destination.appendingPathComponent("provenance.txt"), atomically: true, encoding: .utf8)
    }

    @MainActor
    private func render<V: View>(_ view: V, name: String, to destination: URL, defaults: UserDefaults, language: AppLanguage, width: CGFloat, height: CGFloat) async throws {
        let content = view.defaultAppStorage(defaults)
            .environment(\.appLanguage, language).environment(\.locale, language.locale)
            .environment(\.colorScheme, .dark).preferredColorScheme(.dark)
            .frame(width: width, height: height)
        let hosting = NSHostingView(rootView: content)
        let rect = NSRect(x: 0, y: 0, width: width, height: height)
        let window = NSWindow(contentRect: rect, styleMask: [.borderless], backing: .buffered, defer: false)
        window.appearance = NSAppearance(named: .darkAqua)
        window.contentView = hosting
        hosting.frame = rect
        try await Task.sleep(for: .milliseconds(350))
        hosting.layoutSubtreeIfNeeded()
        let bitmap = try XCTUnwrap(hosting.bitmapImageRepForCachingDisplay(in: rect))
        hosting.cacheDisplay(in: rect, to: bitmap)
        try XCTUnwrap(bitmap.representation(using: .png, properties: [:])).write(to: destination.appendingPathComponent(name + ".png"), options: .atomic)
    }
}
