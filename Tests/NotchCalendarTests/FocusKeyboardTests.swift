import AppKit
import SwiftUI
import XCTest
@testable import NotchCalendar

final class FocusKeyboardTests: XCTestCase {
    @MainActor
    func testTypingSpaceInTaskLabelDoesNotControlTimer() async throws {
        guard ProcessInfo.processInfo.environment["NOTCH_DESK_INTERACTION"] == "1" else {
            throw XCTSkip("Set NOTCH_DESK_INTERACTION=1 for an isolated native text-editing check")
        }
        let suite = "FocusKeyboard.\(UUID())"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let calendar = CalendarManager(dataSource: CalendarSelectionTestDataSource(eventsByCalendarID: [:]), defaults: defaults)
        let timer = FocusTimerModel(defaults: defaults)
        timer.setTaskLabel("Write")
        timer.toggle()
        let window = NSWindow(contentRect: NSRect(x: 100, y: 100, width: 860, height: 700), styleMask: [.titled, .closable], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.contentView = NSHostingView(rootView: FocusWorkspaceView(timer: timer, calendar: calendar, now: Date())
            .defaultAppStorage(defaults).environment(\.appLanguage, .english))
        window.makeKeyAndOrderFront(nil)
        defer { window.orderOut(nil); window.close() }
        try await Task.sleep(for: .milliseconds(400))
        func descendants(_ view: NSView) -> [NSView] { [view] + view.subviews.flatMap(descendants) }
        let input = try XCTUnwrap(descendants(try XCTUnwrap(window.contentView)).compactMap { $0 as? NSTextField }.first { $0.stringValue == "Write" })
        XCTAssertTrue(window.makeFirstResponder(input))
        try await Task.sleep(for: .milliseconds(200))
        let editor = try XCTUnwrap(input.currentEditor() as? NSTextView)
        editor.setSelectedRange(NSRange(location: 5, length: 0))
        let space = try XCTUnwrap(NSEvent.keyEvent(with: .keyDown, location: .zero, modifierFlags: [], timestamp: 0, windowNumber: window.windowNumber, context: nil, characters: " ", charactersIgnoringModifiers: " ", isARepeat: false, keyCode: 49))
        XCTAssertFalse(window.performKeyEquivalent(with: space), "Text editing must suspend the timer's Space shortcut")
        window.sendEvent(space)
        editor.insertText("proposal", replacementRange: NSRange(location: NSNotFound, length: 0))
        try await Task.sleep(for: .milliseconds(200))
        XCTAssertTrue(timer.isRunning)
        XCTAssertEqual(timer.taskLabel, "Write proposal")
        XCTAssertTrue(window.makeFirstResponder(nil))
        try await Task.sleep(for: .milliseconds(200))
        XCTAssertTrue(window.performKeyEquivalent(with: space), "Space should resume controlling the timer after leaving the editor")
        try await Task.sleep(for: .milliseconds(100))
        XCTAssertFalse(timer.isRunning)
    }
}
