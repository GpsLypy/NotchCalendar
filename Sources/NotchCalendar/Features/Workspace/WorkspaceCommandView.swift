import SwiftUI

struct WorkspaceCommandView: View {
    let commands: [WorkspaceCommand]
    let perform: (WorkspaceCommand.Action) -> Void
    @Environment(\.appLanguage) private var appLanguage
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var selection: String?
    @FocusState private var searchFocused: Bool

    private var results: [WorkspaceCommand] { WorkspaceCommandCatalog.matching(query, in: commands) }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass").foregroundStyle(WorkspacePalette.accent)
                TextField(t("Search pages and today's events"), text: $query)
                    .textFieldStyle(.plain)
                    .font(.system(size: 17))
                    .focused($searchFocused)
                    .onSubmit { executeSelection() }
                    .onKeyPress(.downArrow) { moveSelection(1); return .handled }
                    .onKeyPress(.upArrow) { moveSelection(-1); return .handled }
                Button { dismiss() } label: {
                    Text("esc").font(.system(size: 10, design: .monospaced))
                        .padding(5).background(WorkspacePalette.hover, in: RoundedRectangle(cornerRadius: 5))
                }
                .buttonStyle(.plain).keyboardShortcut(.cancelAction)
                .accessibilityLabel(t("Close"))
            }
            .padding(22)
            Divider().overlay(WorkspacePalette.stroke)
            if results.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "magnifyingglass").font(.system(size: 28))
                    Text(t("No matching pages or events")).font(.headline)
                    Text(t("Try a page name, event title, or calendar name."))
                        .font(.callout).foregroundStyle(WorkspacePalette.secondaryText)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 4) {
                            ForEach(results) { command in
                                Button { execute(command) } label: { row(command) }
                                    .buttonStyle(.plain)
                                    .id(command.id)
                                    .accessibilityAddTraits(selection == command.id ? .isSelected : [])
                            }
                        }
                        .padding(12)
                    }
                    .onChange(of: selection) { _, id in
                        if let id { proxy.scrollTo(id, anchor: nil) }
                    }
                }
            }
            Divider().overlay(WorkspacePalette.stroke)
            HStack {
                Text(t("↑ ↓ to move · Return to open"))
                Spacer()
                Text(t("On this Mac"))
            }
            .font(.system(size: 10, weight: .medium))
            .foregroundStyle(WorkspacePalette.secondaryText)
            .padding(.horizontal, 22).padding(.vertical, 13)
        }
        .frame(width: 580, height: 460)
        .foregroundStyle(WorkspacePalette.primaryText)
        .background(WorkspacePalette.canvas)
        .onAppear { searchFocused = true; selection = results.first?.id }
        .onChange(of: query) { _, _ in selection = results.first?.id }
        .onChange(of: commands.map(\.id)) { _, _ in
            if !results.contains(where: { $0.id == selection }) { selection = results.first?.id }
        }
    }

    private func row(_ command: WorkspaceCommand) -> some View {
        HStack(spacing: 12) {
            Image(systemName: command.symbol)
                .font(.system(size: 16)).foregroundStyle(WorkspacePalette.accent)
                .frame(width: 30)
            VStack(alignment: .leading, spacing: 3) {
                Text(command.title).font(.system(size: 13, weight: .medium)).lineLimit(1)
                Text(command.detail).font(.system(size: 10)).foregroundStyle(WorkspacePalette.secondaryText).lineLimit(1)
            }
            Spacer()
            if selection == command.id {
                Image(systemName: "return").font(.system(size: 11)).foregroundStyle(WorkspacePalette.accent)
            }
        }
        .padding(11)
        .background(selection == command.id ? WorkspacePalette.elevated : .clear, in: RoundedRectangle(cornerRadius: 9))
        .contentShape(Rectangle())
    }

    private func moveSelection(_ delta: Int) {
        guard !results.isEmpty else { return }
        let index = results.firstIndex { $0.id == selection } ?? 0
        selection = results[min(results.count - 1, max(0, index + delta))].id
    }
    private func executeSelection() {
        guard let command = results.first(where: { $0.id == selection }) else { return }
        execute(command)
    }
    private func execute(_ command: WorkspaceCommand) { perform(command.action); dismiss() }
    private func t(_ key: String) -> String { L10n.string(key, language: appLanguage) }
}
