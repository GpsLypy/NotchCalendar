import SwiftUI
import AppKit

struct SettingsView: View {
    @ObservedObject var updateChecker: UpdateChecker
    @AppStorage(AppLanguage.storageKey) private var storedLanguage = AppLanguage.system.rawValue
    @Environment(\.appLanguage) private var appLanguage
    @State private var showsUpdateDetails = false

    var body: some View {
        Form {
            Section(t("Language")) {
                Picker(t("App Language"), selection: $storedLanguage) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(t(language.titleKey))
                            .tag(language.rawValue)
                    }
                }
                .pickerStyle(.menu)

                Text(t("Changes apply immediately across the app."))
                    .foregroundStyle(.secondary)
            }

            Section("Notch Calendar") {
                Text(t("Click the compact notch calendar to open today's agenda."))
                Text(t("Calendar access is requested on first launch and your event data stays on this Mac."))
                    .foregroundStyle(.secondary)
            }

            Section(t("Software Update")) {
                HStack {
                    Text(t("Version"))
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
                        Label(t("Check for Updates"), systemImage: "arrow.triangle.2.circlepath")
                    }
                    .disabled(
                        !updateChecker.canCheckForUpdates
                            || updateChecker.status == .checking
                            || updateChecker.isDownloading
                            || updateChecker.isInstalling
                            || updateChecker.isCheckingInstallCapability
                            || updateChecker.downloadedUpdateURL != nil
                    )
                }

                if case let .updateAvailable(version, releaseURL, downloadURL) = updateChecker.status {
                    HStack(spacing: 10) {
                        if updateChecker.downloadedUpdateURL == nil {
                            Button {
                                Task {
                                    _ = await updateChecker.downloadUpdate()
                                }
                            } label: {
                                downloadButtonLabel(version: version)
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(downloadURL == nil || updateChecker.isDownloading)
                        } else {
                            switch updateChecker.automaticInstallCapability {
                            case .supported:
                                Button {
                                    Task { await updateChecker.installAndRelaunch() }
                                } label: {
                                    Label(t("Install and Relaunch"), systemImage: "arrow.triangle.2.circlepath")
                                }
                                .buttonStyle(.borderedProminent)
                                .disabled(!updateChecker.canInstallDownloadedUpdate)

                                Button {
                                    updateChecker.openDMGAndQuit()
                                } label: {
                                    Label(t("Open DMG & Quit"), systemImage: "rectangle.portrait.and.arrow.right")
                                }
                                .disabled(updateChecker.isInstalling)
                            case .checking:
                                Button(t("Checking Install Support…")) {}
                                    .buttonStyle(.borderedProminent)
                                    .disabled(true)
                            case .unknown, .manualOnly:
                                Button {
                                    updateChecker.openDMGAndQuit()
                                } label: {
                                    Label(t("Open DMG & Quit"), systemImage: "rectangle.portrait.and.arrow.right")
                                }
                                .buttonStyle(.borderedProminent)
                                .disabled(updateChecker.isInstalling)
                            }
                        }

                        Link(t("Release Notes"), destination: releaseURL)
                    }
                }

                updateStatus
                downloadStatus
                automaticInstallStatus
                installationStatus

                if let latestRelease = updateChecker.latestRelease {
                    updateDetails(latestRelease)
                }

                if updateChecker.isRunningFromReadOnlyVolume {
                    if let installedVersion = updateChecker.installedApplicationsVersion {
                        HStack(spacing: 8) {
                            Label(
                                t(
                                    "Running from a disk image. Version %@ is already in Applications.",
                                    installedVersion
                                ),
                                systemImage: "externaldrive.fill"
                            )
                            .foregroundStyle(.secondary)
                            Spacer()
                            Button(t("Open Applications Copy & Quit")) {
                                updateChecker.openInstalledApplicationsCopyAndQuit()
                            }
                        }
                    } else {
                        Label(
                            t("Running from a disk image. Move the app to Applications for reliable updates."),
                            systemImage: "externaldrive.fill"
                        )
                        .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 540, height: 570)
        .onAppear { revealUpdateDetailsIfNeeded(for: updateChecker.status) }
        .onChange(of: updateChecker.status) { _, status in
            revealUpdateDetailsIfNeeded(for: status)
        }
    }

    @ViewBuilder private var updateStatus: some View {
        switch updateChecker.status {
        case .ready:
            if !updateChecker.canCheckForUpdates {
                Text(t("Updates will be enabled when a GitHub repository is configured for the release build."))
                    .foregroundStyle(.secondary)
            }
        case .checking:
            HStack(spacing: 6) {
                ProgressView().controlSize(.small)
                Text(t("Checking for updates…")).foregroundStyle(.secondary)
            }
        case .upToDate:
            Label(t("You’re up to date."), systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
        case let .updateAvailable(version, _, downloadURL):
            Label(t("Version %@ is available.", version), systemImage: "arrow.down.circle.fill")
                .foregroundStyle(Color.accentColor)
            if downloadURL == nil {
                Text(t("This release does not include a DMG. Open the release notes to download another format."))
                    .foregroundStyle(.secondary)
            }
        case let .unavailable(message):
            Text(t(message)).foregroundStyle(.secondary)
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
                        .accessibilityLabel(t("Update download progress"))
                        .accessibilityValue(t("%@ percent", "\(progress.percentage ?? 0)"))
                } else {
                    ProgressView()
                        .controlSize(.small)
                        .accessibilityLabel(t("Starting update download"))
                }
            }
        case .downloaded:
            HStack(spacing: 8) {
                Label(t("Download complete. Use the action above to continue."), systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Spacer()
                Button(t("Show in Finder")) { updateChecker.revealDownloadedUpdate() }
                    .buttonStyle(.link)
            }
        case let .failed(message):
            Label(t(message), systemImage: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
        }
    }

    @ViewBuilder private var installationStatus: some View {
        switch updateChecker.installationStatus {
        case .idle:
            EmptyView()
        case .preparing:
            HStack(spacing: 6) {
                ProgressView().controlSize(.small)
                Text(t("Verifying the DMG, app identity, and signing certificate…"))
                    .foregroundStyle(.secondary)
            }
        case .relaunching:
            HStack(spacing: 6) {
                ProgressView().controlSize(.small)
                Text(t("Installing and relaunching…"))
                    .foregroundStyle(.secondary)
            }
        case let .failed(message):
            Label(localizedStatusMessage(message), systemImage: "exclamationmark.shield.fill")
                .foregroundStyle(.orange)
        }
    }

    @ViewBuilder private var automaticInstallStatus: some View {
        switch updateChecker.automaticInstallCapability {
        case .unknown, .supported:
            EmptyView()
        case .checking:
            HStack(spacing: 6) {
                ProgressView().controlSize(.small)
                Text(t("Checking whether this build supports secure automatic installation…"))
                    .foregroundStyle(.secondary)
            }
        case let .manualOnly(message):
            Label(t(message), systemImage: "hand.raised.fill")
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder private func downloadButtonLabel(version: String) -> some View {
        if case let .downloading(progress) = updateChecker.downloadStatus {
            if let percentage = progress.percentage {
                Label(t("Downloading %@%%", "\(percentage)"), systemImage: "arrow.down.circle.fill")
            } else {
                Label(t("Starting Download…"), systemImage: "arrow.down.circle.fill")
            }
        } else {
            Label(t("Download %@ DMG", version), systemImage: "arrow.down.circle.fill")
        }
    }

    private func updateDetails(_ release: UpdateReleaseSummary) -> some View {
        DisclosureGroup(isExpanded: $showsUpdateDetails) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("v\(release.version)")
                        .font(.headline)
                        .monospacedDigit()
                    if let publishedAt = release.publishedAt {
                        Text(
                            publishedAt.formatted(
                                .dateTime.year().month().day().locale(appLanguage.locale)
                            )
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Link(t("View on GitHub"), destination: release.releaseURL)
                        .font(.subheadline)
                }

                if release.sections.isEmpty, let fallbackText = release.fallbackText {
                    Text(fallbackText)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                } else if release.sections.isEmpty {
                    Text(t("No update details were provided for this release."))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(release.sections) { section in
                        VStack(alignment: .leading, spacing: 6) {
                            Label(
                                t(section.category.titleKey),
                                systemImage: section.category.systemImage
                            )
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(categoryColor(section.category))

                            ForEach(Array(section.items.enumerated()), id: \.offset) { _, item in
                                Text("• \(item)")
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
            }
            .padding(.top, 8)
        } label: {
            Label(t("Update Details"), systemImage: "list.bullet.rectangle")
                .font(.body.weight(.medium))
        }
    }

    private func categoryColor(_ category: UpdateReleaseNoteCategory) -> Color {
        switch category {
        case .added: .green
        case .improved: Color.accentColor
        case .fixed: .orange
        }
    }

    private func revealUpdateDetailsIfNeeded(for status: UpdateStatus) {
        if case .updateAvailable = status {
            showsUpdateDetails = true
        }
    }

    private func downloadProgressText(_ progress: UpdateDownloadProgress) -> String {
        let received = progress.bytesReceived.formatted(
            .byteCount(style: .file).locale(appLanguage.locale)
        )
        guard let totalBytes = progress.totalBytes else {
            return t("Downloaded %@", received)
        }
        let total = totalBytes.formatted(
            .byteCount(style: .file).locale(appLanguage.locale)
        )
        return t("%@ of %@", received, total)
    }

    private func localizedStatusMessage(_ message: String) -> String {
        let openDMGFailurePrefix = "The DMG could not be opened: "
        guard message.hasPrefix(openDMGFailurePrefix) else { return t(message) }
        return t(
            "The DMG could not be opened: %@",
            String(message.dropFirst(openDMGFailurePrefix.count))
        )
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

    private func t(_ key: String, _ arguments: CVarArg...) -> String {
        L10n.string(key, language: appLanguage, arguments: arguments)
    }
}
