import SwiftUI
import AppKit

struct SettingsView: View {
    @StateObject private var updateChecker = UpdateChecker()

    var body: some View {
        Form {
            Section("Notch Calendar") {
                Text("Click the compact notch calendar to open today's agenda.")
                Text("Calendar access is requested only when you choose to enable it.").foregroundStyle(.secondary)
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

                    Button {
                        Task { await updateChecker.checkForUpdates() }
                    } label: {
                        Label("Check for Updates", systemImage: "arrow.triangle.2.circlepath")
                    }
                    .disabled(!updateChecker.canCheckForUpdates || updateChecker.status == .checking)

                    if case let .updateAvailable(_, releaseURL) = updateChecker.status {
                        Button("View Release") { NSWorkspace.shared.open(releaseURL) }
                    }
                }

                updateStatus
            }
        }
        .formStyle(.grouped)
        .frame(width: 440, height: 270)
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
        case let .updateAvailable(version, _):
            Label("Version \(version) is available.", systemImage: "arrow.down.circle.fill")
                .foregroundStyle(Color.accentColor)
        case let .unavailable(message):
            Text(message).foregroundStyle(.secondary)
        }
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
