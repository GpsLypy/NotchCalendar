import Foundation

enum BriefingSource: String, Codable, CaseIterable, Identifiable, Sendable {
    case github
    case swift
    case nasa

    var id: String { rawValue }

    var name: String {
        switch self {
        case .github: "GitHub Blog"
        case .swift: "Swift.org"
        case .nasa: "NASA"
        }
    }

    var symbol: String {
        switch self {
        case .github: "chevron.left.forwardslash.chevron.right"
        case .swift: "swift"
        case .nasa: "moon.stars"
        }
    }

    var feedURL: URL {
        switch self {
        case .github: URL(string: "https://github.blog/feed/")!
        case .swift: URL(string: "https://www.swift.org/atom.xml")!
        case .nasa: URL(string: "https://www.nasa.gov/feed/")!
        }
    }

    func purpose(chinese: Bool) -> String {
        switch self {
        case .github: chinese ? "从发布者追踪开发工具与开源动态" : "Follow developer tools and open source at the source"
        case .swift: chinese ? "从语言团队了解 Swift 的演进" : "Follow Swift's evolution from its language team"
        case .nasa: chinese ? "从 NASA 了解太空探索与科研进展" : "Explore space and research directly from NASA"
        }
    }
}

enum BriefingTopic: String, Codable, Sendable {
    case security, ai, tools, language, space, update

    func label(chinese: Bool) -> String {
        switch self {
        case .security: chinese ? "安全" : "Security"
        case .ai: "AI"
        case .tools: chinese ? "开发工具" : "Developer tools"
        case .language: chinese ? "语言进展" : "Language"
        case .space: chinese ? "太空与科学" : "Space & science"
        case .update: chinese ? "官方动态" : "Updates"
        }
    }

    static func infer(title: String, source: BriefingSource) -> BriefingTopic {
        let words = title.lowercased().components(separatedBy: .alphanumerics.inverted)
        let tokens = Set(words)
        if !tokens.isDisjoint(with: ["security", "secure", "vulnerability", "vulnerabilities", "cve"]) { return .security }
        if !tokens.isDisjoint(with: ["ai", "copilot", "agent", "agents", "llm", "model", "models"]) { return .ai }
        if source == .nasa { return .space }
        if source == .swift { return .language }
        if !tokens.isDisjoint(with: ["release", "releases", "tool", "tools", "code", "developer", "github"]) { return .tools }
        return .update
    }
}

enum BriefingDateKind: String, Codable, Sendable {
    case published, updated
}

struct BriefingArticle: Codable, Equatable, Identifiable, Sendable {
    let source: BriefingSource
    let title: String
    let url: URL
    let publishedAt: Date
    let dateKind: BriefingDateKind

    var id: String { url.absoluteString }
    var topic: BriefingTopic { .infer(title: title, source: source) }

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && title.count <= 500
            && title.utf8.count <= 2_000
            && Self.safeURL(url.absoluteString) == url
            && publishedAt.timeIntervalSince1970.isFinite
            && publishedAt.timeIntervalSince1970 > 0
    }

    static func safeURL(_ rawValue: String) -> URL? {
        let value = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard value.count <= 2_048,
              !value.unicodeScalars.contains(where: CharacterSet.controlCharacters.contains),
              var components = URLComponents(string: value),
              let scheme = components.scheme?.lowercased(),
              scheme == "https" || scheme == "http",
              let host = components.host, !host.isEmpty,
              components.user == nil, components.password == nil else { return nil }
        components.scheme = scheme
        components.fragment = nil
        return components.url
    }
}

struct BriefingSnapshot: Codable, Equatable, Sendable {
    let source: BriefingSource
    let articles: [BriefingArticle]
    let fetchedAt: Date

    func isFresh(at now: Date) -> Bool {
        let age = now.timeIntervalSince(fetchedAt)
        return age >= 0 && age < BriefingDiskCache.timeToLive
    }

    func isValid(at now: Date) -> Bool {
        !articles.isEmpty
            && articles.count <= BriefingFeedClient.articleLimit
            && articles.allSatisfy { $0.isValid && $0.source == source && $0.publishedAt <= fetchedAt.addingTimeInterval(86_400) }
            && Set(articles.map(\.id)).count == articles.count
            && fetchedAt.timeIntervalSince1970.isFinite
            && fetchedAt.timeIntervalSince1970 > 0
            && fetchedAt <= now.addingTimeInterval(60)
    }
}

enum BriefingError: Error, Equatable, Sendable {
    case oversized, malformed, unsafeXML, noArticles, invalidResponse(Int), timedOut
}
