import AppKit
import SwiftUI
import XCTest
@testable import NotchCalendar

/// Opt-in, offline native rendering. All calendar and timer records below are
/// disposable fixtures; this never reads the user's calendars or preferences.
final class PlanningCaptureTests: XCTestCase {
    @MainActor
    func testRenderPlanningAndFocus() async throws {
        guard let path = ProcessInfo.processInfo.environment["NOTCH_PLANNING_CAPTURE_PATH"] else {
            throw XCTSkip("Set NOTCH_PLANNING_CAPTURE_PATH for offline native layout review.")
        }
        let destination = URL(fileURLWithPath: path, isDirectory: true)
        try FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true)
        let suite = "PlanningCapture.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let day = Calendar.current.startOfDay(for: Date())
        func time(_ hour: Int, _ minute: Int = 0) -> Date {
            Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: day)!
        }
        let now = time(9, 35)
        func event(_ id: String, _ title: String, _ start: Date, _ end: Date) -> CalendarEvent {
            CalendarEvent(id: id, title: title, startDate: start, endDate: end, calendarName: "演示 · Work", calendarColor: .systemPink, location: nil, meetingLink: nil, isAllDay: false)
        }
        let events = [
            event("review", "产品评审 / Product review", time(10), time(11)),
            event("design", "设计同步 / Design sync", time(10, 30), time(11, 30)),
            event("planning", "下周计划 / Next week", time(14), time(15))
        ]
        let provider = CalendarSelectionTestDataSource(eventsByCalendarID: ["work": events])
        let manager = CalendarManager(dataSource: provider, defaults: defaults)
        manager.refresh(now: now)
        let timer = FocusTimerModel(defaults: defaults, now: now)
        _ = timer.prepareFocus(minutes: 25)
        timer.toggle(now: time(8))
        timer.synchronize(now: time(8, 25))
        _ = timer.prepareFocus(minutes: 20)

        for language: AppLanguage in [.simplifiedChinese, .english] {
            for width: CGFloat in [647, 980] {
                let suffix = "\(language.rawValue)-\(Int(width))"
                let planning = DayPlanningCard(events: events, now: now, sourceAvailability: .available, focusTimer: timer, openFocus: {}, openCalendar: {})
                    .padding(30)
                    .background(WorkspacePalette.canvas)
                try await render(planning, name: "planning-\(suffix)", to: destination, defaults: defaults, language: language, width: width, height: 620)
                try await render(FocusWorkspaceView(timer: timer, calendar: manager, now: now), name: "focus-\(suffix)", to: destination, defaults: defaults, language: language, width: width, height: 1000)
            }
        }
        try await render(
            DayPlanningCard(events: [], now: now, sourceAvailability: .noneSelected, focusTimer: timer, openFocus: {}, openCalendar: {}).padding(30).background(WorkspacePalette.canvas),
            name: "planning-hidden-calendars", to: destination, defaults: defaults, language: .simplifiedChinese, width: 647, height: 360
        )
        try await render(
            SettingsView(updateChecker: UpdateChecker(), presentationPreferences: PresentationPreferences(defaults: defaults), calendar: manager),
            name: "calendar-settings", to: destination, defaults: defaults, language: .simplifiedChinese, width: 540, height: 620
        )
        XCTAssertEqual(provider.accessRequestCount, 0)
        try "Offline native SwiftUI rendering with synthetic calendar and timer fixtures, isolated preferences, no real Calendar access. These images verify layout, not physical mouse interaction or live account sync.".write(to: destination.appendingPathComponent("provenance.txt"), atomically: true, encoding: .utf8)
    }

    @MainActor
    private func render<V: View>(_ view: V, name: String, to destination: URL, defaults: UserDefaults, language: AppLanguage, width: CGFloat, height: CGFloat) async throws {
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
        try await Task.sleep(for: .milliseconds(350))
        hosting.layoutSubtreeIfNeeded()
        let bitmap = try XCTUnwrap(hosting.bitmapImageRepForCachingDisplay(in: rect))
        hosting.cacheDisplay(in: rect, to: bitmap)
        let png = try XCTUnwrap(bitmap.representation(using: .png, properties: [:]))
        try png.write(to: destination.appendingPathComponent(name + ".png"), options: .atomic)
    }
}
