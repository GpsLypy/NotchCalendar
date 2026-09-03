import AppKit
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
    case downloading(UpdateDownloadProgress)
    case downloaded(URL)
    case failed(String)
}

enum UpdateInstallationStatus: Equatable {
    case idle
    case preparing
    case relaunching
    case failed(String)
}

struct UpdateDownloadProgress: Equatable {
    let bytesReceived: Int64
    let totalBytes: Int64?

    var fraction: Double? {
        guard let totalBytes, totalBytes > 0 else { return nil }
        return min(max(Double(bytesReceived) / Double(totalBytes), 0), 1)
    }

    var percentage: Int? {
        fraction.map { Int(($0 * 100).rounded()) }
    }
}

@MainActor
final class UpdateChecker: ObservableObject {
    @Published private(set) var status: UpdateStatus = .ready
    @Published private(set) var downloadStatus: UpdateDownloadStatus = .idle
    @Published private(set) var installationStatus: UpdateInstallationStatus = .idle
    @Published private(set) var automaticInstallCapability: AutomaticInstallCapability = .unknown
    @Published private(set) var installedApplicationsVersion: String?

    private var availableUpdate: AvailableUpdate?
    private var downloadedArtifact: DownloadedUpdateArtifact?

    init() {
        let currentBundleURL = Bundle.main.bundleURL
        let rawVersion = UpdateConfiguration.currentVersion
        let bundleIdentifier = Bundle.main.bundleIdentifier
        Task { [weak self] in
            guard let currentVersion = AppVersion(rawVersion),
                  let bundleIdentifier else { return }
            let installedVersion = await Task.detached(priority: .utility) {
                UpdateInstaller.verifiedInstalledApplicationsCopyVersion(
                    currentBundleURL: currentBundleURL,
                    currentVersion: currentVersion,
                    bundleIdentifier: bundleIdentifier
                )
            }.value
            self?.installedApplicationsVersion = installedVersion
        }
    }

    var canCheckForUpdates: Bool { UpdateConfiguration.releasesAPIURL != nil }
    var isDownloading: Bool {
        if case .downloading = downloadStatus { return true }
        return false
    }
    var isInstalling: Bool {
        switch installationStatus {
        case .preparing, .relaunching: true
        case .idle, .failed: false
        }
    }
    var downloadedUpdateURL: URL? {
        guard case let .downloaded(url) = downloadStatus else { return nil }
        return url
    }
    var canInstallDownloadedUpdate: Bool {
        downloadedArtifact != nil
            && automaticInstallCapability == .supported
            && !isInstalling
    }
    var isCheckingInstallCapability: Bool {
        automaticInstallCapability == .checking
    }
    var isRunningFromReadOnlyVolume: Bool {
        (try? Bundle.main.bundleURL.resourceValues(forKeys: [.volumeIsReadOnlyKey]))?
            .volumeIsReadOnly == true
    }
    func checkForUpdates() async {
        guard let url = UpdateConfiguration.releasesAPIURL else {
            status = .unavailable("The release source has not been configured yet.")
            return
        }

        status = .checking
        downloadStatus = .idle
        installationStatus = .idle
        automaticInstallCapability = .unknown
        availableUpdate = nil
        downloadedArtifact = nil
        do {
            var request = URLRequest(url: url)
            request.setValue("NotchCalendar", forHTTPHeaderField: "User-Agent")
            request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
            request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
            request.timeoutInterval = 12
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw UpdateError.invalidResponse
            }

            let release = try JSONDecoder().decode(GitHubRelease.self, from: data)
            guard let releaseURL = URL(string: release.htmlURL) else {
                throw UpdateError.invalidResponse
            }

            guard let remoteVersion = AppVersion(release.tagName),
                  let currentVersion = AppVersion(UpdateConfiguration.currentVersion) else {
                throw UpdateError.invalidVersion
            }

            let trustedAssets = release.assets.compactMap { asset -> (GitHubReleaseAsset, URL)? in
                guard let downloadURL = URL(string: asset.browserDownloadURL),
                      ReleaseAssetSelector.trustedDMGURL(
                        assetName: asset.name,
                        downloadURL: downloadURL,
                        releaseTag: release.tagName,
                        repository: UpdateConfiguration.githubRepository ?? ""
                      ) != nil else {
                    return nil
                }
                return (asset, downloadURL)
            }
            let trustedAsset = trustedAssets.count == 1 ? trustedAssets[0] : nil

            if currentVersion < remoteVersion {
                if let trustedAsset {
                    availableUpdate = AvailableUpdate(
                        version: remoteVersion,
                        releaseTag: release.tagName,
                        assetName: trustedAsset.0.name,
                        downloadURL: trustedAsset.1,
                        expectedSHA256: UpdateFileDigest.parseGitHubSHA256(
                            trustedAsset.0.digest
                        )
                    )
                }
                status = .updateAvailable(
                    version: remoteVersion.description,
                    releaseURL: releaseURL,
                    downloadURL: trustedAsset?.1
                )
            } else {
                status = .upToDate
            }
        } catch {
            status = .unavailable("Could not check for updates. Try again later.")
        }
    }

    func downloadUpdate() async -> URL? {
        guard let availableUpdate else {
            downloadStatus = .failed("This release does not include the expected repository DMG.")
            return nil
        }

        downloadStatus = .downloading(
            UpdateDownloadProgress(bytesReceived: 0, totalBytes: nil)
        )

        do {
            var request = URLRequest(url: availableUpdate.downloadURL)
            request.setValue("NotchCalendar", forHTTPHeaderField: "User-Agent")
            request.timeoutInterval = 120

            let operation = UpdateDownloadOperation { [weak self] bytesReceived, totalBytes in
                Task { @MainActor [weak self] in
                    guard let self, self.isDownloading else { return }
                    self.downloadStatus = .downloading(
                        UpdateDownloadProgress(
                            bytesReceived: bytesReceived,
                            totalBytes: totalBytes
                        )
                    )
                }
            }
            let destinationURL = try await operation.download(
                request,
                fileName: availableUpdate.assetName
            )
            let digest = try await Task.detached(priority: .userInitiated) {
                try UpdateFileDigest.sha256(of: destinationURL)
            }.value
            if let expectedSHA256 = availableUpdate.expectedSHA256 {
                guard digest == expectedSHA256 else {
                    try? FileManager.default.removeItem(at: destinationURL)
                    throw UpdateError.digestMismatch
                }
                downloadedArtifact = DownloadedUpdateArtifact(
                    fileURL: destinationURL,
                    sourceURL: availableUpdate.downloadURL,
                    assetName: availableUpdate.assetName,
                    releaseTag: availableUpdate.releaseTag,
                    version: availableUpdate.version,
                    expectedSHA256: expectedSHA256
                )
                installationStatus = .idle
                automaticInstallCapability = .checking
            } else {
                downloadedArtifact = nil
                automaticInstallCapability = .manualOnly(
                    "This release does not publish a valid SHA-256 digest. Open the DMG to install it manually."
                )
            }
            downloadStatus = .downloaded(destinationURL)
            if downloadedArtifact != nil {
                if let bundleIdentifier = Bundle.main.bundleIdentifier {
                    let currentBundleURL = Bundle.main.bundleURL
                    automaticInstallCapability = await Task.detached(priority: .utility) {
                        UpdateInstaller.automaticInstallationCapability(
                            currentBundleURL: currentBundleURL,
                            bundleIdentifier: bundleIdentifier
                        )
                    }.value
                } else {
                    automaticInstallCapability = .manualOnly(
                        "This build has no application identifier, so it must be installed manually."
                    )
                }
            }
            return destinationURL
        } catch UpdateError.digestMismatch {
            downloadedArtifact = nil
            automaticInstallCapability = .manualOnly(
                "The DMG did not match GitHub’s published SHA-256 digest. Download it again."
            )
            downloadStatus = .failed(
                "The DMG failed its SHA-256 check and was removed."
            )
            return nil
        } catch {
            downloadStatus = .failed("The download failed. Try again or open the release page.")
            return nil
        }
    }

    func installAndRelaunch() async {
        guard let artifact = downloadedArtifact,
              let repository = UpdateConfiguration.githubRepository,
              let currentVersion = AppVersion(UpdateConfiguration.currentVersion),
              let bundleIdentifier = Bundle.main.bundleIdentifier else {
            installationStatus = .failed("The downloaded update is no longer available. Download it again.")
            return
        }

        installationStatus = .preparing
        let request = UpdateInstallRequest(
            artifact: artifact,
            repository: repository,
            currentVersion: currentVersion,
            currentBundleURL: Bundle.main.bundleURL,
            bundleIdentifier: bundleIdentifier
        )

        do {
            let prepared = try await Task.detached(priority: .userInitiated) {
                try UpdateInstaller.prepare(request)
            }.value
            do {
                try await Task.detached(priority: .userInitiated) {
                    try UpdateInstaller.launchHelper(prepared)
                }.value
            } catch {
                UpdateInstaller.discard(prepared)
                throw error
            }
            installationStatus = .relaunching
            NSApp.terminate(nil)
        } catch {
            installationStatus = .failed(
                (error as? LocalizedError)?.errorDescription
                    ?? "The update could not be prepared. This app was not changed."
            )
        }
    }

    func revealDownloadedUpdate() {
        guard let downloadedUpdateURL else { return }
        NSWorkspace.shared.activateFileViewerSelecting([downloadedUpdateURL])
    }

    func openDMGAndQuit() {
        guard let downloadedUpdateURL else { return }
        NSWorkspace.shared.open(
            downloadedUpdateURL,
            configuration: NSWorkspace.OpenConfiguration()
        ) { _, error in
            Task { @MainActor [weak self] in
                if let error {
                    self?.installationStatus = .failed(
                        "The DMG could not be opened: \(error.localizedDescription)"
                    )
                } else {
                    NSApp.terminate(nil)
                }
            }
        }
    }

    func openInstalledApplicationsCopyAndQuit() {
        guard let currentVersion = AppVersion(UpdateConfiguration.currentVersion),
              let bundleIdentifier = Bundle.main.bundleIdentifier else { return }
        do {
            try UpdateInstaller.launchInstalledApplicationsCopyAfterCurrentProcessExits(
                currentBundleURL: Bundle.main.bundleURL,
                currentVersion: currentVersion,
                bundleIdentifier: bundleIdentifier
            )
            NSApp.terminate(nil)
        } catch {
            installationStatus = .failed(
                (error as? LocalizedError)?.errorDescription
                    ?? "The Applications copy could not be opened."
            )
        }
    }
}

private struct AvailableUpdate {
    let version: AppVersion
    let releaseTag: String
    let assetName: String
    let downloadURL: URL
    let expectedSHA256: String?
}

private final class UpdateDownloadOperation: NSObject, URLSessionDownloadDelegate, @unchecked Sendable {
    typealias ProgressHandler = @Sendable (_ bytesReceived: Int64, _ totalBytes: Int64?) -> Void

    private let progressHandler: ProgressHandler
    private let lock = NSLock()
    private var continuation: CheckedContinuation<URL, Error>?
    private var session: URLSession?
    private var destinationFileName = "NotchCalendar-update.dmg"

    init(progressHandler: @escaping ProgressHandler) {
        self.progressHandler = progressHandler
    }

    func download(_ request: URLRequest, fileName: String) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            let session = URLSession(
                configuration: .ephemeral,
                delegate: self,
                delegateQueue: nil
            )

            lock.lock()
            self.continuation = continuation
            self.session = session
            destinationFileName = fileName
            lock.unlock()

            session.downloadTask(with: request).resume()
        }
    }

    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        if totalBytesWritten > UpdateInstaller.maximumDMGSize
            || totalBytesExpectedToWrite > UpdateInstaller.maximumDMGSize {
            downloadTask.cancel()
            finish(with: .failure(UpdateError.downloadTooLarge))
            return
        }
        let totalBytes = totalBytesExpectedToWrite > 0 ? totalBytesExpectedToWrite : nil
        progressHandler(totalBytesWritten, totalBytes)
    }

    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        do {
            guard let response = downloadTask.response as? HTTPURLResponse,
                  (200..<300).contains(response.statusCode) else {
                throw UpdateError.invalidResponse
            }

            let destinationURL = try UpdateDownloadDestination.availableURL(
                for: destinationFileName
            )
            try FileManager.default.moveItem(at: location, to: destinationURL)
            finish(with: .success(destinationURL))
        } catch {
            finish(with: .failure(error))
        }
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
        if let error {
            finish(with: .failure(error))
        }
    }

    private func finish(with result: Result<URL, Error>) {
        lock.lock()
        guard let continuation else {
            lock.unlock()
            return
        }
        self.continuation = nil
        let activeSession = session
        session = nil
        lock.unlock()

        continuation.resume(with: result)
        activeSession?.finishTasksAndInvalidate()
    }
}

private enum UpdateDownloadDestination {
    static func availableURL(for fileName: String) throws -> URL {
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
    static var currentVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0.0"
    }

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
    let digest: String?

    enum CodingKeys: String, CodingKey {
        case name
        case browserDownloadURL = "browser_download_url"
        case digest
    }
}

private enum UpdateError: Error {
    case invalidResponse
    case invalidVersion
    case downloadTooLarge
    case digestMismatch
    case downloadsDirectoryUnavailable
}
