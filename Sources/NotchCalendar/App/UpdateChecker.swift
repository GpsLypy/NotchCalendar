import Foundation

enum UpdateStatus: Equatable {
    case ready
    case checking
    case upToDate
    case updateAvailable(version: String, releaseURL: URL, downloadURL: URL?)
    case unavailable(String)
}

enum UpdateDownloadStatus: Equatable {
    case idle
    case downloading
    case downloaded(URL)
    case failed(String)
}

@MainActor
final class UpdateChecker: ObservableObject {
    @Published private(set) var status: UpdateStatus = .ready
    @Published private(set) var downloadStatus: UpdateDownloadStatus = .idle

    var canCheckForUpdates: Bool { UpdateConfiguration.releasesAPIURL != nil }

    func checkForUpdates() async {
        guard let url = UpdateConfiguration.releasesAPIURL else {
            status = .unavailable("The release source has not been configured yet.")
            return
        }

        status = .checking
        downloadStatus = .idle
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

            let downloadURL = release.assets
                .first(where: { $0.name.lowercased().hasSuffix(".dmg") })
                .flatMap { URL(string: $0.browserDownloadURL) }

            if Self.isNewer(release.tagName, than: UpdateConfiguration.currentVersion) {
                status = .updateAvailable(
                    version: release.tagName,
                    releaseURL: releaseURL,
                    downloadURL: downloadURL
                )
            } else {
                status = .upToDate
            }
        } catch {
            status = .unavailable("Could not check for updates. Try again later.")
        }
    }

    func downloadUpdate() async -> URL? {
        guard case let .updateAvailable(_, _, downloadURL) = status,
              let downloadURL else {
            downloadStatus = .failed("This release does not include a DMG download.")
            return nil
        }

        downloadStatus = .downloading

        do {
            var request = URLRequest(url: downloadURL)
            request.setValue("NotchCalendar", forHTTPHeaderField: "User-Agent")
            request.timeoutInterval = 120

            let (temporaryURL, response) = try await URLSession.shared.download(for: request)
            guard let response = response as? HTTPURLResponse,
                  (200..<300).contains(response.statusCode) else {
                throw UpdateError.invalidResponse
            }

            let proposedName = response.suggestedFilename ?? downloadURL.lastPathComponent
            let fileName = URL(fileURLWithPath: proposedName).lastPathComponent
            let destinationURL = try Self.availableDownloadURL(for: fileName)
            try FileManager.default.moveItem(at: temporaryURL, to: destinationURL)
            downloadStatus = .downloaded(destinationURL)
            return destinationURL
        } catch {
            downloadStatus = .failed("The download failed. Try again or open the release page.")
            return nil
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

    private static func availableDownloadURL(for fileName: String) throws -> URL {
        guard let downloadsDirectory = FileManager.default.urls(
            for: .downloadsDirectory,
            in: .userDomainMask
        ).first else {
            throw UpdateError.downloadsDirectoryUnavailable
        }

        let fallbackName = "NotchCalendar-update.dmg"
        let safeName = fileName.isEmpty ? fallbackName : fileName
        let sourceURL = URL(fileURLWithPath: safeName)
        let stem = sourceURL.deletingPathExtension().lastPathComponent
        let fileExtension = sourceURL.pathExtension
        var destinationURL = downloadsDirectory.appendingPathComponent(safeName)
        var suffix = 2

        while FileManager.default.fileExists(atPath: destinationURL.path) {
            let candidateName = fileExtension.isEmpty
                ? "\(stem)-\(suffix)"
                : "\(stem)-\(suffix).\(fileExtension)"
            destinationURL = downloadsDirectory.appendingPathComponent(candidateName)
            suffix += 1
        }

        return destinationURL
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
    let assets: [GitHubReleaseAsset]

    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
        case htmlURL = "html_url"
        case assets
    }
}

private struct GitHubReleaseAsset: Decodable {
    let name: String
    let browserDownloadURL: String

    enum CodingKeys: String, CodingKey {
        case name
        case browserDownloadURL = "browser_download_url"
    }
}

private enum UpdateError: Error {
    case invalidResponse
    case downloadsDirectoryUnavailable
}
