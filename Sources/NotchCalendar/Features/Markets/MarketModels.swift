import Foundation

enum MarketSymbol {
    static let maximumWatchlistCount = 8

    /// This first release accepts ordinary US ticker symbols only, not exchange suffixes.
    static func normalize(_ raw: String) -> String? {
        let value = raw.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard (1...5).contains(value.utf8.count),
              value.utf8.allSatisfy({ (65...90).contains($0) }) else { return nil }
        return value
    }

    static func cleanWatchlist(_ raw: [String]) -> [String] {
        var seen: Set<String> = []
        return Array(raw.compactMap(normalize).filter { seen.insert($0).inserted }
            .prefix(maximumWatchlistCount))
    }
}

struct MarketQuote: Codable, Equatable, Sendable {
    static let cacheLifetime: TimeInterval = 15 * 60
    let symbol: String
    let price: Double
    let previousClose: Double
    let change: Double
    let changePercent: Double
    let tradingDay: String
    let high: Double?
    let low: Double?
    let volume: Int64?
    let fetchedAt: Date

    func isValid(at now: Date) -> Bool {
        guard MarketSymbol.normalize(symbol) == symbol,
              price.isFinite, price > 0,
              previousClose.isFinite, previousClose > 0,
              change.isFinite, changePercent.isFinite,
              fetchedAt.timeIntervalSince1970.isFinite,
              fetchedAt.timeIntervalSince1970 > 0,
              fetchedAt <= now.addingTimeInterval(60),
              let day = Self.date(from: tradingDay),
              day <= now.addingTimeInterval(24 * 60 * 60) else { return false }
        if let high, !high.isFinite || high <= 0 { return false }
        if let low, !low.isFinite || low <= 0 { return false }
        if let high, let low, high < low { return false }
        if let volume, volume < 0 { return false }
        return true
    }

    func isFresh(at now: Date) -> Bool {
        isValid(at: now) && now.timeIntervalSince(fetchedAt) >= 0
            && now.timeIntervalSince(fetchedAt) < Self.cacheLifetime
    }

    static func date(from raw: String) -> Date? {
        guard raw.utf8.count == 10 else { return nil }
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.isLenient = false
        guard let date = formatter.date(from: raw),
              formatter.string(from: date) == raw,
              date.timeIntervalSince1970 > 0 else { return nil }
        return date
    }
}

enum MarketError: Error, Equatable, Sendable {
    case invalidSymbol, malformedData, noQuote, invalidKey, rateLimited
    case providerUnavailable, responseTooLarge, network, timedOut, keychain
    case watchlistFull, duplicateSymbol, localQuota, allFresh, saved, verified

    func message(chinese: Bool) -> String {
        switch self {
        case .invalidSymbol: chinese ? "请输入 1–5 位美股字母代码，例如 AAPL。" : "Enter a US ticker of 1–5 letters, such as AAPL."
        case .malformedData: chinese ? "数据格式不完整，已保留上次行情。稍后重试。" : "The response was incomplete. Saved quotes are preserved; try again later."
        case .noQuote: chinese ? "没有找到行情，请检查股票代码及数据权限。" : "No quote was found. Check the symbol and your data access."
        case .invalidKey: chinese ? "密钥无效或没有数据权限，请更新个人密钥。" : "The key is invalid or lacks access. Update your personal key."
        case .rateLimited: chinese ? "数据源已限流，本轮停止请求。请检查套餐配额，稍后再试。" : "The provider limited requests. Refresh stopped; check your plan and try later."
        case .providerUnavailable: chinese ? "数据源暂时不可用，已保留上次行情。" : "The provider is unavailable. Saved quotes are preserved."
        case .responseTooLarge: chinese ? "数据响应超出安全大小，已停止读取。" : "The response exceeded the safe size limit."
        case .network: chinese ? "连接失败，请检查网络后重试。" : "Connection failed. Check your network and retry."
        case .timedOut: chinese ? "连接超时，请稍后重试。" : "The request timed out. Try again later."
        case .keychain: chinese ? "无法访问钥匙串，请检查系统访问权限。" : "Keychain access failed. Check system access permissions."
        case .watchlistFull: chinese ? "最多关注 8 只股票，移除一只后再添加。" : "Watch up to 8 symbols. Remove one before adding another."
        case .duplicateSymbol: chinese ? "这只股票已在自选中。" : "This symbol is already on your watchlist."
        case .localQuota: chinese ? "已达到本机 24 小时 25 次请求上限，等待额度恢复后重试。" : "This Mac reached its 25-request rolling 24-hour limit. Wait for capacity to return."
        case .allFresh: chinese ? "自选行情均在 15 分钟缓存期内，本次未消耗额度。" : "Every quote is within the 15-minute cache window. No requests were used."
        case .saved: chinese ? "密钥已存入钥匙串，点击刷新即可读取行情。" : "Key saved to Keychain. Refresh to load quotes."
        case .verified: chinese ? "连接已验证，行情已保存。" : "Connection verified and quote saved."
        }
    }
}

protocol MarketQuoteClient: Sendable {
    func quote(symbol: String, apiKey: String, at date: Date) async throws -> MarketQuote
}
