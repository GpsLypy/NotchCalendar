import Foundation

protocol DiscussionClient: Sendable {
    func fetch(storyID: Int, at date: Date) async throws -> DiscussionSnapshot
}

struct HackerNewsDiscussionClient: DiscussionClient, Sendable {
    static let commentLimit = 12
    static let candidateLimit = 16
    static let maximumItemBytes = 96 * 1_024
    private let transport: any RadarHTTPTransport
    private let deadline: Duration

    init(transport: any RadarHTTPTransport = RadarURLSessionTransport(), deadline: Duration = .seconds(14)) {
        self.transport = transport
        self.deadline = deadline
    }

    func fetch(storyID: Int, at date: Date) async throws -> DiscussionSnapshot {
        guard storyID > 0 else { throw RadarClientError.invalidEndpoint }
        return try await withThrowingTaskGroup(of: DiscussionSnapshot.self) { group in
            group.addTask { try await fetchThread(storyID: storyID, at: date) }
            group.addTask {
                try await Task.sleep(for: deadline)
                try Task.checkCancellation()
                throw RadarClientError.requestTimedOut
            }
            defer { group.cancelAll() }
            guard let result = try await group.next() else { throw RadarClientError.malformedData }
            return result
        }
    }

    private func fetchThread(storyID: Int, at date: Date) async throws -> DiscussionSnapshot {
        let story = try await item(storyID)
        guard story.id == storyID, story.type == "story", story.dead != true, story.deleted != true else {
            throw RadarClientError.malformedData
        }
        var seen = Set<Int>()
        let children = (story.kids ?? []).filter { $0 > 0 && seen.insert($0).inserted }
        let candidates = Array(children.prefix(Self.candidateLimit).enumerated())
        var comments: [(rank: Int, comment: DiscussionComment)] = []
        var failures = 0
        for start in stride(from: 0, to: candidates.count, by: 4) {
            try Task.checkCancellation()
            let batch = Array(candidates[start..<min(start + 4, candidates.count)])
            let results = try await withThrowingTaskGroup(of: CommentResult.self) { group in
                for (rank, id) in batch {
                    group.addTask {
                        do {
                            let raw = try await item(id)
                            if raw.id == id && (raw.dead == true || raw.deleted == true) {
                                return CommentResult(rank: rank, comment: nil, failed: false)
                            }
                            let comment = Self.comment(raw, expectedID: id, storyID: storyID, at: date)
                            // A removed comment is an intentional absence; malformed data is
                            // an incomplete refresh and must not erase a healthy cached copy.
                            return CommentResult(rank: rank, comment: comment, failed: comment == nil)
                        } catch is CancellationError { throw CancellationError() }
                        catch {
                            try Task.checkCancellation()
                            return CommentResult(rank: rank, comment: nil, failed: true)
                        }
                    }
                }
                var results: [CommentResult] = []
                for try await result in group { results.append(result) }
                return results
            }
            for result in results {
                if let comment = result.comment { comments.append((result.rank, comment)) }
                if result.failed { failures += 1 }
            }
            if comments.count >= Self.commentLimit { break }
        }
        if comments.isEmpty && failures > 0 { throw RadarClientError.malformedData }
        return DiscussionSnapshot(
            storyID: storyID,
            storyText: DiscussionText.plain(story.text ?? ""),
            comments: comments.sorted { $0.rank < $1.rank }.prefix(Self.commentLimit).map(\.comment),
            topLevelCount: children.count,
            failedCount: failures,
            fetchedAt: date
        )
    }

    private func item(_ id: Int) async throws -> DiscussionItem {
        try Task.checkCancellation()
        guard id > 0, let url = URL(string: "https://hacker-news.firebaseio.com/v0/item/\(id).json") else {
            throw RadarClientError.invalidEndpoint
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 8
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("NotchCalendar-Discussion", forHTTPHeaderField: "User-Agent")
        let response = try await transport.data(for: request, maximumBytes: Self.maximumItemBytes)
        try Task.checkCancellation()
        guard (200..<300).contains(response.statusCode) else { throw RadarClientError.invalidResponse(statusCode: response.statusCode) }
        guard response.data.count <= Self.maximumItemBytes else { throw RadarClientError.responseTooLarge }
        guard let item = try? JSONDecoder().decode(DiscussionItem.self, from: response.data) else { throw RadarClientError.malformedData }
        return item
    }

    static func comment(_ item: DiscussionItem, expectedID: Int, storyID: Int, at date: Date) -> DiscussionComment? {
        guard item.id == expectedID, item.parent == storyID, item.type == "comment",
              item.dead != true, item.deleted != true,
              let author = item.by?.trimmingCharacters(in: .whitespacesAndNewlines),
              author.rangeOfCharacter(from: .controlCharacters) == nil,
              let timestamp = item.time, timestamp.isFinite, timestamp > 0,
              timestamp <= date.addingTimeInterval(86_400).timeIntervalSince1970 else { return nil }
        let comment = DiscussionComment(id: expectedID, storyID: storyID, author: author,
            text: DiscussionText.plain(item.text ?? ""), publishedAt: Date(timeIntervalSince1970: timestamp),
            replyCount: (item.kids ?? []).filter { $0 > 0 }.count)
        return comment.isValid ? comment : nil
    }
}

struct DiscussionItem: Decodable, Sendable {
    let id: Int
    let type: String?
    let parent: Int?
    let by: String?
    let time: TimeInterval?
    let text: String?
    let kids: [Int]?
    let dead: Bool?
    let deleted: Bool?
}

private struct CommentResult: Sendable {
    let rank: Int
    let comment: DiscussionComment?
    let failed: Bool
}
