import AppKit
import SwiftUI

/// Publish committed text only; never rewrite an NSTextView's marked IME range.
struct CompositionSafeTextEditor: NSViewRepresentable {
    @Binding var text: String
    var label: String
    @Environment(\.isEnabled) private var isEnabled

    func makeCoordinator() -> Coordinator { Coordinator(text: $text) }

    func makeNSView(context: Context) -> NSScrollView {
        let scroll = NSTextView.scrollableTextView()
        scroll.drawsBackground = false
        let editor = scroll.documentView as! NSTextView
        editor.drawsBackground = false
        editor.isRichText = false
        editor.isEditable = isEnabled
        editor.isAutomaticQuoteSubstitutionEnabled = false
        editor.isAutomaticDashSubstitutionEnabled = false
        editor.allowsUndo = true
        editor.font = .systemFont(ofSize: 14)
        editor.textColor = .labelColor
        editor.insertionPointColor = .labelColor
        editor.textContainerInset = NSSize(width: 12, height: 12)
        editor.setAccessibilityLabel(label)
        editor.string = text
        editor.delegate = context.coordinator
        context.coordinator.lastAppliedText = text
        return scroll
    }

    func updateNSView(_ scroll: NSScrollView, context: Context) {
        let editor = scroll.documentView as! NSTextView
        context.coordinator.text = $text
        editor.isEditable = isEnabled
        editor.setAccessibilityLabel(label)
        guard editor.string != text else { return }
        if editor.hasMarkedText() {
            context.coordinator.pendingExternalText = text
            return
        }
        let selection = editor.selectedRange()
        editor.string = text
        editor.setSelectedRange(NSRange(location: min(selection.location, (text as NSString).length), length: 0))
        context.coordinator.lastAppliedText = text
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
        var text: Binding<String>
        var lastAppliedText = ""
        var pendingExternalText: String?
        init(text: Binding<String>) { self.text = text }

        func textDidChange(_ notification: Notification) {
            guard let editor = notification.object as? NSTextView, !editor.hasMarkedText() else { return }
            var committed = editor.string
            if let pending = pendingExternalText {
                // A Shortcut append during composition must not discard either the new line or the IME commit.
                if pending.hasPrefix(lastAppliedText) {
                    committed += pending.dropFirst(lastAppliedText.count)
                } else { committed = pending }
                pendingExternalText = nil
                editor.string = committed
            }
            lastAppliedText = committed
            text.wrappedValue = committed
        }
    }
}
