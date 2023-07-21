//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)
import SwiftUI

public protocol AccSecureStorageKey {
    var key: String { get }
}

public enum NbAppSecureStorageKey: AccSecureStorageKey {
    
    case BearerToken
    case Email

    public var key: String {
        switch self {
        case .BearerToken:
            return "bearer_token"
        case .Email:
            return "email"
        }
    }
}

@propertyWrapper
public struct AppSecureStorage: DynamicProperty {
    
    private let key: String
    private let accessibility: KeychainItemAccessibility

    public var wrappedValue: String? {
        get {
            KeychainWrapper.standard.string(forKey: key, withAccessibility: self.accessibility)
        }
        
        nonmutating set {
            if let newValue, !newValue.isEmpty {
                KeychainWrapper.standard.set(newValue, forKey: key, withAccessibility: self.accessibility)
            }
            else {
                KeychainWrapper.standard.removeObject(forKey: key, withAccessibility: self.accessibility)
            }
        }
    }

    public init(_ key: AccSecureStorageKey, accessibility: KeychainItemAccessibility = .whenUnlocked ) {
        self.key = key.key
        self.accessibility = accessibility
    }
}
