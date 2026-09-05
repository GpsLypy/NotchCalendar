import Combine
import Foundation

protocol DiscussionCaching: Sendable {
    func snapshot(storyID: Int) async -> DiscussionSnapshot?
    func save(_ snapshot: DiscussionSnapshot) async throws
}

actor DiscussionDiskCache: DiscussionCaching {
    static let maximumBytes = 2 * 1_024 * 1_024
    static let snapshotLimit = 20
    private let fileURL: URL

    init(fileURL: URL? = nil) {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first ?? FileManager.default.temporaryDirectory
        self.fileURL = fileURL ?? support.appendingPathComponent("Notch Calendar/Discussion/threads.json")
    }

    func snapshot(storyID: Int) -> DiscussionSnapshot? { read().first { $0.storyID == storyID } }

    func save(_ snapshot: DiscussionSnapshot) throws {
        guard snapshot.isValid else { throw RadarClientError.malformedData }
        var snapshots = Array(([snapshot] + read().filter { $0.storyID != snapshot.storyID })
            .sorted { $0.fetchedAt > $1.fetchedAt }.prefix(Self.snapshotLimit))
        var data = try JSONEncoder().encode(snapshots)
        while data.count > Self.maximumBytes, snapshots.count > 1 {
            snapshots.removeLast()
            data = try JSONEncoder().encode(snapshots)
        }
        guard data.count <= Self.maximumBytes else { throw RadarClientError.responseTooLarge }
        try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: fileURL, options: .atomic)
    }

    private func read() -> [DiscussionSnapshot] {
        guard let values = try? fileURL.resourceValues(forKeys: [.fileSizeKey, .isRegularFileKey]),
              values.isRegularFile == true, let size = values.fileSize, size <= Self.maximumBytes,
              let data = try? Data(contentsOf: fileURL), data.count <= Self.maximumBytes,
              let snapshots = try? JSONDecoder().decode([DiscussionSnapshot].self, from: data),
              snapshots.count <= Self.snapshotLimit else { return [] }
        return snapshots.filter(\.isValid)
    }
}

@MainActor
final class DiscussionStore: ObservableObject {
    @Published private(set) var snapshot: DiscussionSnapshot?
    @Published private(set) var selectedID: Int?
    @Published private(set) var isLoading = false
    @Published private(set) var isStale = false
    @Published private(set) var loadFailed = false
    @Published private(set) var cacheWriteFailed = false

    private let client: any DiscussionClient
    private let cache: any DiscussionCaching
    private let now: () -> Date
    private var generation = 0

    init(client: any DiscussionClient = HackerNewsDiscussionClient(), cache: any DiscussionCaching = DiscussionDiskCache(), now: @escaping () -> Date = Date.init) {
        self.client = client
        self.cache = cache
        self.now = now
    }

    func load(storyID: Int, force: Bool = false) async {
        generation &+= 1
        let request = generation
        if selectedID != storyID { snapshot = nil }
        selectedID = storyID
        loadFailed = false
        cacheWriteFailed = false
        isStale = false
        isLoading = true
        defer { if generation == request { isLoading = false } }
        let date = now()
        if let cached = await cache.snapshot(storyID: storyID), cached.isValid, cached.storyID == storyID {
            guard generation == request, !Task.isCancelled else { return }
            if snapshot == nil || cached.fetchedAt > snapshot!.fetchedAt { snapshot = cached }
            let age = date.timeIntervalSince(cached.fetchedAt)
            isStale = age < 0 || age > 600
            if !isStale && !force { return }
        }
        guard generation == request, !Task.isCancelled else { return }
        do {
            let incoming = try await client.fetch(storyID: storyID, at: date)
            try Task.checkCancellation()
            guard generation == request else { return }
            guard incoming.isValid, incoming.storyID == storyID else { throw RadarClientError.malformedData }
            // An incomplete refresh must not remove comments the reader already had.
            if incoming.failedCount > 0, let previous = snapshot {
                var ids = Set(incoming.comments.map(\.id))
                let retained = previous.comments.filter { ids.insert($0.id).inserted }
                let merged = Array((incoming.comments + retained).prefix(HackerNewsDiscussionClient.commentLimit))
                snapshot = DiscussionSnapshot(storyID: storyID, storyText: incoming.storyText,
                    comments: merged, topLevelCount: max(incoming.topLevelCount, merged.count),
                    failedCount: incoming.failedCount, fetchedAt: incoming.fetchedAt)
                isStale = !retained.isEmpty
            } else {
                snapshot = incoming
                isStale = false
            }
            // Save complete responses only; partial data must not overwrite a healthy offline copy.
            if incoming.failedCount == 0 {
                do { try await cache.save(incoming) }
                catch { if generation == request { cacheWriteFailed = true } }
            }
        } catch {
            guard generation == request, !Task.isCancelled, !(error is CancellationError) else { return }
            loadFailed = true
            isStale = snapshot != nil
        }
    }
}

@MainActor
final class DiscussionNotebook: ObservableObject {
    static let storageKey = "discussion.privateTakes.v1"
    static let maximumNotes = 500
    static let maximumBytes = 2 * 1_024 * 1_024
    @Published private(set) var takes: [Int: DiscussionTake] = [:]
    @Published private(set) var writeFailed = false
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: Self.storageKey), data.count <= Self.maximumBytes,
           let values = try? JSONDecoder().decode([DiscussionTake].self, from: data), values.count <= Self.maximumNotes {
            for take in values where take.isValid { takes[take.story.id] = take }
        }
    }

    func take(for story: RadarStory) -> DiscussionTake {
        takes[story.id] ?? DiscussionTake(story: story, note: "", stance: .exploring, isSaved: false, updatedAt: Date())
    }

    var savedStories: [RadarStory] {
        // Notes and stances remain discoverable after the story leaves the live feed.
        takes.values.sorted { $0.updatedAt > $1.updatedAt }.map(\.story)
    }

    @discardableResult func save(story: RadarStory, note: String, stance: DiscussionStance, isSaved: Bool) -> Bool {
        var next = takes
        let take = DiscussionTake(story: story, note: String(note.prefix(2_000)), stance: stance, isSaved: isSaved, updatedAt: Date())
        guard take.isValid else { writeFailed = true; return false }
        if note.isEmpty && stance == .exploring && !isSaved { next.removeValue(forKey: story.id) }
        else { next[story.id] = take }
        guard next.count <= Self.maximumNotes,
              let data = try? JSONEncoder().encode(Array(next.values)), data.count <= Self.maximumBytes else {
            writeFailed = true
            return false
        }
        defaults.set(data, forKey: Self.storageKey)
        takes = next
        writeFailed = false
        return true
    }
}
