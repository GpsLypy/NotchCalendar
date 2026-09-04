import Foundation

protocol RadarClient: Sendable {
    func fetch(feed: RadarFeed, at date: Date) async throws -> RadarSnapshot
}

protocol RadarHTTPTransport: Sendable {
    func data(for request: URLRequest, maximumBytes: Int) async throws -> RadarHTTPResponse
}

struct RadarURLSessionTransport: RadarHTTPTransport, @unchecked Sendable {
    private let session: URLSession

    init(session: URLSession = RadarURLSessionTransport.makeSession()) {
        self.session = session
    }

    func data(for request: URLRequest, maximumBytes: Int) async throws -> RadarHTTPResponse {
        let (bytes, response) = try await session.bytes(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RadarClientError.invalidResponse(statusCode: 0)
        }

        if httpResponse.expectedContentLength > Int64(maximumBytes) {
            throw RadarClientError.responseTooLarge
        }

        var data = Data()
        if httpResponse.expectedContentLength > 0 {
            data.reserveCapacity(min(Int(httpResponse.expectedContentLength), maximumBytes))
        }
        for try await byte in bytes {
            guard data.count < maximumBytes else {
                throw RadarClientError.responseTooLarge
            }
            data.append(byte)
        }
        return RadarHTTPResponse(data: data, statusCode: httpResponse.statusCode)
    }

    private static func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = HackerNewsRadarClient.requestTimeout
        configuration.timeoutIntervalForResource = HackerNewsRadarClient.requestTimeout
        configuration.waitsForConnectivity = false
        configuration.httpCookieStorage = nil
        configuration.urlCache = nil
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        return URLSession(configuration: configuration)
    }
}

struct HackerNewsRadarClient: RadarClient, Sendable {
    static let storyLimit = 10
    static let maximumConcurrentItemRequests = 4
    static let requestTimeout: TimeInterval = 8
    static let defaultFeedDeadline = Duration.seconds(12)

    private static let maximumIndexBytes = 256 * 1_024
    private static let maximumItemBytes = 64 * 1_024
    private static let maximumCandidateCount = 24
    private static let apiHost = "hacker-news.firebaseio.com"

    private let transport: any RadarHTTPTransport
    private let feedDeadline: Duration

    init(
        transport: any RadarHTTPTransport = RadarURLSessionTransport(),
        feedDeadline: Duration = Self.defaultFeedDeadline
    ) {
        self.transport = transport
        self.feedDeadline = feedDeadline
    }

    func fetch(feed: RadarFeed, at date: Date) async throws -> RadarSnapshot {
        try await withThrowingTaskGroup(of: RadarSnapshot.self) { group in
            group.addTask {
                try await fetchWithinDeadline(feed: feed, at: date)
            }
            group.addTask {
                try await Task.sleep(for: feedDeadline)
                try Task.checkCancellation()
                throw RadarClientError.requestTimedOut
            }

            do {
                guard let firstResult = try await group.next() else {
                    throw RadarClientError.noStories
                }
                group.cancelAll()
                return firstResult
            } catch {
                group.cancelAll()
                throw error
            }
        }
    }

    private func fetchWithinDeadline(feed: RadarFeed, at date: Date) async throws -> RadarSnapshot {
        let indexURL = try endpointURL(path: "/v0/\(feed.endpointComponent).json")
        let indexData = try await load(indexURL, maximumBytes: Self.maximumIndexBytes)
        guard let decodedIDs = try? JSONDecoder().decode([Int].self, from: indexData) else {
            throw RadarClientError.malformedData
        }

        var seenIDs: Set<Int> = []
        var candidateIDs: [Int] = []
        for id in decodedIDs where id > 0 {
            guard seenIDs.insert(id).inserted else { continue }
            candidateIDs.append(id)
            if candidateIDs.count == Self.maximumCandidateCount { break }
        }
        var rankedStories: [(rank: Int, story: RadarStory)] = []
        let candidates = Array(candidateIDs.enumerated())

        for batchStart in stride(
            from: 0,
            to: candidates.count,
            by: Self.maximumConcurrentItemRequests
        ) {
            try Task.checkCancellation()
            let batchEnd = min(
                batchStart + Self.maximumConcurrentItemRequests,
                candidates.count
            )
            let batch = Array(candidates[batchStart..<batchEnd])
            let batchStories = try await withThrowingTaskGroup(
                of: RankedStory?.self,
                returning: [RankedStory].self
            ) { group in
                for (rank, id) in batch {
                    group.addTask {
                        try Task.checkCancellation()
                        do {
                            guard let story = try await fetchStory(id: id, at: date) else {
                                return nil
                            }
                            return RankedStory(rank: rank, story: story)
                        } catch is CancellationError {
                            throw CancellationError()
                        } catch {
                            try Task.checkCancellation()
                            return nil
                        }
                    }
                }

                var stories: [RankedStory] = []
                for try await result in group {
                    if let result { stories.append(result) }
                }
                return stories
            }

            rankedStories.append(contentsOf: batchStories.map { ($0.rank, $0.story) })
            if rankedStories.count >= Self.storyLimit { break }
        }

        let stories = rankedStories
            .sorted { $0.rank < $1.rank }
            .prefix(Self.storyLimit)
            .map(\.story)
        guard !stories.isEmpty else { throw RadarClientError.noStories }

        return RadarSnapshot(feed: feed, stories: stories, fetchedAt: date)
    }

    private func fetchStory(id: Int, at date: Date) async throws -> RadarStory? {
        let url = try endpointURL(path: "/v0/item/\(id).json")
        let data = try await load(url, maximumBytes: Self.maximumItemBytes)
        guard let item = try? JSONDecoder().decode(HackerNewsItem.self, from: data) else {
            return nil
        }
        guard item.id == id,
              item.type == "story",
              item.dead != true,
              item.deleted != true,
              let title = normalizedTitle(item.title) else {
            return nil
        }

        let publishedAt = Date(timeIntervalSince1970: item.time ?? 0)
        guard publishedAt.timeIntervalSince1970 > 0,
              publishedAt <= date.addingTimeInterval(24 * 60 * 60) else {
            return nil
        }

        let fallbackURL = URL(string: "https://news.ycombinator.com/item?id=\(id)")!
        let destinationURL = safeWebURL(item.url) ?? fallbackURL
        let author = normalizedAuthor(item.by)
        let story = RadarStory(
            id: id,
            title: title,
            destinationURL: destinationURL,
            author: author,
            score: max(0, item.score ?? 0),
            commentCount: max(0, item.descendants ?? 0),
            publishedAt: publishedAt
        )
        return story.isValid ? story : nil
    }

    private func load(_ url: URL, maximumBytes: Int) async throws -> Data {
        guard url.scheme == "https", url.host == Self.apiHost else {
            throw RadarClientError.invalidEndpoint
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = Self.requestTimeout
        request.setValue("NotchCalendar-Radar", forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let response = try await transport.data(for: request, maximumBytes: maximumBytes)
        guard (200..<300).contains(response.statusCode) else {
            throw RadarClientError.invalidResponse(statusCode: response.statusCode)
        }
        guard response.data.count <= maximumBytes else {
            throw RadarClientError.responseTooLarge
        }
        return response.data
    }

    private func endpointURL(path: String) throws -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = Self.apiHost
        components.path = path
        guard let url = components.url else { throw RadarClientError.invalidEndpoint }
        return url
    }

    private func safeWebURL(_ rawValue: String?) -> URL? {
        guard let rawValue,
              rawValue.count <= 2_048,
              let url = URL(string: rawValue),
              let scheme = url.scheme?.lowercased(),
              scheme == "https" || scheme == "http",
              url.host != nil else {
            return nil
        }
        return url
    }

    private func normalizedTitle(_ value: String?) -> String? {
        guard let value else { return nil }
        let title = value
            .components(separatedBy: .controlCharacters)
            .joined()
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty, title.count <= 300 else { return nil }
        return title
    }

    private func normalizedAuthor(_ value: String?) -> String? {
        guard let value else { return nil }
        let author = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !author.isEmpty, author.count <= 80 else { return nil }
        return author
    }
}

private struct RankedStory: Sendable {
    let rank: Int
    let story: RadarStory
}

private struct HackerNewsItem: Decodable, Sendable {
    let id: Int
    let type: String?
    let by: String?
    let time: TimeInterval?
    let title: String?
    let url: String?
    let score: Int?
    let descendants: Int?
    let dead: Bool?
    let deleted: Bool?
}
