import AppKit
import SwiftUI

struct FileShelfView: View {
    @ObservedObject var store: FileShelfStore
    @Environment(\.appLanguage) private var appLanguage

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            Divider().overlay(.white.opacity(0.08))
            content
        }
        .frame(maxWidth: .infinity, minHeight: 340, maxHeight: 340)
    }

    private var toolbar: some View {
        HStack(spacing: 8) {
            Button { store.navigateUp() } label: {
                Image(systemName: "chevron.left")
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
            .disabled(!store.canNavigateUp)
            .help(t("Back"))

            Image(systemName: "folder.fill")
                .foregroundStyle(WorkspacePalette.accent)
            Text(store.currentURL?.lastPathComponent ?? t("No Folder"))
                .font(.system(size: 13, weight: .semibold))
                .lineLimit(1)
                .truncationMode(.middle)

            Spacer(minLength: 8)

            Button { store.refresh() } label: {
                Image(systemName: "arrow.clockwise")
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
            .disabled(store.currentURL == nil || store.isLoading)
            .help(t("Refresh"))

            if let currentURL = store.currentURL {
                Button { store.reveal(currentURL) } label: {
                    Image(systemName: "folder.badge.gearshape")
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
                .help(t("Show in Finder"))
            }
        }
        .foregroundStyle(WorkspacePalette.secondaryText)
        .padding(.horizontal, 28)
        .frame(height: 42)
    }

    @ViewBuilder private var content: some View {
        if store.rootURL == nil {
            unavailableContent(
                symbol: "folder.badge.plus",
                title: t("Choose a folder for quick access"),
                detail: t("Files stay in their original folder on this Mac."),
                actionTitle: t("Choose Folder"),
                action: store.chooseRootDirectory
            )
        } else if store.isLoading && store.items.isEmpty {
            VStack(spacing: 10) {
                ProgressView().controlSize(.small)
                Text(t("Loading files…"))
                    .font(.system(size: 12))
                    .foregroundStyle(WorkspacePalette.secondaryText)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let errorMessageKey = store.errorMessageKey {
            unavailableContent(
                symbol: "exclamationmark.folder",
                title: t(errorMessageKey),
                detail: t("Choose the folder again if it was moved or disconnected."),
                actionTitle: t("Choose Folder"),
                action: store.chooseRootDirectory
            )
        } else if store.items.isEmpty {
            unavailableContent(
                symbol: "folder",
                title: t("This folder is empty"),
                detail: t("New files will appear here automatically."),
                actionTitle: nil,
                action: nil
            )
        } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(store.items) { item in
                        FileShelfRow(item: item, store: store)
                        Divider()
                            .overlay(.white.opacity(0.06))
                            .padding(.leading, 66)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private func unavailableContent(
        symbol: String,
        title: String,
        detail: String,
        actionTitle: String?,
        action: (() -> Void)?
    ) -> some View {
        VStack(spacing: 8) {
            Image(systemName: symbol)
                .font(.system(size: 28, weight: .light))
                .foregroundStyle(WorkspacePalette.secondaryText)
            Text(title).font(.system(size: 14, weight: .semibold))
            Text(detail)
                .font(.system(size: 11))
                .foregroundStyle(WorkspacePalette.secondaryText)
                .multilineTextAlignment(.center)
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .padding(.top, 5)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 40)
    }

    private func t(_ key: String) -> String {
        L10n.string(key, language: appLanguage)
    }
}

private struct FileShelfRow: View {
    let item: FileShelfItem
    @ObservedObject var store: FileShelfStore
    @Environment(\.appLanguage) private var appLanguage
    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 12) {
            Image(nsImage: icon)
                .resizable()
                .interpolation(.high)
                .frame(width: 30, height: 30)
            VStack(alignment: .leading, spacing: 3) {
                Text(item.name)
                    .font(.system(size: 12.5, weight: .medium))
                    .lineLimit(1)
                    .truncationMode(.middle)
                Text(metadata)
                    .font(.system(size: 10.5))
                    .foregroundStyle(WorkspacePalette.secondaryText)
                    .lineLimit(1)
            }
            Spacer(minLength: 8)
            if item.isDirectory {
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(WorkspacePalette.secondaryText)
            }
        }
        .padding(.horizontal, 8)
        .frame(height: 50)
        .contentShape(Rectangle())
        .background(isHovering ? Color.white.opacity(0.06) : .clear)
        .onHover { isHovering = $0 }
        .onTapGesture(count: 2) { store.open(item) }
        .draggable(item.url)
        .contextMenu {
            Button(item.isDirectory ? t("Open Folder") : t("Open")) { store.open(item) }
            Button(t("Show in Finder")) { store.reveal(item.url) }
            Button(t("Copy Path")) { store.copyPath(item.url) }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAction(named: Text(item.isDirectory ? t("Open Folder") : t("Open"))) {
            store.open(item)
        }
    }

    private var icon: NSImage {
        let image = NSWorkspace.shared.icon(forFile: item.url.path)
        image.size = NSSize(width: 30, height: 30)
        return image
    }

    private var metadata: String {
        var parts: [String] = []
        if item.isDirectory {
            parts.append(t("Folder"))
        } else if let fileSize = item.fileSize {
            parts.append(ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file))
        }
        if let date = item.modificationDate {
            parts.append(date.formatted(.dateTime.month(.abbreviated).day().hour().minute().locale(appLanguage.locale)))
        }
        return parts.joined(separator: " · ")
    }

    private func t(_ key: String) -> String {
        L10n.string(key, language: appLanguage)
    }
}
