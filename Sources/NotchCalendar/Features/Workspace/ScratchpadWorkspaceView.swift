import AppKit
import SwiftUI

struct ScratchpadWorkspaceView: View {
    private static let noteStorageKey = "workspace.scratchpad.text"

    // Keep the editor bound to local view state. Binding NSTextView directly to
    // AppStorage writes marked text back through UserDefaults during every IME
    // composition update, which can cancel Chinese/Japanese input before commit.
    @State private var noteText: String
    @State private var copied = false
    @State private var isConfirmingClear = false
    @FocusState private var editorIsFocused: Bool
    @Environment(\.appLanguage) private var appLanguage

    init() {
        _noteText = State(
            initialValue: UserDefaults.standard.string(forKey: Self.noteStorageKey) ?? ""
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            pageHeader

            WorkspaceCard {
                ZStack(alignment: .topLeading) {
                    if noteText.isEmpty {
                        VStack(alignment: .leading, spacing: 7) {
                            Text(t("Write something to remember…"))
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundStyle(WorkspacePalette.secondaryText)
                            Text(t("A thought, a link, or the next small step."))
                                .font(.system(size: 11.5))
                                .foregroundStyle(WorkspacePalette.secondaryText.opacity(0.72))
                        }
                        .padding(.horizontal, 17)
                        .padding(.vertical, 18)
                        .allowsHitTesting(false)
                    }

                    TextEditor(text: $noteText)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .lineSpacing(5)
                        .foregroundStyle(WorkspacePalette.primaryText)
                        .scrollContentBackground(.hidden)
                        .padding(10)
                        .focused($editorIsFocused)
                        .accessibilityLabel(t("Scratchpad"))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }

            HStack {
                Label(t("Saved automatically on this Mac"), systemImage: "checkmark.circle")
                    .font(.system(size: 10.5, weight: .medium))
                    .foregroundStyle(WorkspacePalette.secondaryText)
                Spacer()
                Text(noteCount)
                    .font(.system(size: 10.5, weight: .medium, design: .monospaced))
                    .monospacedDigit()
                    .foregroundStyle(WorkspacePalette.secondaryText)
            }
        }
        .padding(.horizontal, 30)
        .padding(.top, 52)
        .padding(.bottom, 24)
        .background(WorkspacePalette.canvas)
        .onAppear { editorIsFocused = true }
        .onChange(of: noteText) { _, updatedText in
            copied = false
            UserDefaults.standard.set(updatedText, forKey: Self.noteStorageKey)
        }
        .alert(t("Clear the scratchpad?"), isPresented: $isConfirmingClear) {
            Button(t("Cancel"), role: .cancel) {}
            Button(t("Clear"), role: .destructive) { noteText = "" }
        } message: {
            Text(t("This removes the locally saved note and cannot be undone."))
        }
    }

    private var pageHeader: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .bottom, spacing: 16) {
                headerTitle
                    .fixedSize(horizontal: true, vertical: false)
                Spacer()
                headerActions
                    .fixedSize()
            }

            VStack(alignment: .leading, spacing: 12) {
                headerTitle
                HStack {
                    Spacer()
                    headerActions
                }
            }
        }
    }

    private var headerTitle: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(t("Scratchpad"))
                .font(.system(size: 27, weight: .bold, design: .rounded))
                .foregroundStyle(WorkspacePalette.primaryText)
            Text(t("A local, auto-saved place for whatever is in your head."))
                .font(.system(size: 12.5, weight: .medium))
                .foregroundStyle(WorkspacePalette.secondaryText)
        }
    }

    private var headerActions: some View {
        HStack(spacing: 8) {
            Button {
                insertTimestamp()
            } label: {
                Label(t("Add time"), systemImage: "clock.badge.plus")
            }
            .buttonStyle(.bordered)
            .keyboardShortcut("t", modifiers: [.command, .shift])

            Button {
                copyNote()
            } label: {
                Label(copied ? t("Copied") : t("Copy"), systemImage: copied ? "checkmark" : "doc.on.doc")
            }
            .buttonStyle(.bordered)
            .disabled(noteText.isEmpty)

            Button {
                isConfirmingClear = true
            } label: {
                Image(systemName: "trash")
            }
            .buttonStyle(.bordered)
            .disabled(noteText.isEmpty)
            .accessibilityLabel(t("Clear scratchpad"))
            .help(t("Clear scratchpad"))
        }
    }

    private var noteCount: String {
        let words = noteText.split(whereSeparator: { $0.isWhitespace }).count
        let characters = noteText.count
        return t("%@ words · %@ characters", "\(words)", "\(characters)")
    }

    private func insertTimestamp() {
        let stamp = Date().formatted(
            .dateTime.month(.abbreviated).day().hour().minute().locale(appLanguage.locale)
        )
        let separator = noteText.isEmpty || noteText.hasSuffix("\n") ? "" : "\n"
        noteText += "\(separator)• \(stamp) — "
        editorIsFocused = true
    }

    private func copyNote() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        copied = pasteboard.setString(noteText, forType: .string)
    }

    private func t(_ key: String, _ arguments: CVarArg...) -> String {
        L10n.string(key, language: appLanguage, arguments: arguments)
    }
}
