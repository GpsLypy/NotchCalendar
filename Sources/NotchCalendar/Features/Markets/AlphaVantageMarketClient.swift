import Foundation

struct AlphaVantageMarketClient: MarketQuoteClient, Sendable {
    static let maximumResponseBytes = 64 * 1_024
    private let transport: any RadarHTTPTransport
    private let deadline: Duration

    init(transport: any RadarHTTPTransport = MarketHTTPTransport(), deadline: Duration = .seconds(12)) {
        self.transport = transport
        self.deadline = deadline
    }

    func quote(symbol: String, apiKey: String, at date: Date) async throws -> MarketQuote {
        guard MarketSymbol.normalize(symbol) == symbol else { throw MarketError.invalidSymbol }
        guard Self.validKey(apiKey) else { throw MarketError.invalidKey }
        return try await withThrowingTaskGroup(of: MarketQuote.self) { group in
            group.addTask { try await requestQuote(symbol: symbol, apiKey: apiKey, at: date) }
            group.addTask {
                try await Task.sleep(for: deadline)
                throw MarketError.timedOut
            }
            defer { group.cancelAll() }
            guard let result = try await group.next() else { throw MarketError.network }
            return result
        }
    }

    static func validKey(_ key: String) -> Bool {
        (8...128).contains(key.utf8.count)
            && key.utf8.allSatisfy { (48...57).contains($0) || (65...90).contains($0) || (97...122).contains($0) }
    }

    private func requestQuote(symbol: String, apiKey: String, at date: Date) async throws -> MarketQuote {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.alphavantage.co"
        components.path = "/query"
        components.queryItems = [
            URLQueryItem(name: "function", value: "GLOBAL_QUOTE"),
            URLQueryItem(name: "symbol", value: symbol),
            URLQueryItem(name: "apikey", value: apiKey)
        ]
        guard let url = components.url else { throw MarketError.network }
        var request = URLRequest(url: url)
        request.timeoutInterval = 10
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let response: RadarHTTPResponse
        do {
            response = try await transport.data(for: request, maximumBytes: Self.maximumResponseBytes)
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as MarketError {
            throw error
        } catch {
            try Task.checkCancellation()
            if (error as? URLError)?.code == .timedOut { throw MarketError.timedOut }
            throw MarketError.network
        }
        try Task.checkCancellation()
        if response.statusCode == 429 { throw MarketError.rateLimited }
        if response.statusCode == 401 || response.statusCode == 403 { throw MarketError.invalidKey }
        guard (200..<300).contains(response.statusCode) else { throw MarketError.providerUnavailable }
        guard response.data.count <= Self.maximumResponseBytes else { throw MarketError.responseTooLarge }
        return try Self.decode(response.data, symbol: symbol, at: date)
    }

    static func decode(_ data: Data, symbol: String, at date: Date) throws -> MarketQuote {
        guard let envelope = try? JSONDecoder().decode(QuoteEnvelope.self, from: data) else {
            throw MarketError.malformedData
        }
        // Provider text is classified, never surfaced verbatim: it can echo an API key.
        if let note = envelope.note ?? envelope.information {
            let normalized = note.lowercased()
            if normalized.contains("invalid") || normalized.contains("premium") {
                throw MarketError.invalidKey
            }
            throw MarketError.rateLimited
        }
        if envelope.error != nil { throw MarketError.noQuote }
        guard let fields = envelope.quote, !fields.isEmpty else { throw MarketError.noQuote }
        guard fields["01. symbol"] == symbol,
              let price = fields["05. price"].flatMap(Double.init),
              let previous = fields["08. previous close"].flatMap(Double.init),
              let change = fields["09. change"].flatMap(Double.init),
              let percentText = fields["10. change percent"], percentText.hasSuffix("%"),
              let percent = Double(percentText.dropLast()),
              let day = fields["07. latest trading day"] else { throw MarketError.malformedData }
        let high = try optionalNumber(fields["03. high"])
        let low = try optionalNumber(fields["04. low"])
        let volume: Int64?
        if let text = fields["06. volume"] {
            guard let parsed = Int64(text), parsed >= 0 else { throw MarketError.malformedData }
            volume = parsed
        } else { volume = nil }
        let quote = MarketQuote(symbol: symbol, price: price, previousClose: previous,
            change: change, changePercent: percent, tradingDay: day,
            high: high, low: low, volume: volume, fetchedAt: date)
        guard quote.isValid(at: date) else { throw MarketError.malformedData }
        return quote
    }

    private static func optionalNumber(_ text: String?) throws -> Double? {
        guard let text else { return nil }
        guard let value = Double(text), value.isFinite else { throw MarketError.malformedData }
        return value
    }
}

private struct QuoteEnvelope: Decodable {
    let quote: [String: String]?
    let note: String?
    let information: String?
    let error: String?
    enum CodingKeys: String, CodingKey {
        case quote = "Global Quote", note = "Note", information = "Information", error = "Error Message"
    }
}

/// An ephemeral connection with no cookies, no URL cache and no credential-bearing redirects.
private struct MarketHTTPTransport: RadarHTTPTransport, Sendable {
    func data(for request: URLRequest, maximumBytes: Int) async throws -> RadarHTTPResponse {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 10
        configuration.timeoutIntervalForResource = 12
        configuration.urlCache = nil
        configuration.httpCookieStorage = nil
        configuration.waitsForConnectivity = false
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        let session = URLSession(configuration: configuration, delegate: MarketNoRedirect(), delegateQueue: nil)
        defer { session.invalidateAndCancel() }
        let (bytes, response) = try await session.bytes(for: request)
        guard let http = response as? HTTPURLResponse else { throw MarketError.network }
        guard response.expectedContentLength <= Int64(maximumBytes) else { throw MarketError.responseTooLarge }
        var data = Data()
        for try await byte in bytes {
            try Task.checkCancellation()
            guard data.count < maximumBytes else { throw MarketError.responseTooLarge }
            data.append(byte)
        }
        return RadarHTTPResponse(data: data, statusCode: http.statusCode)
    }
}

private final class MarketNoRedirect: NSObject, URLSessionTaskDelegate, Sendable {
    func urlSession(_ session: URLSession, task: URLSessionTask,
                    willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest,
                    completionHandler: @escaping @Sendable (URLRequest?) -> Void) {
        completionHandler(nil)
    }
}
