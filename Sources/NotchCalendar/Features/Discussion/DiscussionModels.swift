import Foundation

/// A manual refresh bypasses cache once; later selections use their normal TTL.
struct DiscussionRefreshGate: Equatable, Sendable {
    private(set) var generation = 0
    private var consumedGeneration = 0

    mutating func request() { generation &+= 1 }
    mutating func consume() -> Bool {
        let pending = generation != consumedGeneration
        consumedGeneration = generation
        return pending
    }
}

/// Public HN text is rendered as plain text. No HTML or remote content is executed.
enum DiscussionText {
    static let maximumInputLength = 32_768
    static let maximumTextLength = 8_000

    static func plain(_ html: String) -> String {
        var value = String(html.prefix(maximumInputLength))
        value = value.replacingOccurrences(of: "(?is)<(script|style)\\b[^>]*>.*?</\\1\\s*>", with: "", options: .regularExpression)
        value = value.replacingOccurrences(of: "(?i)<\\s*(?:br\\s*/?|/?p|/?div|/?pre|/?li)\\b[^>]*>", with: "\n", options: .regularExpression)
        value = value.replacingOccurrences(of: "<[^>]*>", with: "", options: .regularExpression)
        // Decode after removing tags: encoded markup remains harmless visible text.
        let expression = try? NSRegularExpression(pattern: "&(?:#[xX][0-9a-fA-F]{1,8}|#[0-9]{1,10}|[A-Za-z]{2,12});")
        if let expression {
            let original = value as NSString
            let matches = expression.matches(in: value, range: NSRange(location: 0, length: original.length))
            for match in matches.reversed() {
                let entity = original.substring(with: match.range)
                guard let range = Range(match.range, in: value), let replacement = decode(entity) else { continue }
                value.replaceSubrange(range, with: replacement)
            }
        }
        value = String(value.unicodeScalars.filter { !CharacterSet.controlCharacters.contains($0) || $0 == "\n" || $0 == "\t" })
        value = value.replacingOccurrences(of: "[ \\t]+", with: " ", options: .regularExpression)
        value = value.replacingOccurrences(of: "\\n[ \\t]*\\n(?:[ \\t]*\\n)+", with: "\n\n", options: .regularExpression)
        return String(value.trimmingCharacters(in: .whitespacesAndNewlines).prefix(maximumTextLength))
    }

    private static func decode(_ entity: String) -> String? {
        let body = String(entity.dropFirst().dropLast())
        let names = ["amp": "&", "lt": "<", "gt": ">", "quot": "\"", "apos": "'", "nbsp": " ", "hellip": "…", "ndash": "–", "mdash": "—", "lsquo": "‘", "rsquo": "’", "ldquo": "“", "rdquo": "”"]
        if let named = names[body] { return named }
        let number: UInt32?
        if body.lowercased().hasPrefix("#x") { number = UInt32(body.dropFirst(2), radix: 16) }
        else if body.hasPrefix("#") { number = UInt32(body.dropFirst(), radix: 10) }
        else { return nil }
        guard let number, let scalar = UnicodeScalar(number),
              !CharacterSet.controlCharacters.contains(scalar) else { return "" }
        return String(scalar)
    }

    static func webURL(_ raw: String) -> URL? {
        guard raw.count <= 2_048, let url = URL(string: raw),
              ["https", "http"].contains(url.scheme?.lowercased() ?? ""),
              let host = url.host, !host.isEmpty, url.user == nil, url.password == nil else { return nil }
        return url
    }
}

struct DiscussionComment: Codable, Equatable, Identifiable, Sendable {
    let id: Int
    let storyID: Int
    let author: String
    let text: String
    let publishedAt: Date
    let replyCount: Int

    var sourceURL: URL { URL(string: "https://news.ycombinator.com/item?id=\(id)")! }
    var authorURL: URL {
        var components = URLComponents(string: "https://news.ycombinator.com/user")!
        components.queryItems = [URLQueryItem(name: "id", value: author)]
        return components.url!
    }
    var isValid: Bool {
        id > 0 && storyID > 0 && !author.isEmpty && author.count <= 80
            && !text.isEmpty && text.count <= DiscussionText.maximumTextLength
            && publishedAt.timeIntervalSince1970.isFinite && publishedAt.timeIntervalSince1970 > 0 && replyCount >= 0
    }
}

struct DiscussionSnapshot: Codable, Equatable, Sendable {
    let storyID: Int
    let storyText: String
    let comments: [DiscussionComment]
    let topLevelCount: Int
    let failedCount: Int
    let fetchedAt: Date

    var isValid: Bool {
        storyID > 0 && storyText.count <= DiscussionText.maximumTextLength
            && comments.count <= HackerNewsDiscussionClient.commentLimit
            && Set(comments.map(\.id)).count == comments.count
            && comments.allSatisfy { $0.isValid && $0.storyID == storyID }
            && topLevelCount >= comments.count && failedCount >= 0
            && fetchedAt.timeIntervalSince1970.isFinite && fetchedAt.timeIntervalSince1970 > 0
    }
}

enum DiscussionStance: String, Codable, CaseIterable, Identifiable, Sendable {
    case exploring, agree, skeptical
    var id: String { rawValue }
    func title(chinese: Bool) -> String {
        switch self {
        case .exploring: chinese ? "先听听" : "Exploring"
        case .agree: chinese ? "有共鸣" : "Resonates"
        case .skeptical: chinese ? "存疑" : "Skeptical"
        }
    }
}

struct DiscussionTake: Codable, Equatable, Sendable {
    let story: RadarStory
    var note: String
    var stance: DiscussionStance
    var isSaved: Bool
    var updatedAt: Date

    var isValid: Bool { story.isValid && note.count <= 2_000 && updatedAt.timeIntervalSince1970.isFinite }
}
