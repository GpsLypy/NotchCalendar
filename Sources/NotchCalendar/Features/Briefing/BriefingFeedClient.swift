import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

protocol BriefingClient: Sendable {
    func fetch(source: BriefingSource, at date: Date) async throws -> BriefingSnapshot
}

struct BriefingFeedClient: BriefingClient, Sendable {
    static let articleLimit = 20
    static let maximumBytes = 1_024 * 1_024
    private let transport: any RadarHTTPTransport
    private let deadline: Duration

    init(transport: any RadarHTTPTransport = RadarURLSessionTransport(), deadline: Duration = .seconds(12)) {
        self.transport = transport
        self.deadline = deadline
    }

    func fetch(source: BriefingSource, at date: Date) async throws -> BriefingSnapshot {
        try await withThrowingTaskGroup(of: BriefingSnapshot.self) { group in
            group.addTask {
                var request = URLRequest(url: source.feedURL)
                request.timeoutInterval = 8
                request.setValue("application/atom+xml, application/rss+xml, application/xml, text/xml", forHTTPHeaderField: "Accept")
                request.setValue("NotchCalendar-Briefing", forHTTPHeaderField: "User-Agent")
                let response = try await transport.data(for: request, maximumBytes: Self.maximumBytes)
                try Task.checkCancellation()
                guard (200..<300).contains(response.statusCode) else { throw BriefingError.invalidResponse(response.statusCode) }
                let articles = try BriefingXMLParser.parse(response.data, source: source, at: date)
                return BriefingSnapshot(source: source, articles: articles, fetchedAt: date)
            }
            group.addTask {
                try await Task.sleep(for: deadline)
                throw BriefingError.timedOut
            }
            defer { group.cancelAll() }
            guard let result = try await group.next() else { throw BriefingError.noArticles }
            return result
        }
    }
}

/// Reads headline metadata only. No HTML rendering, external entities, enclosures,
/// article downloads or third-party image requests are performed.
final class BriefingXMLParser: NSObject, XMLParserDelegate {
    private let source: BriefingSource
    private let now: Date
    private var depth = 0
    private var itemDepth: Int?
    private var fields: [String: String] = [:]
    private var field: String?
    private var fieldDepth = 0
    private var articles: [BriefingArticle] = []
    private var failure: BriefingError?
    private var candidates = 0
    private var hasFeedRoot = false

    private init(source: BriefingSource, now: Date) {
        self.source = source
        self.now = now
    }

    static func parse(_ data: Data, source: BriefingSource, at now: Date) throws -> [BriefingArticle] {
        try Task.checkCancellation()
        guard data.count <= BriefingFeedClient.maximumBytes else { throw BriefingError.oversized }
        // The configured sources publish UTF-8. Reject other encodings and all DTDs
        // before XMLParser, including internal entity expansion attacks.
        guard let text = String(data: data, encoding: .utf8), !text.contains("\0") else { throw BriefingError.malformed }
        try rejectEntityDeclarations(in: text)
        let delegate = BriefingXMLParser(source: source, now: now)
        let parser = XMLParser(data: data)
        parser.shouldResolveExternalEntities = false
        parser.externalEntityResolvingPolicy = .never
        parser.delegate = delegate
        let succeeded = parser.parse()
        try Task.checkCancellation()
        if let failure = delegate.failure { throw failure }
        guard succeeded, delegate.hasFeedRoot else { throw BriefingError.malformed }
        var seen: Set<String> = []
        let sorted = delegate.articles.sorted {
            $0.publishedAt == $1.publishedAt ? $0.id < $1.id : $0.publishedAt > $1.publishedAt
        }.filter { seen.insert($0.id).inserted }
        guard !sorted.isEmpty else { throw BriefingError.noArticles }
        return Array(sorted.prefix(BriefingFeedClient.articleLimit))
    }

    private static func rejectEntityDeclarations(in text: String) throws {
        // GitHub puts complete HTML documents, including their HTML DOCTYPE,
        // inside RSS CDATA. Those are inert text, not XML declarations. Scan
        // markup linearly, skipping quoted text regions before rejecting DTDs.
        var cursor = text.startIndex
        while cursor < text.endIndex, let opening = text[cursor...].firstIndex(of: "<") {
            let suffix = text[opening...]
            let terminator: String?
            if suffix.hasPrefix("<![CDATA[") { terminator = "]]>" }
            else if suffix.hasPrefix("<!--") { terminator = "-->" }
            else if suffix.hasPrefix("<?") { terminator = "?>" }
            else { terminator = nil }
            if let terminator {
                guard let end = suffix.range(of: terminator) else { throw BriefingError.malformed }
                cursor = end.upperBound
            } else {
                let prefix = suffix.prefix(9).uppercased()
                guard !prefix.hasPrefix("<!DOCTYPE"), !prefix.hasPrefix("<!ENTITY") else { throw BriefingError.unsafeXML }
                cursor = text.index(after: opening)
            }
        }
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes: [String: String] = [:]) {
        depth += 1
        guard depth <= 48, !Task.isCancelled else {
            failure = .malformed
            parser.abortParsing()
            return
        }
        let name = elementName.lowercased()
        if depth == 1 { hasFeedRoot = name == "rss" || name == "feed" }
        if itemDepth == nil, name == "item" || name == "entry" {
            candidates += 1
            guard candidates <= 100 else { failure = .oversized; parser.abortParsing(); return }
            itemDepth = depth
            fields = [:]
        } else if let itemDepth, depth == itemDepth + 1 {
            if ["title", "link", "pubdate", "published", "updated"].contains(name) {
                field = name
                fieldDepth = depth
                // RSS namespaces can contain atom:link; only direct link metadata
                // with the original article's alternate relation is eligible.
                if name == "link", let href = attributes["href"],
                   attributes["rel"] == nil || attributes["rel"] == "alternate" {
                    fields["link"] = String(href.prefix(2_049))
                }
            }
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard let field, depth == fieldDepth else { return }
        let limit = field == "link" ? 2_049 : (field == "title" ? 1_500 : 100)
        let current = fields[field] ?? ""
        guard current.count < limit else { return }
        fields[field] = current + string.prefix(limit - current.count)
    }

    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        if let value = String(data: CDATABlock, encoding: .utf8) { self.parser(parser, foundCharacters: value) }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if depth == fieldDepth { field = nil }
        if itemDepth == depth {
            if let article = makeArticle() { articles.append(article) }
            itemDepth = nil
            fields = [:]
            field = nil
        }
        depth -= 1
    }

    func parser(_ parser: XMLParser, resolveExternalEntityName name: String, systemID: String?) -> Data? { nil }

    private func makeArticle() -> BriefingArticle? {
        guard let rawTitle = fields["title"], let rawLink = fields["link"],
              let url = BriefingArticle.safeURL(rawLink) else { return nil }
        let title = Self.cleanTitle(rawTitle)
        let published = (fields["pubdate"] ?? fields["published"]).flatMap(Self.parseDate)
        let updated = fields["updated"].flatMap(Self.parseDate)
        guard let date = published ?? updated, date <= now.addingTimeInterval(86_400) else { return nil }
        let article = BriefingArticle(source: source, title: title, url: url, publishedAt: date, dateKind: published != nil ? .published : .updated)
        return article.isValid ? article : nil
    }

    private static func cleanTitle(_ raw: String) -> String {
        var title = raw.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        for (entity, value) in [("&#8217;", "’"), ("&#8216;", "‘"), ("&#8220;", "“"), ("&#8221;", "”"), ("&#8211;", "–"), ("&#8212;", "—"), ("&quot;", "\""), ("&apos;", "'"), ("&lt;", "<"), ("&gt;", ">"), ("&nbsp;", " "), ("&amp;", "&")] {
            title = title.replacingOccurrences(of: entity, with: value)
        }
        return title.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.joined(separator: " ")
    }

    static func parseDate(_ raw: String) -> Date? {
        let value = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = iso.date(from: value) { return date }
        iso.formatOptions = [.withInternetDateTime]
        if let date = iso.date(from: value) { return date }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.isLenient = false
        for format in ["EEE, dd MMM yyyy HH:mm:ss Z", "EEE, d MMM yyyy HH:mm:ss zzz", "dd MMM yyyy HH:mm:ss Z"] {
            formatter.dateFormat = format
            if let date = formatter.date(from: value) { return date }
        }
        return nil
    }
}
