import SwiftUI

struct WorkspaceSidebar: View {
    @Binding var selection: WorkspaceDestination
    @ObservedObject var calendar: CalendarManager
    @ObservedObject var focusTimer: FocusTimerModel
    @ObservedObject var updateChecker: UpdateChecker
    var openCommands: (() -> Void)? = nil
    @Environment(\.appLanguage) private var appLanguage
    @Environment(\.openSettings) private var openSettings
    @State private var showsShare = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            brand
                .padding(.horizontal, 13)
                .padding(.top, 43)
                .padding(.bottom, 20)

            if let openCommands {
                Button(action: openCommands) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                        Text(t("Quick access"))
                        Spacer(minLength: 4)
                        Text("⌘K").font(.system(size: 10, design: .monospaced))
                    }
                    .font(.system(size: 12))
                    .padding(10)
                    .background(WorkspacePalette.elevated, in: RoundedRectangle(cornerRadius: 8))
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(WorkspacePalette.secondaryText)
                .keyboardShortcut("k", modifiers: .command)
                .padding(.horizontal, 12)
                .padding(.bottom, 18)
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    sectionLabel("WORKSPACE")
                    navigationRow(.today, shortcut: "⌘1")
                    navigationRow(.calendar, shortcut: "⌘2", badge: eventBadge)

                    sectionLabel("TOOLS")
                        .padding(.top, 14)
                    navigationRow(.focus, shortcut: "⌘3", badge: focusBadge)
                    navigationRow(.scratchpad, shortcut: "⌘4")

                    sectionLabel("INSIGHTS")
                        .padding(.top, 14)
                    navigationRow(.radar, shortcut: "⌘5")
                    navigationRow(.markets, shortcut: "⌘6")
                    navigationRow(.discussion, shortcut: "⌘7")
                    navigationRow(.briefing, shortcut: "⌘8")
                }
            }
            .scrollIndicators(.automatic)

            Spacer(minLength: 8)

            calendarStatus
                .padding(.horizontal, 10)
                .padding(.bottom, 7)

            if let version = availableUpdateVersion {
                updateAvailableLink(version: version)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 7)
            }

            VStack(spacing: 2) {
                Divider().padding(.bottom, 6)
                if let url = UpdateConfiguration.githubURL {
                    Link(destination: url) {
                        utilityLabel("GitHub", icon: "chevron.left.forwardslash.chevron.right")
                    }
                    .help(t("View on GitHub"))
                }
                Button { showsShare = true } label: {
                    utilityLabel("Share", icon: "square.and.arrow.up")
                }
                SettingsLink {
                    utilityLabel("Settings", icon: "gearshape")
                }
                Button {
                    openSettings()
                    Task { await updateChecker.checkForUpdates() }
                } label: {
                    utilityLabel(
                        updateChecker.status == .checking ? "Checking for updates…" : "Check for Updates",
                        icon: "arrow.triangle.2.circlepath"
                    )
                }
                .disabled(updateChecker.status == .checking || updateChecker.isDownloading || updateChecker.isInstalling)
            }
            .buttonStyle(.plain)
            .foregroundStyle(WorkspacePalette.secondaryText)
            .padding(.horizontal, 10)
            .padding(.bottom, 12)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(WorkspacePalette.sidebar)
        .accessibilityElement(children: .contain)
        .sheet(isPresented: $showsShare) {
            ShareCalendarView()
                .environment(\.appLanguage, appLanguage)
        }
    }

    private func utilityLabel(_ title: String, icon: String) -> some View {
        Label(t(title), systemImage: icon)
            .font(.system(size: 12, weight: .medium))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 10)
            .frame(height: 30)
            .contentShape(Rectangle())
    }

    private var brand: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(WorkspacePalette.accent.opacity(0.16))
                Image(systemName: "calendar")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(WorkspacePalette.accent)
                    .accessibilityHidden(true)
            }
            .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 1) {
                Text("Notch")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(WorkspacePalette.primaryText)
                Text(t("PERSONAL DESK"))
                    .font(.system(size: 8.5, weight: .bold))
                    .tracking(0.9)
                    .foregroundStyle(WorkspacePalette.secondaryText)
            }
        }
    }

    private func sectionLabel(_ title: String) -> some View {
        Text(t(title))
            .font(.system(size: 9.5, weight: .bold))
            .tracking(0.9)
            .foregroundStyle(WorkspacePalette.secondaryText.opacity(0.8))
            .padding(.horizontal, 18)
            .padding(.bottom, 6)
    }

    private func navigationRow(
        _ destination: WorkspaceDestination,
        shortcut: String,
        badge: String? = nil
    ) -> some View {
        SidebarNavigationButton(
            destination: destination,
            shortcut: shortcut,
            badge: badge,
            isSelected: selection == destination
        ) {
            selection = destination
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 1)
        .keyboardShortcut(keyEquivalent(for: destination), modifiers: .command)
    }

    private var eventBadge: String? {
        guard calendar.authorizationMessage == nil, !calendar.todayEvents.isEmpty else { return nil }
        return "\(calendar.todayEvents.count)"
    }

    private var focusBadge: String? {
        focusTimer.isRunning ? focusTimer.timeLabel : nil
    }

    private var calendarStatus: some View {
        Button {
            selection = .calendar
        } label: {
            HStack(spacing: 8) {
                Circle()
                    .fill(calendar.sourceAvailability == .available ? WorkspacePalette.success : Color.orange)
                    .frame(width: 6, height: 6)
                VStack(alignment: .leading, spacing: 2) {
                    Text(calendarStatusTitle)
                        .font(.system(size: 11.5, weight: .medium))
                        .foregroundStyle(WorkspacePalette.primaryText)
                    if calendar.authorizationMessage != nil {
                        Text(t("Managed in System Settings"))
                            .font(.system(size: 9.5))
                            .foregroundStyle(WorkspacePalette.secondaryText)
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(WorkspacePalette.hover, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
        .help(t("Open Calendar"))
    }

    private var calendarStatusTitle: String {
        switch calendar.sourceAvailability {
        case .needsPermission: return t("Calendar access needed")
        case .noCalendars: return t("No calendars available")
        case .noneSelected: return t("All calendars hidden")
        case .available: break
        }
        let count = calendar.todayEvents.count
        return count == 1
            ? t("1 event today")
            : t("%@ events today", "\(count)")
    }

    private var availableUpdateVersion: String? {
        guard case let .updateAvailable(version, _, _) = updateChecker.status else {
            return nil
        }
        return version
    }

    private func updateAvailableLink(version: String) -> some View {
        SettingsLink {
            HStack(spacing: 9) {
                Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(WorkspacePalette.success)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 1) {
                    Text(t("Update available"))
                        .font(.system(size: 11.5, weight: .semibold))
                        .foregroundStyle(WorkspacePalette.primaryText)
                    Text(t("Version %@", version))
                        .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                        .foregroundStyle(WorkspacePalette.secondaryText)
                }

                Spacer(minLength: 4)
                Image(systemName: "chevron.right")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(WorkspacePalette.success.opacity(0.8))
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, 10)
            .frame(height: 44)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                WorkspacePalette.success.opacity(0.10),
                in: RoundedRectangle(cornerRadius: 10, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(WorkspacePalette.success.opacity(0.22), lineWidth: 1)
            }
            .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(t("Update available, version %@", version))
        .help(t("Open update details"))
    }

    private func keyEquivalent(for destination: WorkspaceDestination) -> KeyEquivalent {
        switch destination {
        case .today: "1"
        case .calendar: "2"
        case .focus: "3"
        case .scratchpad: "4"
        case .radar: "5"
        case .markets: "6"
        case .discussion: "7"
        case .briefing: "8"
        }
    }

    private func t(_ key: String, _ arguments: CVarArg...) -> String {
        L10n.string(key, language: appLanguage, arguments: arguments)
    }
}

private struct SidebarNavigationButton: View {
    let destination: WorkspaceDestination
    let shortcut: String
    let badge: String?
    let isSelected: Bool
    let action: () -> Void
    @State private var isHovering = false
    @Environment(\.appLanguage) private var appLanguage

    var body: some View {
        Button(action: action) {
            HStack(spacing: 9) {
                Image(systemName: destination.systemImage)
                    .font(.system(size: 12, weight: .medium))
                    .frame(width: 17)
                    .foregroundStyle(isSelected ? WorkspacePalette.accent : WorkspacePalette.secondaryText)
                Text(L10n.string(destination.titleKey, language: appLanguage))
                    .font(.system(size: 12.5, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? WorkspacePalette.primaryText : WorkspacePalette.secondaryText)
                Spacer(minLength: 6)
                if let badge {
                    Text(badge)
                        .font(.system(size: 9.5, weight: .semibold, design: .monospaced))
                        .monospacedDigit()
                        .foregroundStyle(isSelected ? WorkspacePalette.primaryText : WorkspacePalette.secondaryText)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.055), in: Capsule())
                } else {
                    Text(shortcut)
                        .font(.system(size: 9.5, weight: .medium))
                        .foregroundStyle(WorkspacePalette.secondaryText.opacity(isHovering || isSelected ? 1 : 0.75))
                }
            }
            .padding(.horizontal, 10)
            .frame(height: 32)
            .background(rowBackground, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(alignment: .leading) {
                Capsule()
                    .fill(isSelected ? WorkspacePalette.accent : .clear)
                    .frame(width: 2, height: 15)
                    .padding(.leading, 1)
            }
            .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var rowBackground: Color {
        if isSelected { return WorkspacePalette.accent.opacity(0.10) }
        if isHovering { return WorkspacePalette.hover }
        return .clear
    }
}
