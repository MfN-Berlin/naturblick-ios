//
// Copyright © 2024 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation

@MainActor
class Keychain: ObservableObject {
    @Published private(set) var token: String?
    @Published private(set) var email: String?

    enum Key: String {
        case token = "token"
        case email = "email"
    }
    
    func deleteEmail() {
        Keychain.delete(.email)
        email = nil
    }
    
    func deleteToken() {
        Keychain.delete(.token)
        token = nil
    }
    
    func setEmail(email: String) {
        Keychain.upsert(.email, string: email)
        self.email = email
    }
    
    func setToken(token: String) {
        Keychain.upsert(.token, string: token)
        self.token = token
    }
    
    func refresh() {
        token = Keychain.string(.token)
        email = Keychain.string(.email)
    }
    
    private static func delete(_ key: Key) {
        let keychainQueryDictionary: [NSString:Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: Bundle.main.bundleIdentifier! as NSString,
            kSecAttrAccount: key.rawValue as NSString
        ]
        let _ = SecItemDelete(keychainQueryDictionary as CFDictionary)
    }
    
    private static func upsert(_ key: Key, string: String) {
        let value = string.data(using: .utf8)
        let keychainQueryDictionary: [NSString:Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: Bundle.main.bundleIdentifier! as NSString,
            kSecAttrAccount: key.rawValue as NSString
        ]
        
        var insertDictionary = keychainQueryDictionary
        insertDictionary[kSecValueData] = value
        
        let status: OSStatus = SecItemAdd(insertDictionary as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            let updateDictionary = [kSecValueData:value]
            let status: OSStatus = SecItemUpdate(keychainQueryDictionary as CFDictionary, updateDictionary as CFDictionary)
            if status != errSecSuccess {
                Fail.with(message: "Failed to update \(key) with status \(status)")
            }
        } else if status != errSecSuccess {
            Fail.with(message: "Failed to add \(key) with status \(status)")
        }
    }
    
    private static func string(_ key: Key) -> String? {
        let keychainQueryDictionary: [NSString:Any] = [
            kSecClass:kSecClassGenericPassword,
            kSecAttrService: Bundle.main.bundleIdentifier!,
            kSecAttrAccount: key.rawValue as NSString,
            kSecMatchLimit: kSecMatchLimitOne,
            kSecReturnData: kCFBooleanTrue!
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(keychainQueryDictionary as CFDictionary, &result)
        
        guard status == noErr, let data = result as? Data else {
            return nil
        }
        
        return String(data: data, encoding: String.Encoding.utf8)
    }
    
    static let shared = Keychain()
}
