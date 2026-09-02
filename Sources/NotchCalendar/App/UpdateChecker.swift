import Foundation

enum UpdateStatus: Equatable {
    case ready
    case checking
    case upToDate
    case updateAvailable(version: String, releaseURL: URL)
    case unavailable(String)
}

@MainActor
final class UpdateChecker: ObservableObject {
    @Published private(set) var status: UpdateStatus = .ready

    var canCheckForUpdates: Bool { UpdateConfiguration.releasesAPIURL != nil }

    func checkForUpdates() async {
        guard let url = UpdateConfiguration.releasesAPIURL else {
            status = .unavailable("The release source has not been configured yet.")
            return
        }

        status = .checking
        do {
            var request = URLRequest(url: url)
            request.setValue("NotchCalendar", forHTTPHeaderField: "User-Agent")
            request.timeoutInterval = 12
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw UpdateError.invalidResponse
            }

            let release = try JSONDecoder().decode(GitHubRelease.self, from: data)
            guard let releaseURL = URL(string: release.htmlURL) else {
                throw UpdateError.invalidResponse
            }

            if Self.isNewer(release.tagName, than: UpdateConfiguration.currentVersion) {
                status = .updateAvailable(version: release.tagName, releaseURL: releaseURL)
            } else {
                status = .upToDate
            }
        } catch {
            status = .unavailable("Could not check for updates. Try again later.")
        }
    }

    private static func isNewer(_ remoteVersion: String, than localVersion: String) -> Bool {
        let remote = versionComponents(remoteVersion)
        let local = versionComponents(localVersion)
        let count = max(remote.count, local.count)

        for index in 0..<count {
            let remotePart = index < remote.count ? remote[index] : 0
            let localPart = index < local.count ? local[index] : 0
            if remotePart != localPart { return remotePart > localPart }
        }
        return false
    }

    private static func versionComponents(_ version: String) -> [Int] {
        version.split(whereSeparator: { !$0.isNumber }).compactMap { Int($0) }
    }
}

private enum UpdateConfiguration {
    static let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0.0"

    static let githubRepository: String? = {
        guard let repository = Bundle.main.object(forInfoDictionaryKey: "NotchCalendarGitHubRepository") as? String else {
            return nil
        }
        let trimmed = repository.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !trimmed.contains("YOUR_GITHUB") else { return nil }
        return trimmed
    }()

    static var githubURL: URL? {
        guard let githubRepository else { return nil }
        return URL(string: "https://github.com/\(githubRepository)")
    }

    static var releasesAPIURL: URL? {
        guard let githubRepository else { return nil }
        return URL(string: "https://api.github.com/repos/\(githubRepository)/releases/latest")
    }
}

private struct GitHubRelease: Decodable {
    let tagName: String
    let htmlURL: String

    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
        case htmlURL = "html_url"
    }
}

private enum UpdateError: Error {
    case invalidResponse
}
