import SwiftUI
import AppKit

struct SettingsView: View {
    @StateObject private var updateChecker = UpdateChecker()

    var body: some View {
        Form {
            Section("Notch Calendar") {
                Text("Click the compact notch calendar to open today's agenda.")
                Text("Calendar access is requested on first launch and your event data stays on this Mac.")
                    .foregroundStyle(.secondary)
            }

            Section("Software Update") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(currentVersion)
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 10) {
                    if let githubURL = githubURL {
                        Link("GitHub", destination: githubURL)
                    }

                    Spacer()

                    Button {
                        Task { await updateChecker.checkForUpdates() }
                    } label: {
                        Label("Check for Updates", systemImage: "arrow.triangle.2.circlepath")
                    }
                    .disabled(!updateChecker.canCheckForUpdates || updateChecker.status == .checking)
                }

                if case let .updateAvailable(version, releaseURL, downloadURL) = updateChecker.status {
                    HStack(spacing: 10) {
                        Button {
                            Task {
                                if let downloadedURL = await updateChecker.downloadUpdate() {
                                    NSWorkspace.shared.activateFileViewerSelecting([downloadedURL])
                                }
                            }
                        } label: {
                            downloadButtonLabel(version: version)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(downloadURL == nil || updateChecker.isDownloading)

                        Button("Release Notes") { NSWorkspace.shared.open(releaseURL) }
                    }
                }

                updateStatus
                downloadStatus
            }
        }
        .formStyle(.grouped)
        .frame(width: 440, height: 320)
    }

    @ViewBuilder private var updateStatus: some View {
        switch updateChecker.status {
        case .ready:
            if !updateChecker.canCheckForUpdates {
                Text("Updates will be enabled when a GitHub repository is configured for the release build.")
                    .foregroundStyle(.secondary)
            }
        case .checking:
            HStack(spacing: 6) {
                ProgressView().controlSize(.small)
                Text("Checking for updates…").foregroundStyle(.secondary)
            }
        case .upToDate:
            Label("You’re up to date.", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
        case let .updateAvailable(version, _, downloadURL):
            Label("Version \(version) is available.", systemImage: "arrow.down.circle.fill")
                .foregroundStyle(Color.accentColor)
            if downloadURL == nil {
                Text("This release does not include a DMG. Open the release notes to download another format.")
                    .foregroundStyle(.secondary)
            }
        case let .unavailable(message):
            Text(message).foregroundStyle(.secondary)
        }
    }

    @ViewBuilder private var downloadStatus: some View {
        switch updateChecker.downloadStatus {
        case .idle:
            EmptyView()
        case let .downloading(progress):
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(downloadProgressText(progress))
                        .foregroundStyle(.secondary)
                    Spacer()
                    if let percentage = progress.percentage {
                        Text("\(percentage)%")
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                    }
                }

                if let fraction = progress.fraction {
                    ProgressView(value: fraction)
                        .tint(Color.accentColor)
                        .accessibilityLabel("Update download progress")
                        .accessibilityValue("\(progress.percentage ?? 0) percent")
                } else {
                    ProgressView()
                        .controlSize(.small)
                        .accessibilityLabel("Starting update download")
                }
            }
        case .downloaded:
            Label("Downloaded and revealed in Finder.", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
        case let .failed(message):
            Label(message, systemImage: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
        }
    }

    @ViewBuilder private func downloadButtonLabel(version: String) -> some View {
        if case let .downloading(progress) = updateChecker.downloadStatus {
            if let percentage = progress.percentage {
                Label("Downloading \(percentage)%", systemImage: "arrow.down.circle.fill")
            } else {
                Label("Starting Download…", systemImage: "arrow.down.circle.fill")
            }
        } else {
            Label("Download \(version) DMG", systemImage: "arrow.down.circle.fill")
        }
    }

    private func downloadProgressText(_ progress: UpdateDownloadProgress) -> String {
        let received = ByteCountFormatter.string(
            fromByteCount: progress.bytesReceived,
            countStyle: .file
        )
        guard let totalBytes = progress.totalBytes else {
            return "Downloaded \(received)"
        }
        let total = ByteCountFormatter.string(fromByteCount: totalBytes, countStyle: .file)
        return "\(received) of \(total)"
    }

    private var currentVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
    }

    private var githubURL: URL? {
        guard let repository = Bundle.main.object(forInfoDictionaryKey: "NotchCalendarGitHubRepository") as? String,
              !repository.isEmpty,
              !repository.contains("YOUR_GITHUB") else { return nil }
        return URL(string: "https://github.com/\(repository)")
    }
}
