import Foundation

enum MeetingProvider: String, CaseIterable, Sendable {
    case zoom
    case googleMeet
    case microsoftTeams
    case webex
    case around
    case whereby
    case other

    var displayName: String {
        switch self {
        case .zoom: "Zoom"
        case .googleMeet: "Google Meet"
        case .microsoftTeams: "Microsoft Teams"
        case .webex: "Webex"
        case .around: "Around"
        case .whereby: "Whereby"
        case .other: "Meeting"
        }
    }

    var actionTitle: String {
        switch self {
        case .googleMeet: "Join Meet"
        case .microsoftTeams: "Join Teams"
        case .other: "Open link"
        default: "Join \(displayName)"
        }
    }

    var actionSystemImage: String {
        self == .other ? "arrow.up.right" : "video.fill"
    }

    var availabilityDescription: String {
        self == .other ? "Event link available" : "\(displayName) link available"
    }
}

struct MeetingLink: Equatable, Sendable {
    let url: URL
    let provider: MeetingProvider
}

enum MeetingLinkResolver {
    /// Resolves an event's most intentional meeting link.
    ///
    /// EventKit's structured URL is authoritative and may point to a meeting
    /// service we do not recognise. Free-form fields are less trustworthy, so
    /// links found there must belong to a known conferencing provider.
    static func resolve(
        eventURL: URL?,
        location: String?,
        notes: String?
    ) -> MeetingLink? {
        if let eventURL, isWebURL(eventURL) {
            return MeetingLink(
                url: eventURL,
                provider: provider(for: eventURL) ?? .other
            )
        }

        for text in [location, notes] {
            guard let text, !text.isEmpty else { continue }
            if let link = firstKnownMeetingLink(in: text) {
                return link
            }
        }

        return nil
    }

    static func provider(for url: URL) -> MeetingProvider? {
        guard let host = url.host?.lowercased().trimmingCharacters(in: CharacterSet(charactersIn: ".")) else {
            return nil
        }

        let provider: MeetingProvider?
        if matches(host, domains: ["zoom.us", "zoom.com", "zoomgov.com"]) {
            provider = .zoom
        } else if matches(host, domains: ["meet.google.com"]) {
            provider = .googleMeet
        } else if matches(host, domains: ["teams.microsoft.com", "teams.live.com", "teams.microsoft.us"]) {
            provider = .microsoftTeams
        } else if matches(host, domains: ["webex.com", "webexgov.com"]) {
            provider = .webex
        } else if matches(host, domains: ["around.co", "around.com"]) {
            provider = .around
        } else if matches(host, domains: ["whereby.com"]) {
            provider = .whereby
        } else {
            provider = nil
        }

        guard let provider, isLikelyMeetingURL(url, provider: provider) else { return nil }
        return provider
    }

    /// Removes recognised meeting URLs while preserving a physical room name
    /// from hybrid locations such as "Room 301 — https://zoom.us/j/…".
    static func physicalLocation(from location: String?) -> String? {
        guard let location = location?.trimmingCharacters(in: .whitespacesAndNewlines),
              !location.isEmpty,
              let detector = try? NSDataDetector(
                  types: NSTextCheckingResult.CheckingType.link.rawValue
              ) else {
            return nil
        }

        let fullRange = NSRange(location.startIndex..<location.endIndex, in: location)
        let meetingRanges = detector.matches(in: location, options: [], range: fullRange)
            .compactMap { match -> NSRange? in
                guard let url = match.url, provider(for: url) != nil else { return nil }
                return match.range
            }

        let mutableLocation = NSMutableString(string: location)
        for range in meetingRanges.reversed() {
            mutableLocation.replaceCharacters(in: range, with: "")
        }
        var result = mutableLocation as String
        result = result.replacingOccurrences(
            of: #"\s{2,}"#,
            with: " ",
            options: .regularExpression
        )
        let separators = CharacterSet.whitespacesAndNewlines
            .union(CharacterSet(charactersIn: "—–-|,;·"))
        let trimmed = result.trimmingCharacters(in: separators)
        return trimmed.isEmpty ? nil : trimmed
    }

    private static func firstKnownMeetingLink(in text: String) -> MeetingLink? {
        guard let detector = try? NSDataDetector(
            types: NSTextCheckingResult.CheckingType.link.rawValue
        ) else {
            return nil
        }

        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        for match in detector.matches(in: text, options: [], range: range) {
            guard let url = match.url,
                  isWebURL(url),
                  let provider = provider(for: url) else {
                continue
            }
            return MeetingLink(url: url, provider: provider)
        }
        return nil
    }

    private static func isWebURL(_ url: URL) -> Bool {
        guard let scheme = url.scheme?.lowercased(),
              scheme == "https" || scheme == "http",
              url.host != nil else {
            return false
        }
        return true
    }

    private static func matches(_ host: String, domains: [String]) -> Bool {
        domains.contains { host == $0 || host.hasSuffix(".\($0)") }
    }

    private static func isLikelyMeetingURL(_ url: URL, provider: MeetingProvider) -> Bool {
        let path = url.path.lowercased()
        let query = url.query?.lowercased() ?? ""

        switch provider {
        case .zoom:
            return ["/j/", "/s/", "/w/", "/my/", "/wc/"].contains { path.hasPrefix($0) }
        case .googleMeet:
            let meetingCodePattern = #"^/[a-z0-9]{3}-[a-z0-9]{4}-[a-z0-9]{3}/?$"#
            return path.hasPrefix("/lookup/")
                || path.range(of: meetingCodePattern, options: .regularExpression) != nil
        case .microsoftTeams:
            return path.hasPrefix("/l/meetup-join/") || path.hasPrefix("/meet/")
        case .webex:
            return path.hasPrefix("/meet/")
                || path.hasPrefix("/join/")
                || path.contains("/meeting/")
                || ((path.hasSuffix("/j.php") || path.hasSuffix("/m.php")) && query.contains("mtid="))
        case .around:
            return path.hasPrefix("/r/") || path.hasPrefix("/room/") || path.hasPrefix("/v/")
        case .whereby:
            guard let room = path.split(separator: "/").first else { return false }
            let reservedPages: Set<Substring> = ["blog", "help", "information", "pricing", "user"]
            return !reservedPages.contains(room)
        case .other:
            return false
        }
    }
}
