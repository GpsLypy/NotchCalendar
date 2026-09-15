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

struct FileShelfLocation: Identifiable, Equatable, Sendable {
    let id: UUID
    let url: URL
    let bookmark: Data

    var name: String { url.lastPathComponent }
}

struct FileShelfItem: Identifiable, Equatable, Sendable {
    let url: URL
    let name: String
    let isDirectory: Bool
    let isPackage: Bool
    let isSymbolicLink: Bool
    let modificationDate: Date?
    let fileSize: Int64?
    let typeIdentifier: String?

    var id: URL { url }
    var canExpand: Bool { isDirectory && !isPackage && !isSymbolicLink }
}

struct FileShelfVisibleItem: Identifiable, Equatable, Sendable {
    let item: FileShelfItem
    let depth: Int

    var id: URL { item.id }
}

enum FileShelfDirectoryReader {
    static func items(
        at directory: URL,
        showsHiddenFiles: Bool,
        sort: FileShelfSort,
        fileManager: FileManager = .default
    ) throws -> [FileShelfItem] {
        let keys: Set<URLResourceKey> = [
            .isDirectoryKey, .isHiddenKey, .isPackageKey, .isSymbolicLinkKey,
            .localizedNameKey, .contentModificationDateKey, .fileSizeKey,
            .typeIdentifierKey
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
            let isDirectory = values.isDirectory == true
            return FileShelfItem(
                url: url,
                name: values.localizedName ?? url.lastPathComponent,
                isDirectory: isDirectory,
                isPackage: values.isPackage == true,
                isSymbolicLink: values.isSymbolicLink == true,
                modificationDate: values.contentModificationDate,
                fileSize: isDirectory ? nil : values.fileSize.map(Int64.init),
                typeIdentifier: values.typeIdentifier
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

private struct FileShelfLocationRecord: Codable {
    let id: UUID
    let bookmark: Data
}

private enum FileShelfReadFailure: Error, Sendable {
    case unreadable
}

@MainActor
final class FileShelfStore: ObservableObject {
    static let maximumLocations = 12
    static let enabledKey = "files.shelfEnabled"
    static let bookmarkKey = "files.rootBookmark"
    static let locationsKey = "files.rootBookmarks.v2"
    static let selectedLocationKey = "files.selectedLocationID"
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
            resetTree()
            refresh()
        }
    }
    @Published var sort: FileShelfSort {
        didSet {
            guard oldValue != sort else { return }
            defaults.set(sort.rawValue, forKey: Self.sortKey)
            resetTree()
            refresh()
        }
    }
    @Published private(set) var locations: [FileShelfLocation]
    @Published private(set) var selectedLocationID: UUID?
    @Published private(set) var currentURL: URL?
    @Published private(set) var items: [FileShelfItem] = []
    @Published private(set) var expandedDirectoryURLs: Set<URL> = []
    @Published private(set) var childrenByDirectory: [URL: [FileShelfItem]] = [:]
    @Published private(set) var loadingDirectoryURLs: Set<URL> = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessageKey: String?

    private let defaults: UserDefaults
    private var history: [URL]
    private var historyIndex: Int
    private var refreshTask: Task<Void, Never>?
    private var monitor: DispatchSourceFileSystemObject?
    private var monitorDescriptor: Int32 = -1
    private var refreshGeneration = 0
    private var treeGeneration = 0

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        isEnabled = defaults.object(forKey: Self.enabledKey) as? Bool ?? false
        showsHiddenFiles = defaults.object(forKey: Self.hiddenFilesKey) as? Bool ?? false
        sort = defaults.string(forKey: Self.sortKey).flatMap(FileShelfSort.init(rawValue:)) ?? .name

        var restored = Self.restoreLocations(from: defaults.data(forKey: Self.locationsKey))
        if restored.isEmpty,
           let legacy = Self.restoreLocation(from: defaults.data(forKey: Self.bookmarkKey)) {
            restored = [legacy]
        }
        locations = restored
        let storedSelection = defaults.string(forKey: Self.selectedLocationKey).flatMap(UUID.init(uuidString:))
        let selection = restored.contains(where: { $0.id == storedSelection })
            ? storedSelection
            : restored.first?.id
        let selectedURL = restored.first(where: { $0.id == selection })?.url
        selectedLocationID = selection
        currentURL = selectedURL
        history = selectedURL.map { [$0] } ?? []
        historyIndex = history.isEmpty ? -1 : 0
        persistLocations()
        if currentURL != nil, isEnabled { refresh() }
    }

    deinit {
        refreshTask?.cancel()
        monitor?.cancel()
        if monitor == nil, monitorDescriptor >= 0 { close(monitorDescriptor) }
    }

    var selectedLocation: FileShelfLocation? {
        locations.first(where: { $0.id == selectedLocationID })
    }

    var rootURL: URL? { selectedLocation?.url }
    var canNavigateBack: Bool { historyIndex > 0 }
    var canNavigateForward: Bool { historyIndex >= 0 && historyIndex + 1 < history.count }

    var visibleItems: [FileShelfVisibleItem] {
        flatten(items, depth: 0)
    }

    func chooseRootDirectories() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = true
        panel.prompt = L10n.string("Add Folders", language: AppLanguage.persisted(in: defaults))
        if let rootURL { panel.directoryURL = rootURL }
        NSApp.activate(ignoringOtherApps: true)
        guard panel.runModal() == .OK else { return }
        addRootDirectories(panel.urls)
    }

    func chooseRootDirectory() {
        chooseRootDirectories()
    }

    func addRootDirectories(_ urls: [URL]) {
        var additions: [FileShelfLocation] = []
        let availableSlots = max(0, Self.maximumLocations - locations.count)
        for url in urls.prefix(availableSlots) {
            let resolved = url.resolvingSymlinksInPath().standardizedFileURL
            guard !locations.contains(where: { $0.url == resolved }),
                  !additions.contains(where: { $0.url == resolved }),
                  (try? resolved.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true else {
                continue
            }
            guard let bookmark = try? Self.bookmark(for: resolved) else {
                errorMessageKey = "The selected folder could not be saved."
                continue
            }
            additions.append(FileShelfLocation(id: UUID(), url: resolved, bookmark: bookmark))
        }
        guard !additions.isEmpty else {
            if locations.count >= Self.maximumLocations {
                errorMessageKey = "You can keep up to 12 folders."
            }
            return
        }
        locations.append(contentsOf: additions)
        persistLocations()
        selectLocation(additions[0].id)
    }

    func setRootDirectory(_ url: URL) {
        locations = []
        selectedLocationID = nil
        persistLocations()
        addRootDirectories([url])
    }

    func selectLocation(_ id: UUID) {
        guard let location = locations.first(where: { $0.id == id }) else { return }
        selectedLocationID = id
        defaults.set(id.uuidString, forKey: Self.selectedLocationKey)
        currentURL = location.url
        history = [location.url]
        historyIndex = 0
        errorMessageKey = nil
        resetTree()
        refresh()
    }

    func removeLocation(_ id: UUID) {
        guard let index = locations.firstIndex(where: { $0.id == id }) else { return }
        let wasSelected = selectedLocationID == id
        locations.remove(at: index)
        persistLocations()
        guard wasSelected else { return }
        if locations.isEmpty {
            selectedLocationID = nil
            currentURL = nil
            history = []
            historyIndex = -1
            resetTree()
            refresh()
        } else {
            selectLocation(locations[min(index, locations.count - 1)].id)
        }
    }

    func clearRootDirectory() {
        stopMonitoring()
        locations = []
        selectedLocationID = nil
        currentURL = nil
        history = []
        historyIndex = -1
        items = []
        errorMessageKey = nil
        resetTree()
        persistLocations()
    }

    func moveLocation(_ id: UUID, by offset: Int) {
        guard let source = locations.firstIndex(where: { $0.id == id }) else { return }
        let destination = source + offset
        guard locations.indices.contains(destination) else { return }
        locations.swapAt(source, destination)
        persistLocations()
    }

    func canMoveLocation(_ id: UUID, by offset: Int) -> Bool {
        guard let source = locations.firstIndex(where: { $0.id == id }) else { return false }
        return locations.indices.contains(source + offset)
    }

    func open(_ item: FileShelfItem) {
        if item.isDirectory, !item.isPackage {
            navigate(to: item.url)
        } else if !NSWorkspace.shared.open(item.url) {
            errorMessageKey = "The file could not be opened."
        }
    }

    func navigateBack() {
        guard canNavigateBack else { return }
        historyIndex -= 1
        currentURL = history[historyIndex]
        resetTree()
        refresh()
    }

    func navigateForward() {
        guard canNavigateForward else { return }
        historyIndex += 1
        currentURL = history[historyIndex]
        resetTree()
        refresh()
    }

    func toggleDirectoryExpansion(_ item: FileShelfItem) {
        guard item.canExpand, let rootURL,
              FileShelfDirectoryReader.contains(item.url, inside: rootURL) else { return }
        if expandedDirectoryURLs.remove(item.url) != nil { return }
        expandedDirectoryURLs.insert(item.url)
        guard childrenByDirectory[item.url] == nil else { return }
        loadChildren(of: item.url)
    }

    func reveal(_ url: URL) {
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }

    func copyPath(_ url: URL) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(url.path, forType: .string)
    }

    @discardableResult
    func copyFile(_ item: FileShelfItem, to pasteboard: NSPasteboard = .general) -> Bool {
        pasteboard.clearContents()
        guard pasteboard.writeObjects([item.url as NSURL]) else {
            errorMessageKey = "The file could not be copied."
            return false
        }
        errorMessageKey = nil
        return true
    }

    func refresh() {
        guard isEnabled, let directory = currentURL else {
            refreshTask?.cancel()
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
            let result = await Self.read(directory, showsHiddenFiles: showsHiddenFiles, sort: sort)
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
        let destination = url.resolvingSymlinksInPath().standardizedFileURL
        if historyIndex + 1 < history.count {
            history.removeSubrange((historyIndex + 1)..<history.count)
        }
        if history.last != destination { history.append(destination) }
        historyIndex = history.count - 1
        currentURL = destination
        resetTree()
        refresh()
    }

    private func loadChildren(of directory: URL) {
        loadingDirectoryURLs.insert(directory)
        let generation = treeGeneration
        let showsHiddenFiles = showsHiddenFiles
        let sort = sort
        Task { [weak self] in
            let result = await Self.read(directory, showsHiddenFiles: showsHiddenFiles, sort: sort)
            guard let self, self.treeGeneration == generation,
                  self.expandedDirectoryURLs.contains(directory) else { return }
            self.loadingDirectoryURLs.remove(directory)
            if case .success(let children) = result {
                self.childrenByDirectory[directory] = children
            }
        }
    }

    private nonisolated static func read(
        _ directory: URL,
        showsHiddenFiles: Bool,
        sort: FileShelfSort
    ) async -> Result<[FileShelfItem], FileShelfReadFailure> {
        await Task.detached(priority: .userInitiated) {
            do {
                return .success(try FileShelfDirectoryReader.items(
                    at: directory,
                    showsHiddenFiles: showsHiddenFiles,
                    sort: sort
                ))
            } catch {
                return .failure(.unreadable)
            }
        }.value
    }

    private func flatten(_ source: [FileShelfItem], depth: Int) -> [FileShelfVisibleItem] {
        var result: [FileShelfVisibleItem] = []
        for item in source {
            result.append(FileShelfVisibleItem(item: item, depth: depth))
            if expandedDirectoryURLs.contains(item.url),
               let children = childrenByDirectory[item.url] {
                result.append(contentsOf: flatten(children, depth: depth + 1))
            }
        }
        return result
    }

    private func resetTree() {
        treeGeneration += 1
        expandedDirectoryURLs = []
        childrenByDirectory = [:]
        loadingDirectoryURLs = []
    }

    private func persistLocations() {
        let records = locations.map { FileShelfLocationRecord(id: $0.id, bookmark: $0.bookmark) }
        if records.isEmpty {
            defaults.removeObject(forKey: Self.locationsKey)
            defaults.removeObject(forKey: Self.selectedLocationKey)
            defaults.removeObject(forKey: Self.bookmarkKey)
            return
        }
        defaults.set(try? JSONEncoder().encode(records), forKey: Self.locationsKey)
        defaults.set(selectedLocationID?.uuidString, forKey: Self.selectedLocationKey)
        defaults.set(records[0].bookmark, forKey: Self.bookmarkKey)
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
        source.setEventHandler { [weak self] in self?.refresh() }
        source.setCancelHandler { close(descriptor) }
        monitor = source
        source.resume()
    }

    private func stopMonitoring() {
        monitor?.cancel()
        monitor = nil
        monitorDescriptor = -1
    }

    private static func bookmark(for url: URL) throws -> Data {
        try url.bookmarkData(
            options: [],
            includingResourceValuesForKeys: [.isDirectoryKey],
            relativeTo: nil
        )
    }

    private static func restoreLocations(from data: Data?) -> [FileShelfLocation] {
        guard let data,
              let records = try? JSONDecoder().decode([FileShelfLocationRecord].self, from: data) else {
            return []
        }
        var seen: Set<URL> = []
        return records.prefix(maximumLocations).compactMap { record in
            guard let location = restoreLocation(id: record.id, from: record.bookmark),
                  seen.insert(location.url).inserted else { return nil }
            return location
        }
    }

    private static func restoreLocation(id: UUID = UUID(), from bookmark: Data?) -> FileShelfLocation? {
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
        let refreshedBookmark = (try? self.bookmark(for: resolved)) ?? bookmark
        return FileShelfLocation(id: id, url: resolved, bookmark: refreshedBookmark)
    }
}
