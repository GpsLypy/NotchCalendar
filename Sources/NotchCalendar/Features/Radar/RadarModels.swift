import Foundation

enum RadarFeed: String, CaseIterable, Codable, Identifiable, Sendable {
    case hot
    case ask
    case show

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .hot: "Hot"
        case .ask: "Ask"
        case .show: "Show"
        }
    }

    var detailKey: String {
        switch self {
        case .hot: "What the technology community is reading now."
        case .ask: "Questions drawing thoughtful answers."
        case .show: "Things people have just made."
        }
    }

    var endpointComponent: String {
        switch self {
        case .hot: "topstories"
        case .ask: "askstories"
        case .show: "showstories"
        }
    }
}

struct RadarStory: Codable, Equatable, Identifiable, Sendable {
    let id: Int
    let title: String
    let destinationURL: URL
    let author: String?
    let score: Int
    let commentCount: Int
    let publishedAt: Date

    var sourceLabel: String {
        guard let host = destinationURL.host?.lowercased() else { return "news.ycombinator.com" }
        return host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
    }

    var isValid: Bool {
        let normalizedScheme = destinationURL.scheme?.lowercased()
        return id > 0
            && !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && title.count <= 300
            && (normalizedScheme == "https" || normalizedScheme == "http")
            && destinationURL.absoluteString.count <= 2_048
            && destinationURL.host != nil
            && (author?.count ?? 0) <= 80
            && score >= 0
            && commentCount >= 0
            && publishedAt.timeIntervalSince1970.isFinite
            && publishedAt.timeIntervalSince1970 > 0
    }
}

struct RadarSnapshot: Codable, Equatable, Sendable {
    let feed: RadarFeed
    let stories: [RadarStory]
    let fetchedAt: Date

    func isFresh(at date: Date, timeToLive: TimeInterval) -> Bool {
        let age = date.timeIntervalSince(fetchedAt)
        return age >= 0 && age < timeToLive
    }

    func isValid(for expectedFeed: RadarFeed) -> Bool {
        feed == expectedFeed
            && !stories.isEmpty
            && stories.count <= HackerNewsRadarClient.storyLimit
            && Set(stories.map(\.id)).count == stories.count
            && stories.allSatisfy(\.isValid)
            && fetchedAt.timeIntervalSince1970.isFinite
            && fetchedAt.timeIntervalSince1970 > 0
    }
}

struct RadarHTTPResponse: Sendable {
    let data: Data
    let statusCode: Int
}

enum RadarClientError: Error, Equatable, Sendable {
    case invalidEndpoint
    case invalidResponse(statusCode: Int)
    case responseTooLarge
    case malformedData
    case noStories
    case requestTimedOut
}
