import SwiftUI

@MainActor
struct MarketWorkspaceView: View {
    @StateObject private var store: MarketStore
    @State private var symbolInput = ""
    @State private var keyInput = ""
    @State private var showsConnection = false
    @Environment(\.appLanguage) private var language

    init(store: MarketStore = MarketStore()) {
        _store = StateObject(wrappedValue: store)
    }

    private var chinese: Bool { language.localizationIdentifier == "zh-Hans" }
    private func t(_ zh: String, _ en: String) -> String { chinese ? zh : en }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                sourceBand
                if !store.hasAPIKey || showsConnection { connectionCard }
                if let notice = store.notice {
                    Label(notice.message(chinese: chinese), systemImage: notice == .verified || notice == .saved || notice == .allFresh ? "info.circle" : "exclamationmark.circle")
                        .font(.system(size: 12))
                        .foregroundStyle(WorkspacePalette.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("markets.notice")
                }
                watchlistControls
                if store.watchlist.isEmpty {
                    WorkspaceCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(t("把好奇心放进自选", "Make room for your curiosity"))
                                .font(.system(size: 18, weight: .semibold))
                            Text(t("输入一只美股代码开始观察，例如 AAPL。最多保留 8 只，让注意力有边界。", "Add a US ticker such as AAPL to begin. Keep up to 8 symbols in a focused watchlist."))
                                .font(.system(size: 12))
                                .foregroundStyle(WorkspacePalette.secondaryText)
                        }.padding(20).frame(maxWidth: .infinity, alignment: .leading)
                    }
                } else {
                    TimelineView(.periodic(from: .now, by: 60)) { context in
                        VStack(spacing: 12) {
                            ForEach(store.watchlist, id: \.self) { symbol in
                                quoteCard(symbol, at: context.date)
                            }
                        }
                    }
                }
                footer
            }
            .padding(.horizontal, 30)
            .padding(.top, 52)
            .padding(.bottom, 30)
        }
        .background(WorkspacePalette.canvas)
        .foregroundStyle(WorkspacePalette.primaryText)
        .onAppear { store.updateBudget() }
        .onDisappear { store.cancelRefresh(); keyInput = "" }
    }

    private var header: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .bottom) { headerText; Spacer(); refreshButton }
            VStack(alignment: .leading, spacing: 12) { headerText; refreshButton }
        }
    }

    private var headerText: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(t("行情观察台", "Market watch"))
                .font(.system(size: 27, weight: .bold, design: .rounded))
            Text(t("看一眼市场，回到自己的节奏。", "A glance at the market. Back to your own rhythm."))
                .font(.system(size: 12.5, weight: .medium))
                .foregroundStyle(WorkspacePalette.secondaryText)
        }
    }

    private var refreshButton: some View {
        Group {
            if store.isRefreshing {
                Button { store.cancelRefresh() } label: { Label(t("停止", "Stop"), systemImage: "stop.circle") }
            } else {
                Button { store.startRefresh() } label: { Label(t("刷新行情", "Refresh quotes"), systemImage: "arrow.clockwise") }
                    .disabled(!store.hasAPIKey || store.watchlist.isEmpty)
            }
        }
        .buttonStyle(.bordered)
        .accessibilityIdentifier("markets.refresh")
    }

    private var sourceBand: some View {
        WorkspaceCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "chart.xyaxis.line")
                        .font(.system(size: 24, weight: .light))
                        .foregroundStyle(WorkspacePalette.accent)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("ALPHA VANTAGE · US")
                            .font(.system(size: 9, weight: .bold, design: .monospaced)).tracking(1)
                        Text(t("收盘行情 · 非实时", "End-of-day quotes · Not realtime"))
                            .font(.system(size: 13, weight: .semibold))
                    }
                    Spacer(minLength: 8)
                    Button { showsConnection.toggle() } label: {
                        Label(store.hasAPIKey ? t("数据连接", "Connection") : t("连接设置", "Set up"), systemImage: store.hasAPIKey ? "key.fill" : "key")
                            .font(.system(size: 11))
                    }.buttonStyle(.borderless)
                }
                Divider().overlay(WorkspacePalette.stroke)
                if store.isRefreshing {
                    HStack(spacing: 10) {
                        ProgressView().controlSize(.small)
                        Text(t("正在读取", "Loading") + " \(store.completedRequests) / \(store.plannedRequests)")
                        Spacer()
                        Text(t("已更新", "Updated") + " \(store.updatedCount)")
                    }.font(.system(size: 11, design: .monospaced))
                } else {
                    ViewThatFits(in: .horizontal) {
                        HStack { budgetLabel; Spacer(); cacheLabel }
                        VStack(alignment: .leading, spacing: 5) { budgetLabel; cacheLabel }
                    }
                    if store.completedRequests > 0 {
                        Text(t("本轮已更新", "Updated this refresh") + " \(store.updatedCount) / \(store.plannedRequests) " + t("只", "symbols"))
                            .font(.system(size: 10.5)).foregroundStyle(WorkspacePalette.secondaryText)
                    }
                }
            }.padding(16)
        }
    }

    private var budgetLabel: some View {
        Text(t("本机剩余额度", "Local requests left") + " \(store.remainingRequests)/25 · 24h")
            .font(.system(size: 10.5, design: .monospaced))
            .foregroundStyle(WorkspacePalette.secondaryText)
    }

    private var cacheLabel: some View {
        Text(t("手动刷新 · 缓存 15 分钟", "Manual refresh · 15 min cache"))
            .font(.system(size: 10.5)).foregroundStyle(WorkspacePalette.secondaryText)
    }

    private var connectionCard: some View {
        WorkspaceCard {
            VStack(alignment: .leading, spacing: 12) {
                Text(store.hasAPIKey ? t("个人数据连接", "Your data connection") : t("连接你的行情数据", "Connect your market data"))
                    .font(.system(size: 16, weight: .semibold))
                Text(t("使用自己的 Alpha Vantage 密钥。密钥仅保存在本机钥匙串；股票代码和密钥只会在你点击刷新或验证时发送给数据源。", "Use your own Alpha Vantage key, stored only in this Mac’s Keychain. Your symbols and key are sent to the provider only when you refresh or verify."))
                    .font(.system(size: 12)).foregroundStyle(WorkspacePalette.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
                HStack {
                    if let url = URL(string: "https://www.alphavantage.co/support/#api-key") {
                        Link(t("申请个人密钥 ↗", "Get a personal key ↗"), destination: url)
                    }
                    if let url = URL(string: "https://www.alphavantage.co/terms_of_service/") {
                        Link(t("服务条款 ↗", "Provider terms ↗"), destination: url)
                    }
                }.font(.system(size: 11)).tint(WorkspacePalette.accent)
                SecureField(store.hasAPIKey ? t("输入新密钥以替换", "Enter a replacement key") : t("粘贴个人 API 密钥", "Paste your personal API key"), text: $keyInput)
                    .textFieldStyle(.roundedBorder)
                    .accessibilityIdentifier("markets.apiKey")
                    .onSubmit { saveKey(verify: false) }
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 10) { keyButtons }
                    VStack(alignment: .leading, spacing: 10) { keyButtons }
                }
                Text(t("免费套餐通常每日 25 次，每只股票消耗 1 次。仅供个人观察；付费及商业数据权限以服务商约定为准。", "The free plan usually allows 25 daily calls; each symbol uses one. For personal monitoring. Paid and commercial data access follow the provider’s agreement."))
                    .font(.system(size: 10.5)).foregroundStyle(WorkspacePalette.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }.padding(18)
        }
    }

    @ViewBuilder
    private var keyButtons: some View {
        Button(t("保存密钥", "Save key")) { saveKey(verify: false) }
            .buttonStyle(.borderedProminent).tint(WorkspacePalette.accent)
            .disabled(keyInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || store.isRefreshing)
        Button(t("保存并验证", "Save and verify")) { saveKey(verify: true) }
            .buttonStyle(.bordered)
            .disabled(keyInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || store.isRefreshing || store.watchlist.isEmpty)
            .help(t("请求自选第一只股票，消耗 1 次额度。", "Fetch the first watchlist symbol using one request."))
        if store.hasAPIKey {
            Button(t("移除密钥", "Remove key")) { store.removeKey(); keyInput = "" }
                .buttonStyle(.borderless).foregroundStyle(WorkspacePalette.secondaryText)
        }
    }

    private var watchlistControls: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(t("我的自选", "My watchlist")).font(.system(size: 14, weight: .semibold))
                Text("\(store.watchlist.count)/8").font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(WorkspacePalette.secondaryText)
                Spacer()
                if !store.quotes.isEmpty {
                    Button(t("清除行情缓存", "Clear quote cache")) { store.clearCache() }
                        .buttonStyle(.borderless).font(.system(size: 10.5))
                        .foregroundStyle(WorkspacePalette.secondaryText)
                }
            }
            HStack(spacing: 10) {
                TextField(t("美股代码，例如 AAPL", "US ticker, e.g. AAPL"), text: $symbolInput)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit(addSymbol)
                    .accessibilityIdentifier("markets.symbol")
                Button { addSymbol() } label: { Label(t("添加", "Add"), systemImage: "plus") }
                    .buttonStyle(.bordered)
                    .disabled(symbolInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || store.isRefreshing)
            }
        }
    }

    private func quoteCard(_ symbol: String, at date: Date) -> some View {
        WorkspaceCard {
            VStack(alignment: .leading, spacing: 13) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(symbol).font(.system(size: 17, weight: .bold, design: .monospaced))
                        Text(t("美股 · USD", "US · USD")).font(.system(size: 10))
                            .foregroundStyle(WorkspacePalette.secondaryText)
                    }
                    Spacer()
                    if let quote = store.quotes[symbol] {
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(quote.price, format: .number.precision(.fractionLength(2...4)))
                                .font(.system(size: 23, weight: .semibold, design: .monospaced))
                            Text(String(format: "%+.2f (%+.2f%%)", quote.change, quote.changePercent))
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                .foregroundStyle(quote.change >= 0 ? WorkspacePalette.success : WorkspacePalette.accent)
                        }
                    } else {
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("—").font(.system(size: 23, design: .monospaced))
                            Text(store.hasAPIKey ? t("等待手动刷新", "Ready to refresh") : t("连接数据后显示", "Connect to load"))
                                .font(.system(size: 10)).foregroundStyle(WorkspacePalette.secondaryText)
                        }
                    }
                    rowActions(symbol)
                }
                if let quote = store.quotes[symbol] {
                    if let low = quote.low, let high = quote.high {
                        rangeView(low: low, high: high, price: quote.price)
                    }
                    ViewThatFits(in: .horizontal) {
                        HStack { dataDate(quote); Spacer(); cacheDate(quote, at: date) }
                        VStack(alignment: .leading, spacing: 5) { dataDate(quote); cacheDate(quote, at: date) }
                    }
                }
                if let error = store.errors[symbol] {
                    Label(error.message(chinese: chinese), systemImage: "exclamationmark.triangle")
                        .font(.system(size: 10.5)).foregroundStyle(WorkspacePalette.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }.padding(16)
        }
    }

    private func rowActions(_ symbol: String) -> some View {
        Menu {
            Button(t("上移", "Move up")) { store.move(symbol, offset: -1) }
                .disabled(store.watchlist.first == symbol)
            Button(t("下移", "Move down")) { store.move(symbol, offset: 1) }
                .disabled(store.watchlist.last == symbol)
            Divider()
            Button(t("移除自选", "Remove symbol"), role: .destructive) { store.remove(symbol) }
        } label: { Image(systemName: "ellipsis").frame(width: 20, height: 22) }
        .menuStyle(.borderlessButton)
        .fixedSize()
        .accessibilityLabel(t("管理自选", "Manage symbol") + " " + symbol)
    }

    private func rangeView(low: Double, high: Double, price: Double) -> some View {
        VStack(spacing: 5) {
            HStack {
                Text(t("当日区间", "Day range"))
                Spacer()
                Text(String(format: "%.2f — %.2f", low, high))
            }.font(.system(size: 9.5, design: .monospaced)).foregroundStyle(WorkspacePalette.secondaryText)
            GeometryReader { geometry in
                let fraction = high > low ? min(1, max(0, (price - low) / (high - low))) : 0.5
                Capsule().fill(WorkspacePalette.stroke).frame(height: 3)
                Circle().fill(WorkspacePalette.accent).frame(width: 6, height: 6)
                    .offset(x: max(0, (geometry.size.width - 6) * fraction), y: -1.5)
            }.frame(height: 5)
                .accessibilityLabel(t("收盘价在当日价格区间中的位置", "Closing price within the daily range"))
        }
    }

    private func dataDate(_ quote: MarketQuote) -> some View {
        Text(t("数据日", "Trading day") + " " + quote.tradingDay)
            .font(.system(size: 9.5, design: .monospaced)).foregroundStyle(WorkspacePalette.secondaryText)
    }

    private func cacheDate(_ quote: MarketQuote, at date: Date) -> some View {
        HStack(spacing: 5) {
            Image(systemName: quote.isFresh(at: date) ? "clock" : "clock.badge.exclamationmark")
            Text(quote.fetchedAt.formatted(date: .abbreviated, time: .shortened))
            Text(quote.isFresh(at: date) ? t("读取", "fetched") : t("缓存已过期", "cache expired"))
        }.font(.system(size: 9.5)).foregroundStyle(WorkspacePalette.secondaryText)
    }

    private var footer: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(t("涨跌相对前一交易日收盘价。数据日由服务商提供，读取时间只是本机获取时间；缓存有效不代表价格实时。", "Changes compare with the previous close. The provider supplies the trading date; fetched time records this Mac’s retrieval. A fresh cache does not imply a realtime price."))
            Text(t("自选及缓存留在本机。这里不提供交易入口或投资建议。", "Watchlist and cache stay on this Mac. This view does not provide trading or investment advice."))
            if let url = URL(string: "https://www.alphavantage.co/documentation/#latestprice") {
                Link(t("Alpha Vantage 数据说明 ↗", "Alpha Vantage data documentation ↗"), destination: url)
                    .tint(WorkspacePalette.secondaryText)
            }
        }.font(.system(size: 10.5)).foregroundStyle(WorkspacePalette.secondaryText)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func addSymbol() { if store.add(symbolInput) { symbolInput = "" } }
    private func saveKey(verify: Bool) {
        if store.saveKey(keyInput) {
            keyInput = ""
            if verify { store.startRefresh(verifyConnection: true) }
        }
    }
}
