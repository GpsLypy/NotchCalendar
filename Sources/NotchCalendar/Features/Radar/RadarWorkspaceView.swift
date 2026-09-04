import AppKit
import SwiftUI

@MainActor
struct RadarWorkspaceView: View {
    @StateObject private var store: RadarStore
    @State private var loadRequest = RadarLoadRequest(
        feed: .hot,
        generation: 0,
        forceRefresh: false
    )
    @Environment(\.appLanguage) private var appLanguage

    init(store: RadarStore = RadarStore()) {
        _store = StateObject(wrappedValue: store)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                pageHeader
                signalBand
                content
                sourceNote
            }
            .padding(.horizontal, 30)
            .padding(.top, 52)
            .padding(.bottom, 30)
        }
        .background(WorkspacePalette.canvas)
        .task(id: loadRequest) {
            let request = loadRequest
            await store.load(request.feed, forceRefresh: request.forceRefresh)
        }
    }

    private var pageHeader: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .bottom, spacing: 18) {
                headerCopy
                Spacer(minLength: 20)
                refreshButton
            }

            VStack(alignment: .leading, spacing: 12) {
                headerCopy
                refreshButton
            }
        }
    }

    private var headerCopy: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(t("Radar"))
                .font(.system(size: 27, weight: .bold, design: .rounded))
                .foregroundStyle(WorkspacePalette.primaryText)
            Text(t("Ten signals, then back to your day."))
                .font(.system(size: 12.5, weight: .medium))
                .foregroundStyle(WorkspacePalette.secondaryText)
        }
    }

    private var refreshButton: some View {
        Button {
            requestRefresh()
        } label: {
            Label(
                store.isRefreshing ? t("Refreshing…") : t("Refresh"),
                systemImage: "arrow.clockwise"
            )
        }
        .buttonStyle(.bordered)
        .disabled(store.isLoading || store.isRefreshing)
        .help(t("Refresh this signal"))
    }

    private var signalBand: some View {
        WorkspaceCard {
            VStack(spacing: 0) {
                HStack(spacing: 13) {
                    SignalGlyph(feed: selectedFeed, isStale: store.isShowingSavedData)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(t("LIVE SIGNAL"))
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .tracking(1.15)
                            .foregroundStyle(
                                store.isShowingSavedData ? Color.orange : WorkspacePalette.accent
                            )
                        Text(t(selectedFeed.detailKey))
                            .font(.system(size: 12.5, weight: .semibold, design: .rounded))
                            .foregroundStyle(WorkspacePalette.primaryText)
                            .lineLimit(1)
                    }

                    Spacer(minLength: 12)

                    if let fetchedAt = store.fetchedAt {
                        VStack(alignment: .trailing, spacing: 3) {
                            Text(store.isShowingSavedData ? t("SAVED") : t("UPDATED"))
                                .font(.system(size: 8.5, weight: .bold, design: .monospaced))
                                .tracking(0.8)
                            Text(formattedUpdateTime(fetchedAt))
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .monospacedDigit()
                        }
                        .foregroundStyle(WorkspacePalette.secondaryText)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)

                Rectangle()
                    .fill(WorkspacePalette.stroke)
                    .frame(height: 1)

                HStack(spacing: 6) {
                    ForEach(RadarFeed.allCases) { feed in
                        RadarFeedButton(
                            title: t(feed.titleKey),
                            isSelected: selectedFeed == feed
                        ) {
                            select(feed)
                        }
                    }
                }
                .padding(7)
            }
        }
    }

    @ViewBuilder private var content: some View {
        if store.isLoading || (store.stories.isEmpty && store.errorMessageKey == nil) {
            statusCard(
                symbol: "dot.radiowaves.left.and.right",
                title: t("Tuning the signal…"),
                detail: t("Fetching a short briefing from Hacker News."),
                showsProgress: true
            )
        } else if store.stories.isEmpty {
            statusCard(
                symbol: "wifi.exclamationmark",
                title: t(store.errorMessageKey ?? "Radar could not load right now."),
                detail: t("Check your connection, then try again."),
                actionTitle: t("Retry")
            ) {
                requestRefresh()
            }
        } else {
            VStack(alignment: .leading, spacing: 10) {
                if let errorMessageKey = store.errorMessageKey {
                    Label(t(errorMessageKey), systemImage: "clock.badge.exclamationmark")
                        .font(.system(size: 10.5, weight: .medium))
                        .foregroundStyle(Color.orange)
                        .padding(.horizontal, 2)
                        .accessibilityLabel(t(errorMessageKey))
                }

                WorkspaceCard {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(store.stories.enumerated()), id: \.element.id) { index, story in
                            RadarStoryRow(
                                rank: index + 1,
                                story: story,
                                relativeTo: store.fetchedAt ?? Date()
                            ) {
                                NSWorkspace.shared.open(story.destinationURL)
                            }

                            if index < store.stories.count - 1 {
                                Rectangle()
                                    .fill(WorkspacePalette.stroke)
                                    .frame(height: 1)
                                    .padding(.leading, 62)
                            }
                        }
                    }
                }
            }
        }
    }

    private var sourceNote: some View {
        HStack(spacing: 6) {
            Text(t("Source: Hacker News"))
            Text("·")
            Text(t("Links open in your default browser"))
        }
        .font(.system(size: 9.5, weight: .medium, design: .monospaced))
        .foregroundStyle(WorkspacePalette.secondaryText.opacity(0.78))
        .padding(.horizontal, 2)
    }

    private func statusCard(
        symbol: String,
        title: String,
        detail: String,
        showsProgress: Bool = false,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) -> some View {
        WorkspaceCard {
            VStack(spacing: 12) {
                if showsProgress {
                    ProgressView()
                        .controlSize(.small)
                        .tint(WorkspacePalette.accent)
                } else {
                    Image(systemName: symbol)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(WorkspacePalette.accent)
                }
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(WorkspacePalette.primaryText)
                Text(detail)
                    .font(.system(size: 11.5))
                    .foregroundStyle(WorkspacePalette.secondaryText)
                    .multilineTextAlignment(.center)
                if let actionTitle, let action {
                    Button(actionTitle, action: action)
                        .buttonStyle(.borderedProminent)
                        .tint(WorkspacePalette.accent)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 210)
            .padding(20)
        }
    }

    private func formattedUpdateTime(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return date.formatted(.dateTime.hour().minute().locale(appLanguage.locale))
        }
        return date.formatted(
            .dateTime.month(.abbreviated).day().hour().minute().locale(appLanguage.locale)
        )
    }

    private var selectedFeed: RadarFeed { loadRequest.feed }

    private func select(_ feed: RadarFeed) {
        guard feed != loadRequest.feed else { return }
        loadRequest = RadarLoadRequest(
            feed: feed,
            generation: loadRequest.generation &+ 1,
            forceRefresh: false
        )
    }

    private func requestRefresh() {
        loadRequest = RadarLoadRequest(
            feed: loadRequest.feed,
            generation: loadRequest.generation &+ 1,
            forceRefresh: true
        )
    }

    private func t(_ key: String, _ arguments: CVarArg...) -> String {
        L10n.string(key, language: appLanguage, arguments: arguments)
    }
}

private struct RadarLoadRequest: Equatable {
    let feed: RadarFeed
    let generation: Int
    let forceRefresh: Bool
}

private struct SignalGlyph: View {
    let feed: RadarFeed
    let isStale: Bool

    private var activeIndex: Int {
        RadarFeed.allCases.firstIndex(of: feed) ?? 0
    }

    var body: some View {
        HStack(alignment: .center, spacing: 2.5) {
            ForEach(0..<7, id: \.self) { index in
                Capsule()
                    .fill(color.opacity(opacity(for: index)))
                    .frame(width: 2.5, height: height(for: index))
            }
        }
        .frame(width: 32, height: 28)
        .accessibilityHidden(true)
    }

    private var color: Color {
        isStale ? .orange : WorkspacePalette.accent
    }

    private func height(for index: Int) -> CGFloat {
        let patterns: [[CGFloat]] = [
            [6, 13, 21, 11, 25, 16, 8],
            [18, 8, 23, 13, 7, 20, 11],
            [9, 20, 12, 25, 15, 7, 18]
        ]
        return patterns[activeIndex][index]
    }

    private func opacity(for index: Int) -> Double {
        index == activeIndex + 2 ? 1 : 0.48
    }
}

private struct RadarFeedButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 11.5, weight: isSelected ? .bold : .medium, design: .rounded))
                .foregroundStyle(
                    isSelected ? WorkspacePalette.primaryText : WorkspacePalette.secondaryText
                )
                .frame(maxWidth: .infinity)
                .frame(height: 30)
                .background(
                    isSelected ? WorkspacePalette.accent.opacity(0.16) : Color.clear,
                    in: RoundedRectangle(cornerRadius: 8, style: .continuous)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(
                            isSelected ? WorkspacePalette.accent.opacity(0.28) : Color.clear,
                            lineWidth: 1
                        )
                }
                .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct RadarStoryRow: View {
    let rank: Int
    let story: RadarStory
    let relativeTo: Date
    let action: () -> Void

    @State private var isHovering = false
    @Environment(\.appLanguage) private var appLanguage

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 15) {
                Text(String(format: "%02d", rank))
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .monospacedDigit()
                    .foregroundStyle(
                        rank <= 3 ? WorkspacePalette.accent : WorkspacePalette.secondaryText
                    )
                    .frame(width: 30, alignment: .leading)
                    .padding(.top, 2)

                VStack(alignment: .leading, spacing: 7) {
                    Text(story.title)
                        .font(.system(size: 13.5, weight: .semibold, design: .rounded))
                        .foregroundStyle(WorkspacePalette.primaryText)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)

                    HStack(spacing: 7) {
                        Text(story.sourceLabel)
                        metadataDivider
                        Text(t("%@ points", "\(story.score)"))
                        metadataDivider
                        Text(t("%@ comments", "\(story.commentCount)"))
                        if let author = story.author {
                            metadataDivider
                            Text(t("by %@", author))
                        }
                        metadataDivider
                        Text(relativeAge)
                    }
                    .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                    .monospacedDigit()
                    .foregroundStyle(WorkspacePalette.secondaryText)
                    .lineLimit(1)
                }

                Spacer(minLength: 8)

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(
                        isHovering ? WorkspacePalette.accent : WorkspacePalette.secondaryText.opacity(0.6)
                    )
                    .padding(.top, 3)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isHovering ? WorkspacePalette.hover : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
        .accessibilityLabel(story.title)
        .accessibilityValue(
            "\(t("%@ points", "\(story.score)")), \(t("%@ comments", "\(story.commentCount)"))"
        )
        .accessibilityHint(t("Opens in your default browser"))
        .help(t("Open %@", story.title))
    }

    private var metadataDivider: some View {
        Text("·")
            .accessibilityHidden(true)
    }

    private var relativeAge: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = appLanguage.locale
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: story.publishedAt, relativeTo: relativeTo)
    }

    private func t(_ key: String, _ arguments: CVarArg...) -> String {
        L10n.string(key, language: appLanguage, arguments: arguments)
    }
}
