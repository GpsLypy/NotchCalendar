import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct FileShelfView: View {
    @ObservedObject var store: FileShelfStore
    @Environment(\.appLanguage) private var appLanguage
    @State private var selectedItemURL: URL?

    private var selectedItem: FileShelfItem? {
        guard let selectedItemURL else { return nil }
        return store.visibleItems.first(where: { $0.item.url == selectedItemURL })?.item
    }

    var body: some View {
        HStack(spacing: 0) {
            sidebar
            Divider().overlay(.white.opacity(0.10))
            VStack(spacing: 0) {
                toolbar
                Divider().overlay(.white.opacity(0.10))
                columnHeader
                Divider().overlay(.white.opacity(0.08))
                content
            }
        }
        .frame(maxWidth: .infinity, minHeight: 340, maxHeight: 340)
        .onChange(of: store.selectedLocationID) { _, _ in selectedItemURL = nil }
        .onChange(of: store.currentURL) { _, _ in selectedItemURL = nil }
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(t("Favorites"))
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(WorkspacePalette.secondaryText)
                .padding(.horizontal, 12)
                .padding(.top, 12)
                .padding(.bottom, 6)

            ScrollView {
                LazyVStack(spacing: 2) {
                    ForEach(store.locations) { location in
                        Button { store.selectLocation(location.id) } label: {
                            HStack(spacing: 7) {
                                Image(systemName: "folder.fill")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.blue)
                                    .frame(width: 17)
                                Text(location.name)
                                    .font(.system(size: 11.5, weight: .medium))
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                Spacer(minLength: 0)
                            }
                            .padding(.horizontal, 8)
                            .frame(height: 28)
                            .contentShape(Rectangle())
                            .background(
                                store.selectedLocationID == location.id
                                    ? Color.white.opacity(0.12)
                                    : .clear,
                                in: RoundedRectangle(cornerRadius: 5)
                            )
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button(t("Show in Finder")) { store.reveal(location.url) }
                            Button(t("Remove"), role: .destructive) { store.removeLocation(location.id) }
                        }
                    }
                }
                .padding(.horizontal, 6)
            }

            Divider().overlay(.white.opacity(0.08))
            Button { store.chooseRootDirectories() } label: {
                Label(t("Add Folders"), systemImage: "plus")
                    .font(.system(size: 10.5, weight: .medium))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .frame(height: 31)
            }
            .buttonStyle(.plain)
            .foregroundStyle(WorkspacePalette.secondaryText)
            .disabled(store.locations.count >= FileShelfStore.maximumLocations)
        }
        .frame(width: 148)
        .background(Color.white.opacity(0.035))
    }

    private var toolbar: some View {
        HStack(spacing: 5) {
            Button { store.navigateBack() } label: {
                Image(systemName: "chevron.left").frame(width: 22, height: 22)
            }
            .disabled(!store.canNavigateBack)
            .help(t("Back"))

            Button { store.navigateForward() } label: {
                Image(systemName: "chevron.right").frame(width: 22, height: 22)
            }
            .disabled(!store.canNavigateForward)
            .help(t("Forward"))

            Text(store.currentURL?.lastPathComponent ?? t("No Folder"))
                .font(.system(size: 12.5, weight: .semibold))
                .lineLimit(1)
                .truncationMode(.middle)
                .padding(.leading, 5)

            Spacer(minLength: 6)

            Button {
                if let selectedItem { store.open(selectedItem) }
            } label: {
                Image(systemName: "arrow.up.forward.app").frame(width: 22, height: 22)
            }
            .disabled(selectedItem == nil)
            .keyboardShortcut(.return, modifiers: [])
            .help(t("Open"))

            Button {
                if let selectedItem { store.copyFile(selectedItem) }
            } label: {
                Image(systemName: "doc.on.doc").frame(width: 22, height: 22)
            }
            .disabled(selectedItem == nil)
            .keyboardShortcut("c", modifiers: .command)
            .help(t("Copy"))

            Button { store.refresh() } label: {
                Image(systemName: "arrow.clockwise").frame(width: 22, height: 22)
            }
            .disabled(store.currentURL == nil || store.isLoading)
            .help(t("Refresh"))

            Button {
                if let url = selectedItem?.url ?? store.currentURL { store.reveal(url) }
            } label: {
                Image(systemName: "magnifyingglass").frame(width: 22, height: 22)
            }
            .disabled(selectedItem == nil && store.currentURL == nil)
            .help(t("Show in Finder"))
        }
        .buttonStyle(.plain)
        .foregroundStyle(WorkspacePalette.secondaryText)
        .padding(.horizontal, 10)
        .frame(height: 40)
    }

    private var columnHeader: some View {
        HStack(spacing: 0) {
            sortHeader("Name", sort: .name)
                .frame(maxWidth: .infinity, alignment: .leading)
            sortHeader("Date Modified", sort: .modified)
                .frame(width: 105, alignment: .leading)
            Text(t("Size"))
                .frame(width: 58, alignment: .trailing)
            Text(t("Kind"))
                .frame(width: 72, alignment: .leading)
                .padding(.leading, 12)
        }
        .font(.system(size: 9.5, weight: .medium))
        .foregroundStyle(WorkspacePalette.secondaryText)
        .padding(.horizontal, 10)
        .frame(height: 24)
        .background(Color.white.opacity(0.025))
    }

    private func sortHeader(_ title: String, sort: FileShelfSort) -> some View {
        Button { store.sort = sort } label: {
            HStack(spacing: 3) {
                Text(t(title))
                if store.sort == sort {
                    Image(systemName: sort == .name ? "chevron.up" : "chevron.down")
                        .font(.system(size: 7, weight: .bold))
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder private var content: some View {
        if store.locations.isEmpty {
            unavailableContent(
                symbol: "sidebar.left",
                title: t("Add folders to Favorites"),
                detail: t("Keep frequently used folders together in the notch."),
                actionTitle: t("Add Folders"),
                action: store.chooseRootDirectories
            )
        } else if store.isLoading && store.items.isEmpty {
            VStack(spacing: 8) {
                ProgressView().controlSize(.small)
                Text(t("Loading files…"))
                    .font(.system(size: 11))
                    .foregroundStyle(WorkspacePalette.secondaryText)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let errorMessageKey = store.errorMessageKey {
            unavailableContent(
                symbol: "exclamationmark.folder",
                title: t(errorMessageKey),
                detail: t("Remove this favorite or reconnect its disk."),
                actionTitle: nil,
                action: nil
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
                    ForEach(Array(store.visibleItems.enumerated()), id: \.element.id) { index, visible in
                        FileShelfTableRow(
                            visible: visible,
                            rowIndex: index,
                            store: store,
                            selection: $selectedItemURL
                        )
                    }
                }
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
        VStack(spacing: 7) {
            Image(systemName: symbol)
                .font(.system(size: 25, weight: .light))
                .foregroundStyle(WorkspacePalette.secondaryText)
            Text(title).font(.system(size: 13, weight: .semibold))
            Text(detail)
                .font(.system(size: 10.5))
                .foregroundStyle(WorkspacePalette.secondaryText)
                .multilineTextAlignment(.center)
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 24)
    }

    private func t(_ key: String) -> String {
        L10n.string(key, language: appLanguage)
    }
}

private struct FileShelfTableRow: View {
    let visible: FileShelfVisibleItem
    let rowIndex: Int
    @ObservedObject var store: FileShelfStore
    @Binding var selection: URL?
    @Environment(\.appLanguage) private var appLanguage
    @State private var isHovering = false

    private var item: FileShelfItem { visible.item }

    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: 5) {
                Color.clear.frame(width: CGFloat(visible.depth) * 13)
                disclosure
                Image(nsImage: icon)
                    .resizable()
                    .interpolation(.high)
                    .frame(width: 19, height: 19)
                Text(item.name)
                    .font(.system(size: 11.5, weight: .medium))
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(modified)
                .frame(width: 105, alignment: .leading)
            Text(size)
                .frame(width: 58, alignment: .trailing)
            Text(kind)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(width: 72, alignment: .leading)
                .padding(.leading, 12)
        }
        .font(.system(size: 9.5))
        .foregroundStyle(WorkspacePalette.primaryText)
        .padding(.horizontal, 10)
        .frame(height: 32)
        .contentShape(Rectangle())
        .background(rowBackground)
        .onHover { isHovering = $0 }
        .onTapGesture(count: 2) { store.open(item) }
        .simultaneousGesture(TapGesture().onEnded { selection = item.url })
        .draggable(item.url)
        .contextMenu {
            Button(item.isDirectory && !item.isPackage ? t("Open Folder") : t("Open")) {
                store.open(item)
            }
            Button(t("Show in Finder")) { store.reveal(item.url) }
            Button(t("Copy")) { store.copyFile(item) }
            Button(t("Copy Path")) { store.copyPath(item.url) }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAction(named: Text(item.isDirectory ? t("Open Folder") : t("Open"))) {
            store.open(item)
        }
    }

    @ViewBuilder private var disclosure: some View {
        if item.canExpand {
            Button { store.toggleDirectoryExpansion(item) } label: {
                if store.loadingDirectoryURLs.contains(item.url) {
                    ProgressView().controlSize(.mini)
                } else {
                    Image(systemName: store.expandedDirectoryURLs.contains(item.url)
                          ? "chevron.down" : "chevron.right")
                        .font(.system(size: 8, weight: .semibold))
                }
            }
            .buttonStyle(.plain)
            .foregroundStyle(WorkspacePalette.secondaryText)
            .frame(width: 12, height: 22)
            .help(t(store.expandedDirectoryURLs.contains(item.url) ? "Collapse Folder" : "Expand Folder"))
        } else {
            Color.clear.frame(width: 12, height: 22)
        }
    }

    private var rowBackground: Color {
        if selection == item.url { return Color.accentColor.opacity(0.30) }
        if isHovering { return Color.white.opacity(0.055) }
        return rowIndex.isMultiple(of: 2) ? .clear : Color.white.opacity(0.018)
    }

    private var icon: NSImage {
        let image = NSWorkspace.shared.icon(forFile: item.url.path)
        image.size = NSSize(width: 19, height: 19)
        return image
    }

    private var modified: String {
        item.modificationDate?.formatted(
            .dateTime.month(.abbreviated).day().hour().minute().locale(appLanguage.locale)
        ) ?? "--"
    }

    private var size: String {
        guard let fileSize = item.fileSize else { return "--" }
        return ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
    }

    private var kind: String {
        if item.isSymbolicLink { return t("Alias") }
        if item.isDirectory, !item.isPackage { return t("Folder") }
        if let identifier = item.typeIdentifier,
           let description = UTType(identifier)?.localizedDescription {
            return description
        }
        let extensionName = item.url.pathExtension
        return extensionName.isEmpty ? t("Document") : extensionName.uppercased()
    }

    private func t(_ key: String) -> String {
        L10n.string(key, language: appLanguage)
    }
}
