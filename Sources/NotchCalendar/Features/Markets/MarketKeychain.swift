import Foundation
import Security

@MainActor
protocol MarketKeyStorage {
    func read() throws -> String?
    func save(_ key: String) throws
    func remove() throws
}

@MainActor
struct MarketKeychain: MarketKeyStorage {
    private var query: [String: Any] {
        [kSecClass as String: kSecClassGenericPassword,
         kSecAttrService as String: "NotchCalendar.Markets.AlphaVantage",
         kSecAttrAccount as String: "personal-api-key",
         kSecAttrSynchronizable as String: false]
    }

    func read() throws -> String? {
        var request = query
        request[kSecReturnData as String] = true
        request[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: CFTypeRef?
        let status = SecItemCopyMatching(request as CFDictionary, &result)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess, let data = result as? Data,
              let key = String(data: data, encoding: .utf8) else { throw MarketError.keychain }
        return key
    }

    func save(_ key: String) throws {
        guard AlphaVantageMarketClient.validKey(key) else { throw MarketError.invalidKey }
        let data = Data(key.utf8)
        let status = SecItemUpdate(query as CFDictionary,
            [kSecValueData as String: data] as CFDictionary)
        if status == errSecItemNotFound {
            var request = query
            request[kSecValueData as String] = data
            request[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            guard SecItemAdd(request as CFDictionary, nil) == errSecSuccess else { throw MarketError.keychain }
        } else if status != errSecSuccess { throw MarketError.keychain }
    }

    func remove() throws {
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else { throw MarketError.keychain }
    }
}
