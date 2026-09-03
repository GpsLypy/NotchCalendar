import CryptoKit
import Foundation

struct AppVersion: Comparable, CustomStringConvertible, Sendable {
    let components: [Int]

    init?(_ rawValue: String) {
        guard rawValue == rawValue.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return nil
        }

        let version = rawValue.hasPrefix("v") ? String(rawValue.dropFirst()) : rawValue
        let parts = version.split(separator: ".", omittingEmptySubsequences: false)
        guard (1...4).contains(parts.count) else { return nil }

        var parsed: [Int] = []
        parsed.reserveCapacity(parts.count)
        for part in parts {
            guard !part.isEmpty,
                  part.allSatisfy(\.isNumber),
                  (part.count == 1 || part.first != "0"),
                  let value = Int(part) else {
                return nil
            }
            parsed.append(value)
        }
        components = parsed
    }

    var description: String {
        components.map(String.init).joined(separator: ".")
    }

    static func == (lhs: AppVersion, rhs: AppVersion) -> Bool {
        compare(lhs, rhs) == 0
    }

    static func < (lhs: AppVersion, rhs: AppVersion) -> Bool {
        compare(lhs, rhs) < 0
    }

    private static func compare(_ lhs: AppVersion, _ rhs: AppVersion) -> Int {
        let count = max(lhs.components.count, rhs.components.count)
        for index in 0..<count {
            let left = index < lhs.components.count ? lhs.components[index] : 0
            let right = index < rhs.components.count ? rhs.components[index] : 0
            if left != right { return left < right ? -1 : 1 }
        }
        return 0
    }
}

enum ReleaseAssetSelector {
    static func expectedDMGName(for version: AppVersion) -> String {
        "NotchCalendar-\(version)-macos.dmg"
    }

    static func trustedDMGURL(
        assetName: String,
        downloadURL: URL,
        releaseTag: String,
        repository: String
    ) -> URL? {
        guard let version = AppVersion(releaseTag),
              assetName == expectedDMGName(for: version) else {
            return nil
        }

        let repositoryParts = repository.split(separator: "/", omittingEmptySubsequences: false)
        guard repositoryParts.count == 2,
              repositoryParts.allSatisfy({ !$0.isEmpty && $0.allSatisfy(isRepositoryCharacter) }),
              let components = URLComponents(url: downloadURL, resolvingAgainstBaseURL: false),
              components.scheme == "https",
              components.host?.lowercased() == "github.com",
              components.port == nil,
              components.user == nil,
              components.password == nil,
              components.query == nil,
              components.fragment == nil else {
            return nil
        }

        let expectedPath = "/\(repositoryParts[0])/\(repositoryParts[1])/releases/download/\(releaseTag)/\(assetName)"
        guard components.percentEncodedPath == expectedPath else { return nil }
        return downloadURL
    }

    private static func isRepositoryCharacter(_ character: Character) -> Bool {
        character.isASCII && (character.isLetter || character.isNumber || ".-_".contains(character))
    }
}

struct DownloadedUpdateArtifact: Equatable, Sendable {
    let fileURL: URL
    let sourceURL: URL
    let assetName: String
    let releaseTag: String
    let version: AppVersion
    let expectedSHA256: String
}

enum UpdateFileDigest {
    static func parseGitHubSHA256(_ digest: String?) -> String? {
        guard let digest, digest.hasPrefix("sha256:") else { return nil }
        let value = String(digest.dropFirst("sha256:".count))
        guard value.count == 64,
              value.allSatisfy({
                  $0.isASCII && ($0.isNumber || "abcdefABCDEF".contains($0))
              }) else {
            return nil
        }
        return value.lowercased()
    }

    static func sha256(of fileURL: URL) throws -> String {
        let handle = try FileHandle(forReadingFrom: fileURL)
        defer { try? handle.close() }

        var digest = SHA256()
        while let data = try handle.read(upToCount: 1024 * 1024), !data.isEmpty {
            digest.update(data: data)
        }
        return digest.finalize().map { String(format: "%02x", $0) }.joined()
    }
}

struct UpdateInstallRequest: Sendable {
    let artifact: DownloadedUpdateArtifact
    let repository: String
    let currentVersion: AppVersion
    let currentBundleURL: URL
    let bundleIdentifier: String
}

enum AutomaticInstallCapability: Equatable, Sendable {
    case unknown
    case checking
    case supported
    case manualOnly(String)
}

struct PreparedUpdate: Sendable {
    let helperURL: URL
    let stagedAppURL: URL
    let destinationAppURL: URL
    let currentBundleURL: URL
    let downloadedDMGURL: URL
    let handoffDirectoryURL: URL
    let helperReadyURL: URL
    let launchReadyURL: URL
    let expectedVersion: AppVersion
    let teamIdentifier: String
    let token: UUID

    var helperArguments: [String] {
        [
            "--perform-install",
            String(ProcessInfo.processInfo.processIdentifier),
            stagedAppURL.path,
            destinationAppURL.path,
            currentBundleURL.path,
            downloadedDMGURL.path,
            expectedVersion.description,
            teamIdentifier,
            token.uuidString.lowercased(),
            handoffDirectoryURL.path
        ]
    }
}

enum UpdateInstaller {
    static let maximumDMGSize: Int64 = 512 * 1024 * 1024
    static let appName = "Notch Calendar.app"
    static let updaterIdentifier = "com.codex.notch-calendar.updater"
    // Automatic replacement stays fail-closed until interrupted transactions
    // can be recovered durably after a helper crash or machine restart.
    private static let automaticReplacementEnabled = false

    static func prepare(_ request: UpdateInstallRequest) throws -> PreparedUpdate {
        guard automaticReplacementEnabled else {
            throw UpdateInstallError.automaticReplacementDisabled
        }
        guard request.currentVersion < request.artifact.version else {
            throw UpdateInstallError.versionIsNotNewer
        }
        guard ReleaseAssetSelector.trustedDMGURL(
            assetName: request.artifact.assetName,
            downloadURL: request.artifact.sourceURL,
            releaseTag: request.artifact.releaseTag,
            repository: request.repository
        ) != nil else {
            throw UpdateInstallError.untrustedReleaseAsset
        }

        try validateRegularFile(request.artifact.fileURL, maximumSize: maximumDMGSize)
        guard try UpdateFileDigest.sha256(of: request.artifact.fileURL)
            == request.artifact.expectedSHA256 else {
            throw UpdateInstallError.downloadChanged
        }

        let currentIdentity = try UpdateBundleIdentity.load(
            appURL: request.currentBundleURL,
            expectedBundleIdentifier: request.bundleIdentifier
        )
        guard currentIdentity.version == request.currentVersion else {
            throw UpdateInstallError.currentVersionChanged
        }

        let currentSignature = try CodeSignatureVerifier.inspect(request.currentBundleURL)
        guard currentSignature.identifier == request.bundleIdentifier,
              CodeSignatureVerifier.isDeveloperTeamIdentifier(currentSignature.teamIdentifier) else {
            throw UpdateInstallError.developerIDSignedBuildRequired
        }
        try CodeSignatureVerifier.verify(
            request.currentBundleURL,
            identifier: request.bundleIdentifier,
            teamIdentifier: currentSignature.teamIdentifier,
            assessWithGatekeeper: true
        )

        let token = UUID()
        let tokenString = token.uuidString.lowercased()
        let fileManager = FileManager.default
        let temporaryRoot = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .standardizedFileURL
        let handoffDirectory = temporaryRoot
            .appendingPathComponent("NotchCalendar-update-\(tokenString)", isDirectory: true)
        try fileManager.createDirectory(
            at: handoffDirectory,
            withIntermediateDirectories: false,
            attributes: [.posixPermissions: 0o700]
        )

        let privateDMG = handoffDirectory.appendingPathComponent("update.dmg")
        let mountRoot = handoffDirectory.appendingPathComponent("mount", isDirectory: true)
        let destinationApp = URL(fileURLWithPath: "/Applications", isDirectory: true)
            .appendingPathComponent(appName, isDirectory: true)
        let stagedApp = URL(fileURLWithPath: "/Applications", isDirectory: true)
            .appendingPathComponent(".Notch Calendar.update-\(tokenString).app", isDirectory: true)
        var keepPreparedFiles = false

        defer {
            if !keepPreparedFiles {
                try? fileManager.removeItem(at: stagedApp)
                try? fileManager.removeItem(at: handoffDirectory)
            }
        }

        try fileManager.copyItem(at: request.artifact.fileURL, to: privateDMG)
        try validateRegularFile(privateDMG, maximumSize: maximumDMGSize)
        guard try UpdateFileDigest.sha256(of: privateDMG)
            == request.artifact.expectedSHA256 else {
            throw UpdateInstallError.downloadChanged
        }

        _ = try UpdateCommand.run("/usr/bin/hdiutil", ["verify", privateDMG.path])
        try fileManager.createDirectory(
            at: mountRoot,
            withIntermediateDirectories: false,
            attributes: [.posixPermissions: 0o700]
        )
        let mount = try attachDMG(privateDMG, beneath: mountRoot)
        var needsDetach = true
        defer {
            if needsDetach {
                _ = try? UpdateCommand.run("/usr/bin/hdiutil", ["detach", mount.mountPoint.path])
            }
        }

        let candidateApp = try candidateApp(in: mount.mountPoint)
        let candidateIdentity = try UpdateBundleIdentity.load(
            appURL: candidateApp,
            expectedBundleIdentifier: request.bundleIdentifier
        )
        guard candidateIdentity.version == request.artifact.version else {
            throw UpdateInstallError.unexpectedCandidateVersion
        }
        try CodeSignatureVerifier.verify(
            candidateApp,
            identifier: request.bundleIdentifier,
            teamIdentifier: currentSignature.teamIdentifier,
            assessWithGatekeeper: true
        )

        if fileManager.fileExists(atPath: destinationApp.path),
           destinationApp.resolvingSymlinksInPath() != request.currentBundleURL.resolvingSymlinksInPath() {
            let installedIdentity = try UpdateBundleIdentity.load(
                appURL: destinationApp,
                expectedBundleIdentifier: request.bundleIdentifier
            )
            guard installedIdentity.version <= request.artifact.version else {
                throw UpdateInstallError.newerVersionAlreadyInstalled
            }
            try CodeSignatureVerifier.verify(
                destinationApp,
                identifier: request.bundleIdentifier,
                teamIdentifier: currentSignature.teamIdentifier,
                assessWithGatekeeper: true
            )
        }

        try fileManager.copyItem(at: candidateApp, to: stagedApp)
        let stagedIdentity = try UpdateBundleIdentity.load(
            appURL: stagedApp,
            expectedBundleIdentifier: request.bundleIdentifier
        )
        guard stagedIdentity == candidateIdentity else {
            throw UpdateInstallError.stagedCopyChanged
        }
        try CodeSignatureVerifier.verify(
            stagedApp,
            identifier: request.bundleIdentifier,
            teamIdentifier: currentSignature.teamIdentifier,
            assessWithGatekeeper: true
        )

        _ = try UpdateCommand.run("/usr/bin/hdiutil", ["detach", mount.mountPoint.path])
        needsDetach = false
        try? fileManager.removeItem(at: privateDMG)
        try? fileManager.removeItem(at: mountRoot)

        let bundledHelper = request.currentBundleURL
            .appendingPathComponent("Contents/Helpers/NotchCalendarUpdater", isDirectory: false)
        try validateRegularFile(bundledHelper, maximumSize: 64 * 1024 * 1024)
        try CodeSignatureVerifier.verify(
            bundledHelper,
            identifier: updaterIdentifier,
            teamIdentifier: currentSignature.teamIdentifier,
            assessWithGatekeeper: false
        )
        let privateHelper = handoffDirectory
            .appendingPathComponent("NotchCalendarUpdater", isDirectory: false)
        try fileManager.copyItem(at: bundledHelper, to: privateHelper)
        try fileManager.setAttributes(
            [.posixPermissions: 0o700],
            ofItemAtPath: privateHelper.path
        )
        try validateRegularFile(privateHelper, maximumSize: 64 * 1024 * 1024)
        try CodeSignatureVerifier.verify(
            privateHelper,
            identifier: updaterIdentifier,
            teamIdentifier: currentSignature.teamIdentifier,
            assessWithGatekeeper: false
        )
        keepPreparedFiles = true
        return PreparedUpdate(
            helperURL: privateHelper,
            stagedAppURL: stagedApp,
            destinationAppURL: destinationApp,
            currentBundleURL: request.currentBundleURL,
            downloadedDMGURL: request.artifact.fileURL,
            handoffDirectoryURL: handoffDirectory,
            helperReadyURL: handoffDirectory.appendingPathComponent("helper-ready"),
            launchReadyURL: handoffDirectory.appendingPathComponent("launch-ready"),
            expectedVersion: request.artifact.version,
            teamIdentifier: currentSignature.teamIdentifier,
            token: token
        )
    }

    static func automaticInstallationCapability(
        currentBundleURL: URL,
        bundleIdentifier: String
    ) -> AutomaticInstallCapability {
        guard automaticReplacementEnabled else {
            return .manualOnly(
                "Automatic replacement is not enabled in this version. Open the verified DMG to install safely."
            )
        }
        do {
            _ = try UpdateBundleIdentity.load(
                appURL: currentBundleURL,
                expectedBundleIdentifier: bundleIdentifier
            )
            let signature = try CodeSignatureVerifier.inspect(currentBundleURL)
            guard signature.identifier == bundleIdentifier,
                  CodeSignatureVerifier.isDeveloperTeamIdentifier(signature.teamIdentifier) else {
                return .manualOnly(
                    "This build is not signed with a Developer ID, so macOS requires manual installation."
                )
            }
            try CodeSignatureVerifier.verify(
                currentBundleURL,
                identifier: bundleIdentifier,
                teamIdentifier: signature.teamIdentifier,
                assessWithGatekeeper: true
            )

            let helper = currentBundleURL
                .appendingPathComponent("Contents/Helpers/NotchCalendarUpdater")
            try validateRegularFile(helper, maximumSize: 64 * 1024 * 1024)
            try CodeSignatureVerifier.verify(
                helper,
                identifier: updaterIdentifier,
                teamIdentifier: signature.teamIdentifier,
                assessWithGatekeeper: false
            )
            return .supported
        } catch let error as UpdateInstallError {
            return .manualOnly(
                error.errorDescription
                    ?? "This build requires manual update installation."
            )
        } catch {
            return .manualOnly("This build requires manual update installation.")
        }
    }

    static func launchHelper(_ update: PreparedUpdate) throws {
        let process = Process()
        process.executableURL = update.helperURL
        process.arguments = update.helperArguments
        try process.run()

        let deadline = Date().addingTimeInterval(15)
        while Date() < deadline {
            if FileManager.default.fileExists(atPath: update.helperReadyURL.path) {
                return
            }
            if !process.isRunning {
                throw UpdateInstallError.helperRejectedInstall
            }
            usleep(50_000)
        }
        if process.isRunning {
            process.terminate()
            process.waitUntilExit()
        }
        throw UpdateInstallError.helperDidNotBecomeReady
    }

    static func discard(_ update: PreparedUpdate) {
        try? FileManager.default.removeItem(at: update.stagedAppURL)
        try? FileManager.default.removeItem(at: update.handoffDirectoryURL)
    }

    static func launchInstalledApplicationsCopyAfterCurrentProcessExits(
        currentBundleURL: URL,
        currentVersion: AppVersion,
        bundleIdentifier: String
    ) throws {
        let validated = try validatedInstalledApplicationsCopy(
            currentBundleURL: currentBundleURL,
            currentVersion: currentVersion,
            bundleIdentifier: bundleIdentifier
        )
        let process = Process()
        process.executableURL = validated.helperURL
        process.arguments = [
            "--launch-installed-copy",
            String(ProcessInfo.processInfo.processIdentifier),
            currentVersion.description,
            validated.teamIdentifier
        ]
        try process.run()
        usleep(100_000)
        guard process.isRunning else {
            throw UpdateInstallError.helperRejectedInstall
        }
    }

    static func verifiedInstalledApplicationsCopyVersion(
        currentBundleURL: URL,
        currentVersion: AppVersion,
        bundleIdentifier: String
    ) -> String? {
        try? validatedInstalledApplicationsCopy(
            currentBundleURL: currentBundleURL,
            currentVersion: currentVersion,
            bundleIdentifier: bundleIdentifier
        ).identity.versionString
    }

    private static func validatedInstalledApplicationsCopy(
        currentBundleURL: URL,
        currentVersion: AppVersion,
        bundleIdentifier: String
    ) throws -> ValidatedInstalledCopy {
        let currentSignature = try CodeSignatureVerifier.inspect(currentBundleURL)
        guard currentSignature.identifier == bundleIdentifier,
              CodeSignatureVerifier.isDeveloperTeamIdentifier(currentSignature.teamIdentifier) else {
            throw UpdateInstallError.developerIDSignedBuildRequired
        }
        try CodeSignatureVerifier.verify(
            currentBundleURL,
            identifier: bundleIdentifier,
            teamIdentifier: currentSignature.teamIdentifier,
            assessWithGatekeeper: true
        )

        let destination = URL(fileURLWithPath: "/Applications", isDirectory: true)
            .appendingPathComponent(appName, isDirectory: true)
        let installed = try UpdateBundleIdentity.load(
            appURL: destination,
            expectedBundleIdentifier: bundleIdentifier
        )
        guard installed.version >= currentVersion else {
            throw UpdateInstallError.installedCopyIsOlder
        }
        try CodeSignatureVerifier.verify(
            destination,
            identifier: bundleIdentifier,
            teamIdentifier: currentSignature.teamIdentifier,
            assessWithGatekeeper: true
        )

        let helper = currentBundleURL
            .appendingPathComponent("Contents/Helpers/NotchCalendarUpdater", isDirectory: false)
        try validateRegularFile(helper, maximumSize: 64 * 1024 * 1024)
        try CodeSignatureVerifier.verify(
            helper,
            identifier: updaterIdentifier,
            teamIdentifier: currentSignature.teamIdentifier,
            assessWithGatekeeper: false
        )
        return ValidatedInstalledCopy(
            identity: installed,
            helperURL: helper,
            teamIdentifier: currentSignature.teamIdentifier
        )
    }

    private static func candidateApp(in mountPoint: URL) throws -> URL {
        let children = try FileManager.default.contentsOfDirectory(
            at: mountPoint,
            includingPropertiesForKeys: [.isDirectoryKey, .isSymbolicLinkKey],
            options: []
        )
        let applications = children.filter { $0.pathExtension.lowercased() == "app" }
        guard applications.count == 1,
              let candidate = applications.first,
              candidate.lastPathComponent == appName,
              candidate.deletingLastPathComponent().standardizedFileURL == mountPoint.standardizedFileURL else {
            throw UpdateInstallError.unexpectedDMGContents
        }
        let values = try candidate.resourceValues(forKeys: [.isDirectoryKey, .isSymbolicLinkKey])
        guard values.isDirectory == true, values.isSymbolicLink != true else {
            throw UpdateInstallError.unexpectedDMGContents
        }
        return candidate
    }

    private static func attachDMG(_ dmgURL: URL, beneath mountRoot: URL) throws -> MountedDMG {
        let result = try UpdateCommand.run(
            "/usr/bin/hdiutil",
            [
                "attach", "-readonly", "-nobrowse", "-noautoopen", "-plist",
                "-mountrandom", mountRoot.path, dmgURL.path
            ]
        )
        let propertyList = try PropertyListSerialization.propertyList(
            from: result.stdout,
            options: [],
            format: nil
        )
        guard let root = propertyList as? [String: Any],
              let entities = root["system-entities"] as? [[String: Any]] else {
            throw UpdateInstallError.invalidMountResponse
        }

        let mountPoints = entities.compactMap { entity -> URL? in
            guard let path = entity["mount-point"] as? String else { return nil }
            return URL(fileURLWithPath: path, isDirectory: true)
        }
        guard mountPoints.count == 1, let mountPoint = mountPoints.first,
              isDescendant(mountPoint, of: mountRoot) else {
            throw UpdateInstallError.invalidMountResponse
        }
        return MountedDMG(mountPoint: mountPoint)
    }

    private static func isDescendant(_ child: URL, of root: URL) -> Bool {
        let rootPath = root.resolvingSymlinksInPath().standardizedFileURL.path
        let childPath = child.resolvingSymlinksInPath().standardizedFileURL.path
        return childPath.hasPrefix(rootPath + "/")
    }

    private static func validateRegularFile(_ url: URL, maximumSize: Int64) throws {
        let values = try url.resourceValues(forKeys: [
            .isRegularFileKey,
            .isSymbolicLinkKey,
            .fileSizeKey
        ])
        guard values.isRegularFile == true,
              values.isSymbolicLink != true,
              let fileSize = values.fileSize,
              fileSize > 0,
              Int64(fileSize) <= maximumSize else {
            throw UpdateInstallError.invalidDownloadedFile
        }
    }
}

private struct MountedDMG {
    let mountPoint: URL
}

private struct ValidatedInstalledCopy {
    let identity: UpdateBundleIdentity
    let helperURL: URL
    let teamIdentifier: String
}

struct UpdateBundleIdentity: Equatable, Sendable {
    let bundleIdentifier: String
    let version: AppVersion
    let versionString: String
    let buildVersion: String
    let executableName: String

    static func load(appURL: URL, expectedBundleIdentifier: String) throws -> UpdateBundleIdentity {
        let appValues = try appURL.resourceValues(forKeys: [.isDirectoryKey, .isSymbolicLinkKey])
        guard appValues.isDirectory == true,
              appValues.isSymbolicLink != true,
              appURL.pathExtension.lowercased() == "app" else {
            throw UpdateInstallError.invalidApplicationBundle
        }

        let infoURL = appURL.appendingPathComponent("Contents/Info.plist", isDirectory: false)
        let infoValues = try infoURL.resourceValues(forKeys: [
            .isRegularFileKey,
            .isSymbolicLinkKey,
            .fileSizeKey
        ])
        guard infoValues.isRegularFile == true,
              infoValues.isSymbolicLink != true,
              let infoSize = infoValues.fileSize,
              infoSize > 0,
              infoSize <= 1024 * 1024 else {
            throw UpdateInstallError.invalidApplicationBundle
        }

        let data = try Data(contentsOf: infoURL, options: [.mappedIfSafe])
        guard let plist = try PropertyListSerialization.propertyList(
            from: data,
            options: [],
            format: nil
        ) as? [String: Any],
              let bundleIdentifier = plist["CFBundleIdentifier"] as? String,
              bundleIdentifier == expectedBundleIdentifier,
              let versionString = plist["CFBundleShortVersionString"] as? String,
              let version = AppVersion(versionString),
              let buildVersion = plist["CFBundleVersion"] as? String,
              !buildVersion.isEmpty,
              let executableName = plist["CFBundleExecutable"] as? String,
              !executableName.isEmpty,
              !executableName.contains("/") else {
            throw UpdateInstallError.invalidApplicationBundle
        }

        let executableURL = appURL
            .appendingPathComponent("Contents/MacOS", isDirectory: true)
            .appendingPathComponent(executableName, isDirectory: false)
        let executableValues = try executableURL.resourceValues(forKeys: [
            .isRegularFileKey,
            .isSymbolicLinkKey
        ])
        guard executableValues.isRegularFile == true,
              executableValues.isSymbolicLink != true else {
            throw UpdateInstallError.invalidApplicationBundle
        }

        return UpdateBundleIdentity(
            bundleIdentifier: bundleIdentifier,
            version: version,
            versionString: versionString,
            buildVersion: buildVersion,
            executableName: executableName
        )
    }
}

private struct CodeSignatureIdentity {
    let identifier: String
    let teamIdentifier: String
}

private enum CodeSignatureVerifier {
    static func inspect(_ url: URL) throws -> CodeSignatureIdentity {
        let result = try UpdateCommand.run(
            "/usr/bin/codesign",
            ["--display", "--verbose=4", url.path]
        )
        let details = String(decoding: result.stdout + result.stderr, as: UTF8.self)
        guard let identifier = value(named: "Identifier", in: details),
              let teamIdentifier = value(named: "TeamIdentifier", in: details) else {
            throw UpdateInstallError.unreadableCodeSignature
        }
        return CodeSignatureIdentity(
            identifier: identifier,
            teamIdentifier: teamIdentifier
        )
    }

    static func verify(
        _ url: URL,
        identifier: String,
        teamIdentifier: String,
        assessWithGatekeeper: Bool
    ) throws {
        guard isDeveloperTeamIdentifier(teamIdentifier) else {
            throw UpdateInstallError.developerIDSignedBuildRequired
        }
        let requirement = "anchor apple generic and identifier \"\(identifier)\" and certificate leaf[subject.OU] = \"\(teamIdentifier)\""
        _ = try UpdateCommand.run(
            "/usr/bin/codesign",
            [
                "--verify", "--deep", "--strict", "--all-architectures",
                "-R=\(requirement)", url.path
            ]
        )

        let identity = try inspect(url)
        guard identity.identifier == identifier,
              identity.teamIdentifier == teamIdentifier else {
            throw UpdateInstallError.codeIdentityMismatch
        }

        if assessWithGatekeeper {
            do {
                _ = try UpdateCommand.run(
                    "/usr/sbin/spctl",
                    ["--assess", "--type", "execute", "--verbose=2", url.path]
                )
            } catch {
                throw UpdateInstallError.gatekeeperRejected
            }
        }
    }

    static func isDeveloperTeamIdentifier(_ value: String) -> Bool {
        value.count == 10 && value.allSatisfy { $0.isASCII && ($0.isLetter || $0.isNumber) }
    }

    private static func value(named name: String, in details: String) -> String? {
        let prefix = "\(name)="
        return details
            .split(whereSeparator: \.isNewline)
            .first(where: { $0.hasPrefix(prefix) })
            .map { String($0.dropFirst(prefix.count)) }
    }
}

private struct UpdateCommandResult {
    let stdout: Data
    let stderr: Data
}

private enum UpdateCommand {
    static func run(_ executable: String, _ arguments: [String]) throws -> UpdateCommandResult {
        let process = Process()
        let standardOutput = Pipe()
        let standardError = Pipe()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        process.standardOutput = standardOutput
        process.standardError = standardError
        try process.run()
        process.waitUntilExit()

        let stdout = standardOutput.fileHandleForReading.readDataToEndOfFile()
        let stderr = standardError.fileHandleForReading.readDataToEndOfFile()
        guard process.terminationReason == .exit, process.terminationStatus == 0 else {
            throw UpdateInstallError.commandFailed(
                String(decoding: stderr, as: UTF8.self)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            )
        }
        return UpdateCommandResult(stdout: stdout, stderr: stderr)
    }
}

enum UpdateInstallError: LocalizedError {
    case automaticReplacementDisabled
    case untrustedReleaseAsset
    case invalidDownloadedFile
    case downloadChanged
    case versionIsNotNewer
    case currentVersionChanged
    case developerIDSignedBuildRequired
    case invalidApplicationBundle
    case unexpectedCandidateVersion
    case unexpectedDMGContents
    case invalidMountResponse
    case unreadableCodeSignature
    case codeIdentityMismatch
    case gatekeeperRejected
    case newerVersionAlreadyInstalled
    case installedCopyIsOlder
    case stagedCopyChanged
    case helperRejectedInstall
    case helperDidNotBecomeReady
    case commandFailed(String)

    var errorDescription: String? {
        switch self {
        case .automaticReplacementDisabled:
            "Automatic replacement is not enabled in this version. Open the verified DMG to install safely."
        case .untrustedReleaseAsset:
            "This download is not the expected release asset. Open the release page instead."
        case .invalidDownloadedFile:
            "The downloaded DMG is missing, is a link, or has an unexpected size."
        case .downloadChanged:
            "The downloaded DMG changed after verification. Download it again."
        case .versionIsNotNewer, .currentVersionChanged:
            "The update is no longer newer than the running app. Check again."
        case .developerIDSignedBuildRequired:
            "Automatic installation requires a Developer ID-signed and notarized build. Open the DMG to install this update manually."
        case .invalidApplicationBundle, .unexpectedDMGContents:
            "The DMG does not contain the expected Notch Calendar app."
        case .unexpectedCandidateVersion:
            "The app inside the DMG does not match the advertised version."
        case .invalidMountResponse:
            "macOS mounted the DMG in an unexpected location."
        case .unreadableCodeSignature, .codeIdentityMismatch:
            "The update’s signing identity does not match this app."
        case .gatekeeperRejected:
            "macOS could not verify this update with Gatekeeper."
        case .newerVersionAlreadyInstalled:
            "A newer version is already installed in Applications."
        case .installedCopyIsOlder:
            "The Applications copy is older than the running app."
        case .stagedCopyChanged:
            "The verified app changed while it was being prepared."
        case .helperRejectedInstall:
            "The update helper rejected the installation before this app quit."
        case .helperDidNotBecomeReady:
            "The update helper did not become ready. This app was not changed."
        case let .commandFailed(message):
            message.isEmpty ? "macOS could not verify or prepare the update." : message
        }
    }
}
