//
// Copyright © 2024 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation

enum Keychain: String {
    case token = "token"
    case email = "email"
    
    static func delete(_ key: Keychain) {
        let keychainQueryDictionary: [NSString:Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: Bundle.main.bundleIdentifier! as NSString,
            kSecAttrAccount: key.rawValue as NSString
        ]
        let _ = SecItemDelete(keychainQueryDictionary as CFDictionary)
    }
    
    static func upsert(_ key: Keychain, string: String) {
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
                preconditionFailure("Failed to update \(key) with status \(status)")
            }
        } else if status != errSecSuccess {
            preconditionFailure("Failed to add \(key) with status \(status)")
        }
    }
    
    static func string(_ key: Keychain) -> String? {
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
    
}
