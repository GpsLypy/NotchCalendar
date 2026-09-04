import Foundation

protocol RadarCacheStore: Sendable {
    func snapshot(for feed: RadarFeed) async -> RadarSnapshot?
    func save(_ snapshot: RadarSnapshot) async throws
}

actor RadarDiskCache: RadarCacheStore {
    static let timeToLive: TimeInterval = 30 * 60
    private static let maximumCacheBytes = 1_024 * 1_024

    private let directoryURL: URL
    private let fileManager: FileManager

    init(directoryURL: URL? = nil, fileManager: FileManager = .default) {
        self.fileManager = fileManager
        if let directoryURL {
            self.directoryURL = directoryURL
        } else {
            let applicationSupport = fileManager.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            ).first ?? fileManager.temporaryDirectory
            self.directoryURL = applicationSupport
                .appendingPathComponent("Notch Calendar", isDirectory: true)
                .appendingPathComponent("Radar", isDirectory: true)
        }
    }

    func snapshot(for feed: RadarFeed) -> RadarSnapshot? {
        let fileURL = cacheURL(for: feed)
        guard let values = try? fileURL.resourceValues(forKeys: [.fileSizeKey, .isRegularFileKey]),
              values.isRegularFile == true,
              let fileSize = values.fileSize,
              fileSize > 0,
              fileSize <= Self.maximumCacheBytes,
              let data = try? Data(contentsOf: fileURL, options: [.mappedIfSafe]),
              data.count <= Self.maximumCacheBytes,
              let snapshot = try? decoder.decode(RadarSnapshot.self, from: data),
              snapshot.isValid(for: feed) else {
            return nil
        }
        return snapshot
    }

    func save(_ snapshot: RadarSnapshot) throws {
        guard snapshot.isValid(for: snapshot.feed) else {
            throw RadarClientError.malformedData
        }
        try fileManager.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true,
            attributes: nil
        )
        let data = try encoder.encode(snapshot)
        guard data.count <= Self.maximumCacheBytes else {
            throw RadarClientError.responseTooLarge
        }
        try data.write(to: cacheURL(for: snapshot.feed), options: [.atomic])
    }

    private func cacheURL(for feed: RadarFeed) -> URL {
        directoryURL.appendingPathComponent("\(feed.rawValue).json", isDirectory: false)
    }

    private var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }

    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        return decoder
    }
}
