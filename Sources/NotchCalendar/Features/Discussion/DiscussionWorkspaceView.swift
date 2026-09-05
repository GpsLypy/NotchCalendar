import SwiftUI

@MainActor
struct DiscussionWorkspaceView: View {
    @Environment(\.appLanguage) private var appLanguage
    @StateObject private var topics: RadarStore
    @StateObject private var thread: DiscussionStore
    @StateObject private var notebook: DiscussionNotebook
    @State private var feed: RadarFeed = .ask
    @State private var selected: RadarStory?
    @State private var sort = DiscussionTopicSort.discussed
    @State private var savedOnly = false
    @State private var topicRefresh = DiscussionRefreshGate()
    @State private var threadRefresh = DiscussionRefreshGate()

    init(topics: RadarStore = RadarStore(), thread: DiscussionStore = DiscussionStore(),
         notebook: DiscussionNotebook = DiscussionNotebook(), selected: RadarStory? = nil) {
        _topics = StateObject(wrappedValue: topics)
        _thread = StateObject(wrappedValue: thread)
        _notebook = StateObject(wrappedValue: notebook)
        _selected = State(initialValue: selected)
    }

    private var chinese: Bool { appLanguage.localizationIdentifier == "zh-Hans" }
    private func tr(_ zh: String, _ en: String) -> String { chinese ? zh : en }
    private var visibleStories: [RadarStory] {
        let stories = savedOnly ? notebook.savedStories : topics.stories
        switch sort {
        case .discussed: return stories.sorted { $0.commentCount > $1.commentCount }
        case .newest: return stories.sorted { $0.publishedAt > $1.publishedAt }
        case .ranked: return stories
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    sourceBand
                    if geometry.size.width >= 720 {
                        HStack(alignment: .top, spacing: 18) {
                            topicList.frame(width: 236)
                            discussion.frame(maxWidth: .infinity)
                        }
                    } else {
                        compactTopics
                        discussion
                    }
                }
                .padding(.horizontal, 26)
                .padding(.top, 52)
                .padding(.bottom, 30)
            }
        }
        .background(WorkspacePalette.canvas)
        .task(id: DiscussionTopicRequest(feed: feed, generation: topicRefresh.generation, saved: savedOnly)) {
            let force = topicRefresh.consume()
            guard !savedOnly else { return }
            await topics.load(feed, forceRefresh: force)
            guard !Task.isCancelled else { return }
            selected = visibleStories.first { $0.id == selected?.id } ?? visibleStories.first
        }
        .task(id: DiscussionThreadRequest(id: selected?.id, generation: threadRefresh.generation)) {
            let force = threadRefresh.consume()
            guard let id = selected?.id else { return }
            await thread.load(storyID: id, force: force)
        }
        .onChange(of: savedOnly) { _, _ in
            selected = visibleStories.first { $0.id == selected?.id } ?? visibleStories.first
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 5) {
                Text(tr("舆论室", "Discussion Room"))
                    .font(.system(size: 27, weight: .bold, design: .rounded))
                    .foregroundStyle(WorkspacePalette.primaryText)
                Text(tr("听见不同声音，也留下自己的判断。", "Read other perspectives. Keep your own."))
                    .font(.system(size: 12.5))
                    .foregroundStyle(WorkspacePalette.secondaryText)
            }
            Spacer(minLength: 4)
            Button {
                topicRefresh.request()
                threadRefresh.request()
            } label: { Label(tr("刷新", "Refresh"), systemImage: "arrow.clockwise") }
            .buttonStyle(.bordered)
            .disabled(topics.isLoading || topics.isRefreshing || thread.isLoading)
        }
    }

    private var sourceBand: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 20)).foregroundStyle(WorkspacePalette.accent)
                VStack(alignment: .leading, spacing: 4) {
                    Text(tr("HN 社区 · 讨论样本", "HN COMMUNITY · DISCUSSION SAMPLE"))
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(WorkspacePalette.accent)
                    Text(tr("来自 Hacker News 的真实原文，不代表全网舆论；立场与笔记只留在本机。", "Original Hacker News voices, not a measure of public opinion. Your notes and stance stay on this Mac."))
                        .font(.system(size: 11)).foregroundStyle(WorkspacePalette.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            HStack(spacing: 7) {
                sourceButton(tr("问答现场", "Ask HN"), active: feed == .ask && !savedOnly) { chooseFeed(.ask) }
                sourceButton(tr("热门话题", "Top stories"), active: feed == .hot && !savedOnly) { chooseFeed(.hot) }
                sourceButton(tr("我的留存", "My collection"), active: savedOnly) { savedOnly = true }
                Spacer(minLength: 0)
                Menu {
                    ForEach(DiscussionTopicSort.allCases) { choice in
                        Button { sort = choice } label: {
                            Label(choice.title(chinese: chinese), systemImage: sort == choice ? "checkmark" : "")
                        }
                    }
                } label: { Label(sort.title(chinese: chinese), systemImage: "arrow.up.arrow.down") }
                .menuStyle(.borderlessButton)
                .fixedSize()
                .font(.system(size: 11))
            }
        }
        .padding(15)
        .background(WorkspacePalette.elevated, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(WorkspacePalette.stroke))
    }

    private var topicList: some View {
        VStack(alignment: .leading, spacing: 8) {
            topicStatus
            ForEach(visibleStories) { story in topicButton(story, compact: false) }
        }
    }

    private var compactTopics: some View {
        VStack(alignment: .leading, spacing: 8) {
            topicStatus
            ScrollView(.horizontal) {
                HStack(alignment: .top, spacing: 8) {
                    ForEach(visibleStories) { story in topicButton(story, compact: true).frame(width: 220) }
                }
            }
            .scrollIndicators(.hidden)
        }
    }

    @ViewBuilder private var topicStatus: some View {
        if savedOnly && visibleStories.isEmpty {
            Text(tr("还没有留存。收藏话题，或写下观点，以后都能在这里找回。", "Nothing here yet. Bookmark a topic or write your take to find it here later."))
                .font(.system(size: 12)).foregroundStyle(WorkspacePalette.secondaryText)
        } else if !savedOnly && topics.stories.isEmpty && (topics.isLoading || topics.errorMessageKey == nil) {
            HStack { ProgressView().controlSize(.small); Text(tr("正在接入讨论…", "Opening the room…")) }
                .font(.system(size: 12)).foregroundStyle(WorkspacePalette.secondaryText)
        } else if !savedOnly && topics.errorMessageKey != nil {
            VStack(alignment: .leading, spacing: 8) {
                Text(topics.stories.isEmpty
                     ? tr("暂时无法加载话题，请检查网络后重试。", "Topics could not load. Check your connection and retry.")
                     : tr("刷新失败，保留上次的话题。", "Refresh failed. Previous topics are still available."))
                    .font(.system(size: 11)).foregroundStyle(.orange)
                Button(tr("重试", "Retry")) { topicRefresh.request() }.buttonStyle(.bordered)
            }
        } else {
            Text(savedOnly ? tr("本机留存 · \(visibleStories.count) 个话题", "SAVED ON THIS MAC · \(visibleStories.count)")
                 : tr("本次 \(visibleStories.count) 个话题 · \(topics.isShowingSavedData ? "缓存" : "HN 原文")", "\(visibleStories.count) TOPICS · \(topics.isShowingSavedData ? "CACHED" : "HN ORIGINALS")"))
                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                .foregroundStyle(WorkspacePalette.secondaryText)
        }
    }

    private func topicButton(_ story: RadarStory, compact: Bool) -> some View {
        Button { selected = story } label: {
            VStack(alignment: .leading, spacing: 9) {
                Text(DiscussionText.plain(story.title))
                    .font(.system(size: 12.5, weight: .semibold))
                    .foregroundStyle(WorkspacePalette.primaryText)
                    .lineLimit(compact ? 2 : 3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack(spacing: 8) {
                    Label("\(story.commentCount)", systemImage: "bubble.right")
                    Text(story.publishedAt, style: .relative).lineLimit(1)
                    Spacer(minLength: 0)
                    if notebook.takes[story.id]?.isSaved == true { Image(systemName: "bookmark.fill") }
                }
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(selected?.id == story.id ? WorkspacePalette.accent : WorkspacePalette.secondaryText)
            }
            .padding(13)
            .frame(minHeight: compact ? 84 : 75, alignment: .topLeading)
            .background(selected?.id == story.id ? WorkspacePalette.accent.opacity(0.10) : WorkspacePalette.elevated,
                        in: RoundedRectangle(cornerRadius: 11))
            .overlay(RoundedRectangle(cornerRadius: 11).stroke(selected?.id == story.id ? WorkspacePalette.accent.opacity(0.55) : WorkspacePalette.stroke))
            .contentShape(RoundedRectangle(cornerRadius: 11))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected?.id == story.id ? [.isSelected] : [])
        .help(DiscussionText.plain(story.title))
    }

    @ViewBuilder private var discussion: some View {
        if let story = selected {
            VStack(alignment: .leading, spacing: 18) {
                roomHeader(story)
                DiscussionTakeEditor(story: story, notebook: notebook).id(story.id)
                if thread.selectedID == story.id {
                    if thread.isLoading {
                        HStack { ProgressView().controlSize(.small); Text(tr("正在听取现场声音…", "Loading the conversation…")) }
                            .font(.system(size: 11)).foregroundStyle(WorkspacePalette.secondaryText)
                    }
                    if thread.loadFailed {
                        retryNotice(thread.snapshot == nil
                            ? tr("评论暂未加载，请检查网络后重试。", "Comments could not load. Check your connection and retry.")
                            : tr("评论刷新失败，继续显示上次缓存。", "Refresh failed. Showing the previous discussion."))
                    }
                    if thread.cacheWriteFailed {
                        Text(tr("评论已加载，但无法写入本机缓存。", "Comments loaded, but could not be cached on this Mac."))
                            .font(.system(size: 11)).foregroundStyle(.orange)
                    }
                    if let snapshot = thread.snapshot { commentList(snapshot) }
                }
            }
        } else if !topics.isLoading {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: "quote.bubble").font(.system(size: 28)).foregroundStyle(WorkspacePalette.accent)
                Text(tr("选一个话题，进入讨论。", "Pick a topic to enter the conversation."))
                    .font(.system(size: 16, weight: .semibold)).foregroundStyle(WorkspacePalette.primaryText)
                Text(tr("读原文、看不同观点，再记录自己的想法。", "Read the source, explore perspectives, and keep your own take."))
                    .font(.system(size: 12)).foregroundStyle(WorkspacePalette.secondaryText)
            }
            .padding(24).frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func roomHeader(_ story: RadarStory) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                Text(DiscussionText.plain(story.title))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(WorkspacePalette.primaryText).textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
                Button {
                    let take = notebook.take(for: story)
                    notebook.save(story: story, note: take.note, stance: take.stance, isSaved: !take.isSaved)
                } label: { Image(systemName: notebook.takes[story.id]?.isSaved == true ? "bookmark.fill" : "bookmark") }
                .buttonStyle(.plain).foregroundStyle(WorkspacePalette.accent)
                .accessibilityLabel(notebook.takes[story.id]?.isSaved == true ? tr("取消收藏", "Remove bookmark") : tr("收藏话题", "Bookmark thread"))
                .help(notebook.takes[story.id]?.isSaved == true ? tr("取消收藏", "Remove bookmark") : tr("收藏话题", "Bookmark thread"))
            }
            Text(tr("\(story.author ?? "HN") 发起 · \(story.commentCount) 条总评论（含回复）", "By \(story.author ?? "HN") · \(story.commentCount) comments including replies"))
                .font(.system(size: 10)).foregroundStyle(WorkspacePalette.secondaryText)
            HStack(spacing: 14) {
                Link(destination: URL(string: "https://news.ycombinator.com/item?id=\(story.id)")!) {
                    Label(tr("完整讨论", "Full discussion"), systemImage: "arrow.up.right")
                }
                if let url = DiscussionText.webURL(story.destinationURL.absoluteString) {
                    Link(tr("阅读原文", "Read source"), destination: url)
                }
            }
            .font(.system(size: 11, weight: .semibold)).tint(WorkspacePalette.accent)
            if notebook.writeFailed { Text(tr("本机保存失败，请缩短笔记或清理已有收藏后重试。", "Could not save. Shorten the note or remove older saved takes and retry."))
                .font(.system(size: 11)).foregroundStyle(.orange) }
        }
    }

    private func commentList(_ snapshot: DiscussionSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            if !snapshot.storyText.isEmpty {
                Text(snapshot.storyText).font(.system(size: 12.5)).foregroundStyle(WorkspacePalette.secondaryText)
                    .textSelection(.enabled).lineSpacing(4)
            }
            HStack {
                Text(tr("现场声音 · \(snapshot.comments.count) 条主评论", "VOICES · \(snapshot.comments.count) TOP-LEVEL COMMENTS"))
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                Spacer(minLength: 4)
                Text(snapshot.fetchedAt.formatted(.dateTime.month().day().hour().minute().locale(appLanguage.locale)))
                    .font(.system(size: 9, design: .monospaced))
            }
            .foregroundStyle(WorkspacePalette.secondaryText)
            if snapshot.failedCount > 0 { retryNotice(tr("部分评论暂未载入，保留已读内容。", "Some comments are unavailable. Loaded voices remain here.")) }
            if thread.isStale { Text(tr("包含本机缓存，时间以上次抓取为准。", "Includes cached comments from an earlier fetch."))
                .font(.system(size: 10)).foregroundStyle(.orange) }
            if snapshot.comments.isEmpty {
                Text(tr("这个话题暂时没有可展示的主评论。可以打开完整讨论查看。", "No available top-level comments yet. Open the full discussion to check for updates."))
                    .font(.system(size: 12)).foregroundStyle(WorkspacePalette.secondaryText)
            }
            ForEach(snapshot.comments) { comment in
                VStack(alignment: .leading, spacing: 9) {
                    HStack(spacing: 8) {
                        Text(String(comment.author.prefix(1)).uppercased())
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .frame(width: 26, height: 26)
                            .background(WorkspacePalette.accent.opacity(0.13), in: Circle())
                            .foregroundStyle(WorkspacePalette.accent)
                        Link(comment.author, destination: comment.authorURL)
                            .font(.system(size: 11, weight: .semibold)).tint(WorkspacePalette.primaryText)
                        Spacer(minLength: 4)
                        Text(comment.publishedAt, style: .relative)
                            .font(.system(size: 9)).foregroundStyle(WorkspacePalette.secondaryText)
                    }
                    Text(comment.text).font(.system(size: 12.5)).lineSpacing(4)
                        .foregroundStyle(WorkspacePalette.primaryText).textSelection(.enabled)
                        .fixedSize(horizontal: false, vertical: true)
                    Link(destination: comment.sourceURL) {
                        Label(comment.replyCount > 0 ? tr("原评论 · \(comment.replyCount) 条直接回复", "Original · \(comment.replyCount) direct replies") : tr("查看原评论", "View original comment"), systemImage: "arrow.up.right")
                    }
                    .font(.system(size: 10)).tint(WorkspacePalette.secondaryText)
                }
                .padding(15)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(WorkspacePalette.elevated, in: RoundedRectangle(cornerRadius: 12))
                .overlay(alignment: .leading) { UnevenRoundedRectangle(topLeadingRadius: 2, bottomLeadingRadius: 2).fill(WorkspacePalette.accent.opacity(0.4)).frame(width: 2).padding(.vertical, 15) }
            }
            Text(tr("按 HN 排序选取最多 12 条主评论，长文本会截取；不是赞反投票或舆情统计。完整内容与回复请看原帖。", "Up to 12 top-level comments in HN order; long text is excerpted. This is not sentiment scoring or a vote. Open the thread for full text and replies."))
                .font(.system(size: 10)).lineSpacing(3).foregroundStyle(WorkspacePalette.secondaryText)
        }
    }

    private func retryNotice(_ message: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(message).font(.system(size: 11)).foregroundStyle(.orange)
            Spacer(minLength: 4)
            Button(tr("重试", "Retry")) { threadRefresh.request() }
                .font(.system(size: 11)).disabled(thread.isLoading)
        }
    }

    private func sourceButton(_ label: String, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label).font(.system(size: 11, weight: .semibold))
                .padding(.horizontal, 10).padding(.vertical, 7)
                .background(active ? WorkspacePalette.accent.opacity(0.16) : .clear, in: Capsule())
                .foregroundStyle(active ? WorkspacePalette.accent : WorkspacePalette.secondaryText)
        }
        .buttonStyle(.plain).accessibilityAddTraits(active ? [.isSelected] : [])
    }

    private func chooseFeed(_ newFeed: RadarFeed) {
        if feed != newFeed { selected = nil }
        savedOnly = false
        feed = newFeed
    }
}

@MainActor
private struct DiscussionTakeEditor: View {
    let story: RadarStory
    @ObservedObject var notebook: DiscussionNotebook
    @Environment(\.appLanguage) private var language
    @State private var note: String
    @State private var stance: DiscussionStance

    init(story: RadarStory, notebook: DiscussionNotebook) {
        self.story = story
        self.notebook = notebook
        let take = notebook.take(for: story)
        _note = State(initialValue: take.note)
        _stance = State(initialValue: take.stance)
    }

    private var chinese: Bool { language.localizationIdentifier == "zh-Hans" }
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(chinese ? "我的判断" : "MY TAKE", systemImage: "pencil.line")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(WorkspacePalette.accent)
                Spacer()
                Text(notebook.writeFailed ? (chinese ? "保存失败" : "SAVE FAILED") : (chinese ? "仅本机 · 自动保存" : "ON THIS MAC · AUTO SAVED"))
                    .font(.system(size: 8.5)).foregroundStyle(WorkspacePalette.secondaryText)
            }
            Picker(chinese ? "我的立场" : "My stance", selection: $stance) {
                ForEach(DiscussionStance.allCases) { option in Text(option.title(chinese: chinese)).tag(option) }
            }
            .pickerStyle(.segmented).labelsHidden()
            ZStack(alignment: .topLeading) {
                if note.isEmpty {
                    Text(chinese ? "哪一句启发了你？还有什么需要查证？" : "What changed your mind? What needs checking?")
                        .font(.system(size: 12)).foregroundStyle(WorkspacePalette.secondaryText)
                        .padding(.top, 8).padding(.leading, 4).allowsHitTesting(false)
                }
                TextEditor(text: $note)
                    .font(.system(size: 12)).foregroundStyle(WorkspacePalette.primaryText)
                    .scrollContentBackground(.hidden).frame(minHeight: 64, maxHeight: 96)
                    .accessibilityLabel(chinese ? "本机观点笔记" : "Private take note")
            }
            HStack {
                Text(chinese ? "不会发布到 HN，也不会发送日历或笔记。" : "Never posted to HN. Calendar and notes are not sent.")
                    .font(.system(size: 9)).foregroundStyle(WorkspacePalette.secondaryText)
                Spacer(minLength: 0)
                Text("\(note.count)/2000").font(.system(size: 8, design: .monospaced))
                    .foregroundStyle(WorkspacePalette.secondaryText)
            }
        }
        .padding(13)
        .background(WorkspacePalette.accent.opacity(0.055), in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(WorkspacePalette.accent.opacity(0.22)))
        .onChange(of: note) { _, value in
            if value.count > 2_000 { note = String(value.prefix(2_000)) }
            save()
        }
        .onChange(of: stance) { _, _ in save() }
    }

    private func save() {
        notebook.save(story: story, note: note, stance: stance, isSaved: notebook.take(for: story).isSaved)
    }
}

private enum DiscussionTopicSort: String, CaseIterable, Identifiable {
    case discussed, newest, ranked
    var id: String { rawValue }
    func title(chinese: Bool) -> String {
        switch self {
        case .discussed: chinese ? "评论最多" : "Most discussed"
        case .newest: chinese ? "最近发布" : "Newest"
        case .ranked: chinese ? "来源顺序" : "Source order"
        }
    }
}
private struct DiscussionTopicRequest: Equatable {
    let feed: RadarFeed
    let generation: Int
    let saved: Bool
}
private struct DiscussionThreadRequest: Equatable {
    let id: Int?
    let generation: Int
}
