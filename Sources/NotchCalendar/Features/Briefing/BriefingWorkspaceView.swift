import AppKit
import SwiftUI

@MainActor
struct BriefingWorkspaceView: View {
    @StateObject private var store: BriefingStore
    @State private var refreshGeneration = 0
    @State private var couldNotOpen = false
    @Environment(\.appLanguage) private var appLanguage

    init(store: BriefingStore = BriefingStore()) {
        _store = StateObject(wrappedValue: store)
    }

    private var chinese: Bool { appLanguage.localizationIdentifier == "zh-Hans" }
    private func t(_ zh: String, _ en: String) -> String { chinese ? zh : en }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                sourceDesk
                filters
                notices
                content
                footer
            }
            .padding(.horizontal, 28)
            .padding(.top, 50)
            .padding(.bottom, 28)
        }
        .background(WorkspacePalette.canvas)
        .task(id: refreshGeneration) {
            await store.load(forceRefresh: refreshGeneration > 0)
        }
    }

    private var header: some View {
        HStack(alignment: .bottom, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(t("信息差简报", "Briefing"))
                    .font(.system(size: 27, weight: .bold, design: .rounded))
                    .foregroundStyle(WorkspacePalette.primaryText)
                Text(t("从一手来源出发，每次最多 20 条。", "Start at the source. Up to 20 headlines at a time."))
                    .font(.system(size: 12))
                    .foregroundStyle(WorkspacePalette.secondaryText)
            }
            Spacer(minLength: 0)
            Button { refreshGeneration += 1 } label: {
                Label(store.isLoading ? t("更新中…", "Refreshing…") : t("刷新", "Refresh"), systemImage: "arrow.clockwise")
            }
            .buttonStyle(.bordered)
            .disabled(store.isLoading)
            .help(t("更新三个来源的最新简报", "Refresh all three sources"))
        }
    }

    private var sourceDesk: some View {
        WorkspaceCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 8) {
                    Image(systemName: "text.book.closed")
                        .foregroundStyle(WorkspacePalette.accent)
                    Text(t("公开一手来源", "PUBLIC PRIMARY SOURCES"))
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .tracking(chinese ? 1 : 1.2)
                    Spacer()
                    Text(t("本地收藏 \(store.library.saved.count)/100", "Saved locally · \(store.library.saved.count)/100"))
                        .font(.system(size: 10, design: .monospaced))
                }
                .foregroundStyle(WorkspacePalette.secondaryText)

                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 5) { sourceButtons }
                    VStack(alignment: .leading, spacing: 7) { sourceButtons }
                }

                if let source = store.selectedSource {
                    sourceStatus(source)
                    Text(source.purpose(chinese: chinese))
                        .font(.system(size: 11))
                        .foregroundStyle(WorkspacePalette.secondaryText)
                } else {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), alignment: .leading)], alignment: .leading, spacing: 10) {
                        ForEach(BriefingSource.allCases) { source in sourceStatus(source) }
                    }
                }
            }
            .padding(16)
        }
    }

    @ViewBuilder private var sourceButtons: some View {
        sourceButton(title: t("全部", "All sources"), symbol: "square.stack", selected: store.selectedSource == nil) { store.selectedSource = nil }
        ForEach(BriefingSource.allCases) { source in
            sourceButton(title: source.name, symbol: source.symbol, selected: store.selectedSource == source) { store.selectedSource = source }
        }
    }

    private func sourceButton(title: String, symbol: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: symbol)
                .font(.system(size: 11, weight: selected ? .semibold : .medium))
                .foregroundStyle(selected ? WorkspacePalette.canvas : WorkspacePalette.primaryText)
                .padding(.horizontal, 11)
                .padding(.vertical, 9)
                .background(selected ? WorkspacePalette.accent : WorkspacePalette.hover, in: RoundedRectangle(cornerRadius: 9))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private func sourceStatus(_ source: BriefingSource) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Circle()
                .fill(store.failedSources.contains(source) || store.isStale(source) ? Color.orange : (store.snapshots[source] == nil ? WorkspacePalette.secondaryText : WorkspacePalette.success))
                .frame(width: 5, height: 5)
                .padding(.top, 4)
            VStack(alignment: .leading, spacing: 3) {
                Text(source.name)
                    .font(.system(size: 10.5, weight: .semibold))
                    .foregroundStyle(WorkspacePalette.primaryText)
                Text(statusText(source))
                    .font(.system(size: 9.5, design: .monospaced))
                    .foregroundStyle(WorkspacePalette.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private func statusText(_ source: BriefingSource) -> String {
        guard let snapshot = store.snapshots[source] else {
            return store.failedSources.contains(source) ? t("暂不可用 · 可重试", "Unavailable · retry") : t("正在连接来源…", "Connecting…")
        }
        let label = store.isStale(source) ? t("旧缓存", "Older cache") : (store.cachedSources.contains(source) ? t("缓存", "Cached") : t("已更新", "Updated"))
        let stamp = snapshot.fetchedAt.formatted(.dateTime.month(.twoDigits).day(.twoDigits).hour().minute().locale(appLanguage.locale))
        return "\(label) · \(stamp)"
    }

    private var filters: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 12) {
                filterPicker.frame(width: chinese ? 226 : 250)
                Spacer(minLength: 4)
                searchField.frame(width: 200)
            }
            VStack(alignment: .leading, spacing: 10) {
                filterPicker
                searchField
            }
        }
    }

    private var filterPicker: some View {
        Picker(t("阅读筛选", "Reading filter"), selection: $store.filter) {
            Text(t("最新", "Latest")).tag(BriefingFilter.latest)
            Text(t("未读", "Unread")).tag(BriefingFilter.unread)
            Text(t("收藏", "Saved")).tag(BriefingFilter.saved)
        }
        .labelsHidden()
        .pickerStyle(.segmented)
    }

    private var searchField: some View {
        HStack(spacing: 7) {
            Image(systemName: "magnifyingglass").foregroundStyle(WorkspacePalette.secondaryText)
            TextField(t("搜索标题、来源或主题", "Search title, source or topic"), text: $store.search)
                .textFieldStyle(.plain)
                .accessibilityLabel(t("搜索已加载的简报", "Search loaded briefing headlines"))
            if !store.search.isEmpty {
                Button { store.search = "" } label: { Image(systemName: "xmark.circle.fill") }
                    .buttonStyle(.plain)
                    .foregroundStyle(WorkspacePalette.secondaryText)
                    .accessibilityLabel(t("清除搜索", "Clear search"))
            }
        }
        .font(.system(size: 11))
        .padding(8)
        .background(WorkspacePalette.elevated, in: RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(WorkspacePalette.stroke))
    }

    @ViewBuilder private var notices: some View {
        if !store.failedSources.isEmpty {
            let names = BriefingSource.allCases.filter { store.failedSources.contains($0) }.map(\.name).joined(separator: "、")
            notice(t("\(names) 暂时未能更新；已有内容和收藏仍可查看。可点击刷新重试。", "Could not refresh \(names). Cached headlines and saved items remain available. Refresh to retry."), symbol: "wifi.exclamationmark")
        }
        if store.cacheWriteFailed {
            notice(t("本次内容已加载，但未能写入缓存。", "Headlines loaded, but could not be saved to the cache."), symbol: "externaldrive.badge.exclamationmark")
        }
        if store.savedLimitReached {
            notice(t("收藏已满 100 条，取消一些收藏后即可继续添加。", "Your 100-item shelf is full. Remove a saved item to add another."), symbol: "bookmark")
        }
        if couldNotOpen {
            notice(t("无法打开原文，请检查默认浏览器设置后重试。", "Could not open the article. Check your default browser and try again."), symbol: "globe")
        }
    }

    private func notice(_ text: String, symbol: String) -> some View {
        Label(text, systemImage: symbol)
            .font(.system(size: 11))
            .foregroundStyle(Color.orange)
            .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder private var content: some View {
        let articles = store.visibleArticles
        if articles.isEmpty {
            emptyState
        } else {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(store.filter == .saved ? t("你的阅读书架", "YOUR READING SHELF") : t("本次简报", "THIS EDITION"))
                    Spacer()
                    Text(t("\(articles.count) 条", "\(articles.count) headlines"))
                }
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundStyle(WorkspacePalette.secondaryText)
                .padding(.horizontal, 2)
                WorkspaceCard {
                    LazyVStack(spacing: 0) {
                        ForEach(articles) { article in
                            articleRow(article)
                            if article.id != articles.last?.id {
                                Rectangle().fill(WorkspacePalette.stroke).frame(height: 1).padding(.horizontal, 16)
                            }
                        }
                    }
                }
                Text(store.filter == .saved
                     ? t("收藏保留在本机，即使原条目移出最新列表，也能再次找到。", "Saved headlines stay on this Mac after they leave the latest list.")
                     : t("已到本期结尾。需要更多时，切换来源或主动刷新。", "You have reached the end. Choose a source or refresh when you want more."))
                    .font(.system(size: 10))
                    .foregroundStyle(WorkspacePalette.secondaryText)
                    .padding(.top, 5)
            }
        }
    }

    private func articleRow(_ article: BriefingArticle) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 7) {
                Text(article.source.name)
                    .foregroundStyle(WorkspacePalette.accent)
                Text("·")
                Text(article.dateKind == .updated ? t("更新", "Updated") : t("发布", "Published"))
                Text(article.publishedAt.formatted(.dateTime.year().month(.twoDigits).day(.twoDigits).locale(appLanguage.locale)))
                Spacer(minLength: 0)
                if store.isRead(article) { Text(t("已读", "Read")) }
                else { Circle().fill(WorkspacePalette.accent).frame(width: 5, height: 5).accessibilityLabel(t("未读", "Unread")) }
            }
            .font(.system(size: 10, weight: .medium, design: .monospaced))
            .foregroundStyle(WorkspacePalette.secondaryText)

            Button {
                guard let safeURL = BriefingArticle.safeURL(article.url.absoluteString) else { couldNotOpen = true; return }
                let opened = NSWorkspace.shared.open(safeURL)
                couldNotOpen = !opened
                if opened { store.markRead(article) }
            } label: {
                HStack(alignment: .top, spacing: 10) {
                    Text(article.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(store.isRead(article) ? WorkspacePalette.secondaryText : WorkspacePalette.primaryText)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(WorkspacePalette.secondaryText)
                        .padding(.top, 3)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help(t("在默认浏览器打开原文", "Open the original in your default browser"))

            HStack(spacing: 8) {
                Text(article.topic.label(chinese: chinese))
                    .font(.system(size: 9.5, weight: .medium))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 4)
                    .background(WorkspacePalette.hover, in: Capsule())
                    .help(t("依据标题关键词与来源自动分类", "Rule-based topic from the headline and source"))
                Spacer()
                Button { store.toggleRead(article) } label: {
                    Image(systemName: store.isRead(article) ? "checkmark.circle.fill" : "checkmark.circle")
                }
                .help(store.isRead(article) ? t("标为未读", "Mark unread") : t("标为已读", "Mark read"))
                .accessibilityLabel(store.isRead(article) ? t("标为未读", "Mark unread") : t("标为已读", "Mark read"))
                Button { store.toggleSaved(article) } label: {
                    Image(systemName: store.isSaved(article) ? "bookmark.fill" : "bookmark")
                        .foregroundStyle(store.isSaved(article) ? WorkspacePalette.accent : WorkspacePalette.secondaryText)
                }
                .help(store.isSaved(article) ? t("取消收藏", "Remove saved item") : t("收藏原文", "Save article"))
                .accessibilityLabel(store.isSaved(article) ? t("取消收藏", "Remove saved item") : t("收藏原文", "Save article"))
            }
            .buttonStyle(.borderless)
            .foregroundStyle(WorkspacePalette.secondaryText)
        }
        .padding(16)
    }

    private var emptyState: some View {
        WorkspaceCard {
            VStack(spacing: 12) {
                if store.isLoading && store.filter != .saved {
                    ProgressView().controlSize(.small)
                    Text(t("正在整理一手简报…", "Gathering headlines from the source…"))
                } else {
                    Image(systemName: store.filter == .saved ? "bookmark" : "newspaper")
                        .font(.system(size: 26))
                        .foregroundStyle(WorkspacePalette.accent)
                    Text(emptyTitle).font(.system(size: 15, weight: .semibold))
                    Text(emptyDetail)
                        .font(.system(size: 11))
                        .foregroundStyle(WorkspacePalette.secondaryText)
                        .multilineTextAlignment(.center)
                    if !store.failedSources.isEmpty && store.filter != .saved {
                        Button(t("重新加载", "Try again")) { refreshGeneration += 1 }.buttonStyle(.bordered)
                    } else if !store.search.isEmpty || store.selectedSource != nil {
                        Button(t("清除筛选", "Clear filters")) { store.search = ""; store.selectedSource = nil }.buttonStyle(.bordered)
                    }
                }
            }
            .foregroundStyle(WorkspacePalette.primaryText)
            .frame(maxWidth: .infinity, minHeight: 170)
            .padding(24)
        }
    }

    private var emptyTitle: String {
        if !store.search.isEmpty { return t("没有匹配的简报", "No matching headlines") }
        if store.filter == .saved { return t("书架上还没有这类收藏", "No saved headlines here yet") }
        if !store.failedSources.isEmpty { return t("暂时无法获取这个来源", "This source is currently unavailable") }
        if store.filter == .unread { return t("这里的简报都读过了", "You are all caught up here") }
        return t("简报还未就绪", "Your briefing is not ready yet")
    }

    private var emptyDetail: String {
        if !store.search.isEmpty { return t("只搜索已加载的标题、来源与主题。试试更短的关键词。", "Search covers loaded titles, sources and topics. Try a shorter keyword.") }
        if store.filter == .saved { return t("点击标题下的书签，稍后在这里继续阅读。", "Use the bookmark below a headline to find it here later.") }
        if !store.failedSources.isEmpty { return t("检查网络后重试，或切换其他来源。", "Check your connection and retry, or choose another source.") }
        return t("可以切回最新列表，或主动刷新来源。", "Switch to Latest or refresh the sources.")
    }

    private var footer: some View {
        Text(t("标题与日期来自官方订阅源，按来源日期倒序排列；主题为标题关键词与来源的规则分类，不是内容摘要。搜索、已读和收藏保留在本机。缓存 30 分钟，进入页面或点击刷新时更新；原文在浏览器打开。", "Original headlines and dates from official feeds, newest source date first. Topics use headline keywords and source rules, not article summaries. Search, reading state and bookmarks stay on this Mac. The 30-minute cache is checked when opening this page; refresh manually any time. Originals open in your browser."))
            .font(.system(size: 10))
            .lineSpacing(3)
            .foregroundStyle(WorkspacePalette.secondaryText.opacity(0.85))
            .fixedSize(horizontal: false, vertical: true)
    }
}
