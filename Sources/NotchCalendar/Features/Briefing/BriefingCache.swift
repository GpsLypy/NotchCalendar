import Foundation

protocol BriefingCache: Sendable {
    func snapshot(for source: BriefingSource, at now: Date) async -> BriefingSnapshot?
    func save(_ snapshot: BriefingSnapshot) async throws
}

actor BriefingDiskCache: BriefingCache {
    static let timeToLive: TimeInterval = 30 * 60
    private static let maximumBytes = 256 * 1_024
    private let directoryURL: URL

    init(directoryURL: URL? = nil) {
        self.directoryURL = directoryURL ?? (FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first ?? FileManager.default.temporaryDirectory)
            .appendingPathComponent("Notch Calendar/Briefing", isDirectory: true)
    }

    func snapshot(for source: BriefingSource, at now: Date) -> BriefingSnapshot? {
        let url = cacheURL(for: source)
        guard let values = try? url.resourceValues(forKeys: [.fileSizeKey, .isRegularFileKey]),
              values.isRegularFile == true, let size = values.fileSize,
              size > 0, size <= Self.maximumBytes,
              let data = try? Data(contentsOf: url), data.count <= Self.maximumBytes,
              let snapshot = try? JSONDecoder().decode(BriefingSnapshot.self, from: data),
              snapshot.source == source, snapshot.isValid(at: now) else { return nil }
        return snapshot
    }

    func save(_ snapshot: BriefingSnapshot) throws {
        guard snapshot.isValid(at: snapshot.fetchedAt) else { throw BriefingError.malformed }
        let data = try JSONEncoder().encode(snapshot)
        guard data.count <= Self.maximumBytes else { throw BriefingError.oversized }
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        try data.write(to: cacheURL(for: snapshot.source), options: .atomic)
    }

    private func cacheURL(for source: BriefingSource) -> URL {
        directoryURL.appendingPathComponent("\(source.rawValue).json")
    }
}

struct BriefingLibrary: Codable, Equatable {
    static let storageKey = "briefing.library.v1"
    static let maximumSaved = 100
    static let maximumRead = 256
    var saved: [BriefingArticle] = []
    var readIDs: [String] = []

    static func load(from defaults: UserDefaults) -> BriefingLibrary {
        guard let data = defaults.data(forKey: storageKey), data.count <= 1_024 * 1_024,
              let library = try? JSONDecoder().decode(Self.self, from: data),
              library.saved.count <= maximumSaved, library.readIDs.count <= maximumRead,
              library.saved.allSatisfy(\.isValid),
              library.readIDs.allSatisfy({ BriefingArticle.safeURL($0) != nil }),
              Set(library.saved.map(\.id)).count == library.saved.count,
              Set(library.readIDs).count == library.readIDs.count else { return Self() }
        return library
    }

    func persist(to defaults: UserDefaults) {
        guard let data = try? JSONEncoder().encode(self), data.count <= 1_024 * 1_024 else { return }
        defaults.set(data, forKey: Self.storageKey)
    }

    /// Returns false at the explicit shelf capacity without evicting an existing save.
    mutating func toggleSaved(_ article: BriefingArticle) -> Bool {
        guard article.isValid else { return false }
        if let index = saved.firstIndex(where: { $0.id == article.id }) {
            saved.remove(at: index)
        } else {
            guard saved.count < Self.maximumSaved else { return false }
            saved.insert(article, at: 0)
        }
        return true
    }

    mutating func setRead(_ article: BriefingArticle, isRead: Bool) {
        readIDs.removeAll { $0 == article.id }
        if isRead, article.isValid { readIDs.insert(article.id, at: 0) }
        readIDs = Array(readIDs.prefix(Self.maximumRead))
    }
}
