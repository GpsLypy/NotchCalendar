import AppKit
import Darwin
import Foundation

private let applicationIdentifier = "com.codex.notch-calendar"
private let updaterIdentifier = "com.codex.notch-calendar.updater"
private let applicationName = "Notch Calendar.app"

do {
    if CommandLine.arguments.dropFirst().first == "--launch-installed-copy" {
        try InstalledCopyLauncher.run(CommandLine.arguments)
    } else {
        try UpdateHelper.run()
    }
    exit(EXIT_SUCCESS)
} catch {
    UpdateHelper.log("Fatal error: \(error.localizedDescription)")
    exit(EXIT_FAILURE)
}

private enum InstalledCopyLauncher {
    static func run(_ arguments: [String]) throws {
        guard arguments.count == 5,
              arguments[1] == "--launch-installed-copy",
              let parentPID = pid_t(arguments[2]),
              parentPID > 1,
              let currentVersion = Version(arguments[3]),
              SignatureVerifier.isTeamIdentifier(arguments[4]) else {
            throw HelperError.invalidArguments
        }
        let teamIdentifier = arguments[4]

        let ownExecutable = URL(fileURLWithPath: CommandLine.arguments[0], isDirectory: false)
        try SignatureVerifier.verify(
            ownExecutable,
            identifier: updaterIdentifier,
            teamIdentifier: teamIdentifier,
            gatekeeper: false
        )

        let destination = URL(fileURLWithPath: "/Applications", isDirectory: true)
            .appendingPathComponent(applicationName, isDirectory: true)
        try validateInstalledCopy(
            destination,
            currentVersion: currentVersion,
            teamIdentifier: teamIdentifier
        )
        guard UpdateHelper.waitForProcessToExit(parentPID, timeout: 60) else {
            throw HelperError.parentDidNotExit
        }
        // Revalidate next to execution so a path replacement while waiting for
        // the old process cannot redirect the relaunch to an untrusted app.
        try validateInstalledCopy(
            destination,
            currentVersion: currentVersion,
            teamIdentifier: teamIdentifier
        )
        _ = try Command.run("/usr/bin/open", ["-n", destination.path])
    }

    private static func validateInstalledCopy(
        _ destination: URL,
        currentVersion: Version,
        teamIdentifier: String
    ) throws {
        let installed = try AppIdentity.load(destination)
        guard installed.bundleIdentifier == applicationIdentifier,
              installed.version >= currentVersion else {
            throw HelperError.identityMismatch
        }
        try SignatureVerifier.verify(
            destination,
            identifier: applicationIdentifier,
            teamIdentifier: teamIdentifier,
            gatekeeper: true
        )
    }
}

private enum UpdateHelper {
    static func run() throws {
        let arguments = try HelperArguments(CommandLine.arguments)
        let lock = try TransactionLock.acquire()
        defer { lock.release() }

        log("Preparing install of Notch Calendar \(arguments.expectedVersion.description)")
        try validate(arguments)
        try write("ready", to: arguments.helperReadyURL)
        log("Validation complete; waiting for process \(arguments.parentPID) to exit")

        var parentExited = false
        do {
            guard waitForProcessToExit(arguments.parentPID, timeout: 60) else {
                throw HelperError.parentDidNotExit
            }
            parentExited = true
            try install(arguments)
        } catch {
            log("Install failed: \(error.localizedDescription)")
            if !parentExited {
                try? FileManager.default.removeItem(at: arguments.stagedAppURL)
            }
            revealDMG(arguments.downloadedDMGURL)
            showFailureAlert()
            let preservesRecoveryFiles = (error as? HelperError)?.preservesRecoveryFiles == true
            if !preservesRecoveryFiles {
                try? FileManager.default.removeItem(at: arguments.handoffDirectoryURL)
            }
            throw error
        }
    }

    static func log(_ message: String) {
        let fileManager = FileManager.default
        guard let logsRoot = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first else {
            return
        }
        let directory = logsRoot
            .appendingPathComponent("Logs", isDirectory: true)
            .appendingPathComponent("NotchCalendar", isDirectory: true)
        let file = directory.appendingPathComponent("update.log")
        try? fileManager.createDirectory(
            at: directory,
            withIntermediateDirectories: true,
            attributes: [.posixPermissions: 0o700]
        )
        if !fileManager.fileExists(atPath: file.path) {
            fileManager.createFile(atPath: file.path, contents: nil, attributes: [.posixPermissions: 0o600])
        }
        guard let handle = try? FileHandle(forWritingTo: file) else { return }
        defer { try? handle.close() }
        do {
            try handle.seekToEnd()
            let timestamp = ISO8601DateFormatter().string(from: Date())
            try handle.write(contentsOf: Data("[\(timestamp)] \(message)\n".utf8))
        } catch {
            return
        }
    }

    private static func validate(_ arguments: HelperArguments) throws {
        let ownExecutable = URL(fileURLWithPath: CommandLine.arguments[0], isDirectory: false)
        try SignatureVerifier.verify(
            ownExecutable,
            identifier: updaterIdentifier,
            teamIdentifier: arguments.teamIdentifier,
            gatekeeper: false
        )

        let current = try AppIdentity.load(arguments.currentAppURL)
        guard current.bundleIdentifier == applicationIdentifier else {
            throw HelperError.identityMismatch
        }
        try SignatureVerifier.verify(
            arguments.currentAppURL,
            identifier: applicationIdentifier,
            teamIdentifier: arguments.teamIdentifier,
            gatekeeper: true
        )

        let candidate = try AppIdentity.load(arguments.stagedAppURL)
        guard candidate.bundleIdentifier == applicationIdentifier,
              candidate.version == arguments.expectedVersion else {
            throw HelperError.identityMismatch
        }
        try SignatureVerifier.verify(
            arguments.stagedAppURL,
            identifier: applicationIdentifier,
            teamIdentifier: arguments.teamIdentifier,
            gatekeeper: true
        )

        if FileManager.default.fileExists(atPath: arguments.destinationAppURL.path) {
            let installed = try AppIdentity.load(arguments.destinationAppURL)
            guard installed.bundleIdentifier == applicationIdentifier,
                  installed.version <= arguments.expectedVersion else {
                throw HelperError.newerVersionAlreadyInstalled
            }
            try SignatureVerifier.verify(
                arguments.destinationAppURL,
                identifier: applicationIdentifier,
                teamIdentifier: arguments.teamIdentifier,
                gatekeeper: true
            )
        }
    }

    private static func install(_ arguments: HelperArguments) throws {
        let fileManager = FileManager.default
        let hadInstalledApp = fileManager.fileExists(atPath: arguments.destinationAppURL.path)
        var replacementState = ReplacementState.untouched
        var launchedUpdatedApp = false

        do {
            try write("validated", to: arguments.journalURL)
            if hadInstalledApp {
                try renameSwap(arguments.stagedAppURL, arguments.destinationAppURL)
                replacementState = .swappedWithPrevious
            } else {
                try fileManager.moveItem(at: arguments.stagedAppURL, to: arguments.destinationAppURL)
                replacementState = .installedWithoutPrevious
            }
            try write(hadInstalledApp ? "swapped" : "installed", to: arguments.journalURL)

            let installed = try AppIdentity.load(arguments.destinationAppURL)
            guard installed.bundleIdentifier == applicationIdentifier,
                  installed.version == arguments.expectedVersion else {
                throw HelperError.identityMismatch
            }
            try SignatureVerifier.verify(
                arguments.destinationAppURL,
                identifier: applicationIdentifier,
                teamIdentifier: arguments.teamIdentifier,
                gatekeeper: true
            )

            try launch(
                arguments.destinationAppURL,
                environment: [
                    "NOTCH_CALENDAR_UPDATE_READY_FILE": arguments.launchReadyURL.path,
                    "NOTCH_CALENDAR_UPDATE_TOKEN": arguments.token,
                    "NOTCH_CALENDAR_UPDATE_VERSION": arguments.expectedVersion.description
                ]
            )
            launchedUpdatedApp = true
            try write("launched", to: arguments.journalURL)

            guard waitForLaunchConfirmation(arguments, timeout: 20) else {
                throw HelperError.updatedAppDidNotStart
            }

            try write("committed", to: arguments.journalURL)
            if hadInstalledApp, fileManager.fileExists(atPath: arguments.stagedAppURL.path) {
                do {
                    try fileManager.removeItem(at: arguments.stagedAppURL)
                } catch {
                    // The new app already confirmed a successful launch. A
                    // cleanup failure must never put a partially removed old
                    // bundle back into /Applications.
                    log("Could not remove the old hidden app after commit: \(error.localizedDescription)")
                }
            }
            try? fileManager.removeItem(at: arguments.handoffDirectoryURL)
            log("Update committed successfully")
        } catch {
            if launchedUpdatedApp {
                guard stopFailedUpdatedApp(at: arguments.destinationAppURL) else {
                    log("The failed updated process did not exit; preserving the install transaction")
                    try? write("recovery-incomplete: updated process still running", to: arguments.journalURL)
                    throw HelperError.recoveryIncomplete
                }
            }
            do {
                try recover(arguments, replacementState: replacementState)
            } catch {
                log("Rollback could not complete safely: \(error.localizedDescription)")
                try? write("recovery-incomplete: \(error.localizedDescription)", to: arguments.journalURL)
                throw HelperError.recoveryIncomplete
            }
            throw error
        }
    }

    private static func recover(
        _ arguments: HelperArguments,
        replacementState: ReplacementState
    ) throws {
        let fileManager = FileManager.default
        var cleanupError: Error?
        let relaunchURL: URL

        switch replacementState {
        case .swappedWithPrevious:
            guard fileManager.fileExists(atPath: arguments.destinationAppURL.path),
                  fileManager.fileExists(atPath: arguments.stagedAppURL.path) else {
                throw HelperError.rollbackFilesMissing
            }
            try renameSwap(arguments.destinationAppURL, arguments.stagedAppURL)
            relaunchURL = arguments.destinationAppURL
            do {
                guard !fileManager.fileExists(atPath: arguments.failedAppURL.path) else {
                    throw HelperError.rollbackDestinationExists
                }
                try fileManager.moveItem(at: arguments.stagedAppURL, to: arguments.failedAppURL)
            } catch {
                cleanupError = error
            }
            log("Restored the previous Applications copy")
        case .installedWithoutPrevious:
            guard fileManager.fileExists(atPath: arguments.destinationAppURL.path) else {
                throw HelperError.rollbackFilesMissing
            }
            relaunchURL = arguments.currentAppURL
            do {
                guard !fileManager.fileExists(atPath: arguments.failedAppURL.path) else {
                    throw HelperError.rollbackDestinationExists
                }
                try fileManager.moveItem(at: arguments.destinationAppURL, to: arguments.failedAppURL)
            } catch {
                cleanupError = error
            }
            log("Moved the failed new app aside when possible")
        case .untouched:
            relaunchURL = fileManager.fileExists(atPath: arguments.destinationAppURL.path)
                ? arguments.destinationAppURL
                : arguments.currentAppURL
            if fileManager.fileExists(atPath: arguments.stagedAppURL.path) {
                do {
                    guard !fileManager.fileExists(atPath: arguments.failedAppURL.path) else {
                        throw HelperError.rollbackDestinationExists
                    }
                    try fileManager.moveItem(at: arguments.stagedAppURL, to: arguments.failedAppURL)
                } catch {
                    cleanupError = error
                }
            }
        }

        let restored = try AppIdentity.load(relaunchURL)
        guard restored.bundleIdentifier == applicationIdentifier,
              restored.version <= arguments.expectedVersion else {
            throw HelperError.identityMismatch
        }
        try SignatureVerifier.verify(
            relaunchURL,
            identifier: applicationIdentifier,
            teamIdentifier: arguments.teamIdentifier,
            gatekeeper: true
        )
        try launch(relaunchURL, environment: [:])
        log("Relaunched verified previous app from \(relaunchURL.path)")

        if let cleanupError {
            throw cleanupError
        }
    }

    private enum ReplacementState {
        case untouched
        case swappedWithPrevious
        case installedWithoutPrevious
    }

    static func waitForProcessToExit(_ processID: pid_t, timeout: TimeInterval) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if kill(processID, 0) != 0, errno == ESRCH { return true }
            usleep(100_000)
        }
        return false
    }

    private static func waitForLaunchConfirmation(
        _ arguments: HelperArguments,
        timeout: TimeInterval
    ) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if let contents = try? String(contentsOf: arguments.launchReadyURL, encoding: .utf8) {
                let lines = contents.split(whereSeparator: \.isNewline).map(String.init)
                if lines.count >= 2,
                   lines[0] == arguments.token,
                   lines[1] == arguments.expectedVersion.description {
                    return true
                }
            }
            usleep(100_000)
        }
        return false
    }

    private static func stopFailedUpdatedApp(at appURL: URL) -> Bool {
        let expectedPath = appURL.resolvingSymlinksInPath().standardizedFileURL.path
        for application in NSRunningApplication.runningApplications(withBundleIdentifier: applicationIdentifier) {
            guard application.bundleURL?.resolvingSymlinksInPath().standardizedFileURL.path == expectedPath else {
                continue
            }
            _ = application.terminate()
        }

        let deadline = Date().addingTimeInterval(5)
        while Date() < deadline {
            let stillRunning = NSRunningApplication
                .runningApplications(withBundleIdentifier: applicationIdentifier)
                .contains {
                    $0.bundleURL?.resolvingSymlinksInPath().standardizedFileURL.path == expectedPath
                }
            if !stillRunning { return true }
            usleep(100_000)
        }
        return false
    }

    private static func renameSwap(_ first: URL, _ second: URL) throws {
        let result = first.path.withCString { firstPath in
            second.path.withCString { secondPath in
                renameatx_np(AT_FDCWD, firstPath, AT_FDCWD, secondPath, UInt32(RENAME_SWAP))
            }
        }
        guard result == 0 else {
            throw HelperError.fileReplacementFailed(String(cString: strerror(errno)))
        }
    }

    private static func launch(_ appURL: URL, environment: [String: String]) throws {
        var arguments = ["-n"]
        for key in environment.keys.sorted() {
            guard let value = environment[key] else { continue }
            arguments.append(contentsOf: ["--env", "\(key)=\(value)"])
        }
        arguments.append(appURL.path)
        _ = try Command.run("/usr/bin/open", arguments)
    }

    private static func write(_ value: String, to url: URL) throws {
        try Data("\(value)\n".utf8).write(to: url, options: [.atomic])
    }

    private static func revealDMG(_ url: URL) {
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        _ = try? Command.run("/usr/bin/open", ["-R", url.path])
    }

    private static func showFailureAlert() {
        let script = "display alert \"Notch Calendar could not install the update\" message \"The previous app was restored when possible. Open the downloaded DMG to install manually. Details are in Library/Logs/NotchCalendar/update.log.\" as warning"
        _ = try? Command.run("/usr/bin/osascript", ["-e", script])
    }
}

private struct HelperArguments {
    let parentPID: pid_t
    let stagedAppURL: URL
    let destinationAppURL: URL
    let currentAppURL: URL
    let downloadedDMGURL: URL
    let expectedVersion: Version
    let teamIdentifier: String
    let token: String
    let handoffDirectoryURL: URL

    var helperReadyURL: URL { handoffDirectoryURL.appendingPathComponent("helper-ready") }
    var launchReadyURL: URL { handoffDirectoryURL.appendingPathComponent("launch-ready") }
    var journalURL: URL { handoffDirectoryURL.appendingPathComponent("journal") }
    var failedAppURL: URL {
        URL(fileURLWithPath: "/Applications", isDirectory: true)
            .appendingPathComponent(".Notch Calendar.failed-\(token).app", isDirectory: true)
    }

    init(_ arguments: [String]) throws {
        guard arguments.count == 11,
              arguments[1] == "--perform-install",
              let parentPID = pid_t(arguments[2]),
              parentPID > 1,
              let expectedVersion = Version(arguments[7]),
              SignatureVerifier.isTeamIdentifier(arguments[8]),
              let tokenUUID = UUID(uuidString: arguments[9]),
              tokenUUID.uuidString.lowercased() == arguments[9] else {
            throw HelperError.invalidArguments
        }

        let token = arguments[9]
        let applicationsURL = URL(fileURLWithPath: "/Applications", isDirectory: true).standardizedFileURL
        let stagedAppURL = URL(fileURLWithPath: arguments[3], isDirectory: true).standardizedFileURL
        let destinationAppURL = URL(fileURLWithPath: arguments[4], isDirectory: true).standardizedFileURL
        let currentAppURL = URL(fileURLWithPath: arguments[5], isDirectory: true).standardizedFileURL
        let downloadedDMGURL = URL(fileURLWithPath: arguments[6], isDirectory: false).standardizedFileURL
        let handoffDirectoryURL = URL(fileURLWithPath: arguments[10], isDirectory: true).standardizedFileURL
        let temporaryRoot = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .resolvingSymlinksInPath()
            .standardizedFileURL

        guard destinationAppURL == applicationsURL.appendingPathComponent(applicationName, isDirectory: true),
              stagedAppURL.deletingLastPathComponent() == applicationsURL,
              stagedAppURL.lastPathComponent == ".Notch Calendar.update-\(token).app",
              handoffDirectoryURL.resolvingSymlinksInPath().deletingLastPathComponent() == temporaryRoot,
              handoffDirectoryURL.lastPathComponent == "NotchCalendar-update-\(token)" else {
            throw HelperError.invalidArguments
        }

        self.parentPID = parentPID
        self.stagedAppURL = stagedAppURL
        self.destinationAppURL = destinationAppURL
        self.currentAppURL = currentAppURL
        self.downloadedDMGURL = downloadedDMGURL
        self.expectedVersion = expectedVersion
        self.teamIdentifier = arguments[8]
        self.token = token
        self.handoffDirectoryURL = handoffDirectoryURL
    }
}

private struct Version: Comparable, CustomStringConvertible {
    let components: [Int]

    init?(_ raw: String) {
        let parts = raw.split(separator: ".", omittingEmptySubsequences: false)
        guard (1...4).contains(parts.count) else { return nil }
        var values: [Int] = []
        for part in parts {
            guard !part.isEmpty,
                  part.allSatisfy(\.isNumber),
                  (part.count == 1 || part.first != "0"),
                  let value = Int(part) else { return nil }
            values.append(value)
        }
        components = values
    }

    var description: String { components.map(String.init).joined(separator: ".") }

    static func == (lhs: Version, rhs: Version) -> Bool { compare(lhs, rhs) == 0 }
    static func < (lhs: Version, rhs: Version) -> Bool { compare(lhs, rhs) < 0 }

    private static func compare(_ lhs: Version, _ rhs: Version) -> Int {
        let count = max(lhs.components.count, rhs.components.count)
        for index in 0..<count {
            let left = index < lhs.components.count ? lhs.components[index] : 0
            let right = index < rhs.components.count ? rhs.components[index] : 0
            if left != right { return left < right ? -1 : 1 }
        }
        return 0
    }
}

private struct AppIdentity {
    let bundleIdentifier: String
    let version: Version

    static func load(_ appURL: URL) throws -> AppIdentity {
        let appValues = try appURL.resourceValues(forKeys: [.isDirectoryKey, .isSymbolicLinkKey])
        guard appValues.isDirectory == true,
              appValues.isSymbolicLink != true,
              appURL.pathExtension.lowercased() == "app" else {
            throw HelperError.invalidApplication
        }

        let infoURL = appURL.appendingPathComponent("Contents/Info.plist")
        let infoValues = try infoURL.resourceValues(forKeys: [
            .isRegularFileKey, .isSymbolicLinkKey, .fileSizeKey
        ])
        guard infoValues.isRegularFile == true,
              infoValues.isSymbolicLink != true,
              let size = infoValues.fileSize,
              (1...(1024 * 1024)).contains(size) else {
            throw HelperError.invalidApplication
        }
        let data = try Data(contentsOf: infoURL, options: [.mappedIfSafe])
        guard let plist = try PropertyListSerialization.propertyList(
            from: data,
            options: [],
            format: nil
        ) as? [String: Any],
              let identifier = plist["CFBundleIdentifier"] as? String,
              let rawVersion = plist["CFBundleShortVersionString"] as? String,
              let version = Version(rawVersion),
              let executable = plist["CFBundleExecutable"] as? String,
              !executable.isEmpty,
              !executable.contains("/") else {
            throw HelperError.invalidApplication
        }
        let executableURL = appURL
            .appendingPathComponent("Contents/MacOS", isDirectory: true)
            .appendingPathComponent(executable)
        let executableValues = try executableURL.resourceValues(forKeys: [
            .isRegularFileKey, .isSymbolicLinkKey
        ])
        guard executableValues.isRegularFile == true,
              executableValues.isSymbolicLink != true else {
            throw HelperError.invalidApplication
        }
        return AppIdentity(bundleIdentifier: identifier, version: version)
    }
}

private enum SignatureVerifier {
    static func verify(
        _ url: URL,
        identifier: String,
        teamIdentifier: String,
        gatekeeper: Bool
    ) throws {
        let requirement = "anchor apple generic and identifier \"\(identifier)\" and certificate leaf[subject.OU] = \"\(teamIdentifier)\""
        _ = try Command.run(
            "/usr/bin/codesign",
            [
                "--verify", "--deep", "--strict", "--all-architectures",
                "-R=\(requirement)", url.path
            ]
        )
        let details = try Command.run(
            "/usr/bin/codesign",
            ["--display", "--verbose=4", url.path]
        ).combinedText
        guard value(named: "Identifier", in: details) == identifier,
              value(named: "TeamIdentifier", in: details) == teamIdentifier else {
            throw HelperError.identityMismatch
        }
        if gatekeeper {
            _ = try Command.run(
                "/usr/sbin/spctl",
                ["--assess", "--type", "execute", "--verbose=2", url.path]
            )
        }
    }

    static func isTeamIdentifier(_ value: String) -> Bool {
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

private final class TransactionLock {
    private var fileDescriptor: Int32

    private init(fileDescriptor: Int32) {
        self.fileDescriptor = fileDescriptor
    }

    static func acquire() throws -> TransactionLock {
        let path = (NSTemporaryDirectory() as NSString)
            .appendingPathComponent("com.codex.notch-calendar.update.lock")
        let descriptor = path.withCString {
            open($0, O_CREAT | O_RDWR | O_CLOEXEC, S_IRUSR | S_IWUSR)
        }
        guard descriptor >= 0, flock(descriptor, LOCK_EX | LOCK_NB) == 0 else {
            if descriptor >= 0 { close(descriptor) }
            throw HelperError.updateAlreadyRunning
        }
        return TransactionLock(fileDescriptor: descriptor)
    }

    func release() {
        guard fileDescriptor >= 0 else { return }
        flock(fileDescriptor, LOCK_UN)
        close(fileDescriptor)
        fileDescriptor = -1
    }
}

private struct CommandResult {
    let stdout: Data
    let stderr: Data
    var combinedText: String { String(decoding: stdout + stderr, as: UTF8.self) }
}

private enum Command {
    static func run(_ executable: String, _ arguments: [String]) throws -> CommandResult {
        let process = Process()
        let output = Pipe()
        let error = Pipe()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        process.standardOutput = output
        process.standardError = error
        try process.run()
        process.waitUntilExit()
        let stdout = output.fileHandleForReading.readDataToEndOfFile()
        let stderr = error.fileHandleForReading.readDataToEndOfFile()
        guard process.terminationReason == .exit, process.terminationStatus == 0 else {
            let message = String(decoding: stderr, as: UTF8.self)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            throw HelperError.commandFailed(message)
        }
        return CommandResult(stdout: stdout, stderr: stderr)
    }
}

private enum HelperError: LocalizedError {
    case invalidArguments
    case updateAlreadyRunning
    case invalidApplication
    case identityMismatch
    case newerVersionAlreadyInstalled
    case parentDidNotExit
    case updatedAppDidNotStart
    case rollbackFilesMissing
    case rollbackDestinationExists
    case recoveryIncomplete
    case fileReplacementFailed(String)
    case commandFailed(String)

    var errorDescription: String? {
        switch self {
        case .invalidArguments: "The update helper received invalid arguments."
        case .updateAlreadyRunning: "Another update installation is already running."
        case .invalidApplication: "An application bundle is invalid."
        case .identityMismatch: "An application identity did not match the trusted update."
        case .newerVersionAlreadyInstalled: "A newer version is already installed."
        case .parentDidNotExit: "The running app did not quit within 60 seconds."
        case .updatedAppDidNotStart: "The updated app did not confirm a successful launch."
        case .rollbackFilesMissing: "The files needed to restore the previous app are missing."
        case .rollbackDestinationExists: "The recovery destination already exists."
        case .recoveryIncomplete: "The update could not be rolled back safely; recovery files were preserved."
        case let .fileReplacementFailed(message): "The app replacement failed: \(message)"
        case let .commandFailed(message): message.isEmpty ? "A system command failed." : message
        }
    }

    var preservesRecoveryFiles: Bool {
        if case .recoveryIncomplete = self { return true }
        return false
    }
}
