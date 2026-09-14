import AppKit
import Combine
import Darwin
import Foundation

enum FileShelfSort: String, CaseIterable, Identifiable, Sendable {
    case name
    case modified

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .name: "Name"
        case .modified: "Date Modified"
        }
    }
}

struct FileShelfItem: Identifiable, Equatable, Sendable {
    let url: URL
    let name: String
    let isDirectory: Bool
    let modificationDate: Date?
    let fileSize: Int64?

    var id: URL { url }
}

enum FileShelfDirectoryReader {
    static func items(
        at directory: URL,
        showsHiddenFiles: Bool,
        sort: FileShelfSort,
        fileManager: FileManager = .default
    ) throws -> [FileShelfItem] {
        let keys: Set<URLResourceKey> = [
            .isDirectoryKey, .isHiddenKey, .localizedNameKey,
            .contentModificationDateKey, .fileSizeKey
        ]
        let options: FileManager.DirectoryEnumerationOptions = showsHiddenFiles ? [] : [.skipsHiddenFiles]
        let urls = try fileManager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: Array(keys),
            options: options
        )
        let items = try urls.compactMap { url -> FileShelfItem? in
            let values = try url.resourceValues(forKeys: keys)
            if !showsHiddenFiles, values.isHidden == true { return nil }
            return FileShelfItem(
                url: url,
                name: values.localizedName ?? url.lastPathComponent,
                isDirectory: values.isDirectory == true,
                modificationDate: values.contentModificationDate,
                fileSize: values.isDirectory == true ? nil : values.fileSize.map(Int64.init)
            )
        }
        return items.sorted { first, second in
            if first.isDirectory != second.isDirectory { return first.isDirectory }
            switch sort {
            case .name:
                return first.name.localizedStandardCompare(second.name) == .orderedAscending
            case .modified:
                let firstDate = first.modificationDate ?? .distantPast
                let secondDate = second.modificationDate ?? .distantPast
                if firstDate != secondDate { return firstDate > secondDate }
                return first.name.localizedStandardCompare(second.name) == .orderedAscending
            }
        }
    }

    static func contains(_ candidate: URL, inside root: URL) -> Bool {
        let rootPath = root.resolvingSymlinksInPath().standardizedFileURL.path
        let candidatePath = candidate.resolvingSymlinksInPath().standardizedFileURL.path
        return candidatePath == rootPath || candidatePath.hasPrefix(rootPath + "/")
    }
}

private enum FileShelfReadFailure: Error, Sendable {
    case unreadable
}

@MainActor
final class FileShelfStore: ObservableObject {
    static let enabledKey = "files.shelfEnabled"
    static let bookmarkKey = "files.rootBookmark"
    static let hiddenFilesKey = "files.showsHiddenFiles"
    static let sortKey = "files.sort"

    @Published var isEnabled: Bool {
        didSet {
            guard oldValue != isEnabled else { return }
            defaults.set(isEnabled, forKey: Self.enabledKey)
            refresh()
        }
    }
    @Published var showsHiddenFiles: Bool {
        didSet {
            guard oldValue != showsHiddenFiles else { return }
            defaults.set(showsHiddenFiles, forKey: Self.hiddenFilesKey)
            refresh()
        }
    }
    @Published var sort: FileShelfSort {
        didSet {
            guard oldValue != sort else { return }
            defaults.set(sort.rawValue, forKey: Self.sortKey)
            refresh()
        }
    }
    @Published private(set) var rootURL: URL?
    @Published private(set) var currentURL: URL?
    @Published private(set) var items: [FileShelfItem] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessageKey: String?

    private let defaults: UserDefaults
    private var refreshTask: Task<Void, Never>?
    private var monitor: DispatchSourceFileSystemObject?
    private var monitorDescriptor: Int32 = -1
    private var refreshGeneration = 0

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        isEnabled = defaults.object(forKey: Self.enabledKey) as? Bool ?? false
        showsHiddenFiles = defaults.object(forKey: Self.hiddenFilesKey) as? Bool ?? false
        sort = defaults.string(forKey: Self.sortKey).flatMap(FileShelfSort.init(rawValue:)) ?? .name
        rootURL = Self.restoreRootURL(from: defaults.data(forKey: Self.bookmarkKey))
        currentURL = rootURL
        if rootURL != nil, isEnabled { refresh() }
    }

    deinit {
        refreshTask?.cancel()
        monitor?.cancel()
        if monitor == nil, monitorDescriptor >= 0 { close(monitorDescriptor) }
    }

    var canNavigateUp: Bool {
        guard let rootURL, let currentURL else { return false }
        return currentURL.standardizedFileURL != rootURL.standardizedFileURL
    }

    func chooseRootDirectory() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = L10n.string("Use Folder", language: AppLanguage.persisted(in: defaults))
        if let rootURL { panel.directoryURL = rootURL }
        NSApp.activate(ignoringOtherApps: true)
        guard panel.runModal() == .OK, let url = panel.url else { return }
        setRootDirectory(url)
    }

    func setRootDirectory(_ url: URL) {
        let resolved = url.resolvingSymlinksInPath().standardizedFileURL
        guard (try? resolved.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true else {
            errorMessageKey = "The selected folder is unavailable."
            return
        }
        do {
            let bookmark = try resolved.bookmarkData(
                options: [],
                includingResourceValuesForKeys: [.isDirectoryKey],
                relativeTo: nil
            )
            defaults.set(bookmark, forKey: Self.bookmarkKey)
            rootURL = resolved
            currentURL = resolved
            errorMessageKey = nil
            if isEnabled { refresh() }
        } catch {
            errorMessageKey = "The selected folder could not be saved."
        }
    }

    func clearRootDirectory() {
        stopMonitoring()
        defaults.removeObject(forKey: Self.bookmarkKey)
        rootURL = nil
        currentURL = nil
        items = []
        errorMessageKey = nil
    }

    func open(_ item: FileShelfItem) {
        if item.isDirectory {
            navigate(to: item.url)
        } else if !NSWorkspace.shared.open(item.url) {
            errorMessageKey = "The file could not be opened."
        }
    }

    func navigateUp() {
        guard canNavigateUp, let currentURL else { return }
        navigate(to: currentURL.deletingLastPathComponent())
    }

    func reveal(_ url: URL) {
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }

    func copyPath(_ url: URL) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(url.path, forType: .string)
    }

    func refresh() {
        guard isEnabled, let directory = currentURL else {
            items = []
            isLoading = false
            stopMonitoring()
            return
        }
        refreshTask?.cancel()
        refreshGeneration += 1
        let generation = refreshGeneration
        let showsHiddenFiles = showsHiddenFiles
        let sort = sort
        isLoading = true
        errorMessageKey = nil
        refreshTask = Task { [weak self] in
            let result = await Task.detached(priority: .userInitiated) {
                do {
                    return Result<[FileShelfItem], FileShelfReadFailure>.success(
                        try FileShelfDirectoryReader.items(
                            at: directory,
                            showsHiddenFiles: showsHiddenFiles,
                            sort: sort
                        )
                    )
                } catch {
                    return .failure(.unreadable)
                }
            }.value
            guard let self, !Task.isCancelled,
                  self.refreshGeneration == generation,
                  self.currentURL == directory else { return }
            self.isLoading = false
            switch result {
            case .success(let items):
                self.items = items
                self.startMonitoring(directory)
            case .failure:
                self.items = []
                self.errorMessageKey = "The folder could not be read."
                self.stopMonitoring()
            }
        }
    }

    private func navigate(to url: URL) {
        guard let rootURL,
              FileShelfDirectoryReader.contains(url, inside: rootURL),
              (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true else {
            errorMessageKey = "This folder is outside the file shelf."
            return
        }
        currentURL = url.resolvingSymlinksInPath().standardizedFileURL
        refresh()
    }

    private func startMonitoring(_ directory: URL) {
        stopMonitoring()
        let descriptor = Darwin.open(directory.path, O_EVTONLY)
        guard descriptor >= 0 else { return }
        monitorDescriptor = descriptor
        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: descriptor,
            eventMask: [.write, .delete, .rename, .attrib, .extend, .link, .revoke],
            queue: .main
        )
        source.setEventHandler { [weak self] in
            guard let self else { return }
            self.refresh()
        }
        source.setCancelHandler { close(descriptor) }
        monitor = source
        source.resume()
    }

    private func stopMonitoring() {
        monitor?.cancel()
        monitor = nil
        monitorDescriptor = -1
    }

    private static func restoreRootURL(from bookmark: Data?) -> URL? {
        guard let bookmark else { return nil }
        var isStale = false
        guard let url = try? URL(
            resolvingBookmarkData: bookmark,
            options: [.withoutUI],
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        ) else { return nil }
        let resolved = url.resolvingSymlinksInPath().standardizedFileURL
        guard (try? resolved.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true else { return nil }
        return resolved
    }
}
