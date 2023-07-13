//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation

struct Settings {
    private static let userDefault = UserDefaults.standard
    
    private static let emailKey = "email"
    private static let tokenKey = "token"
    private static let activatedKey = "activated"
    private static let neverSignedInKey = "neverSignedIn"
    
    static func setEmail(email: String?) {
        userDefault.set(email, forKey: emailKey)
    }
    
    static func getEmail() -> String? {
        userDefault.string(forKey: emailKey)
    }
    
    static func getToken() -> String? {
        userDefault.string(forKey: tokenKey)
    }
    
    static func setToken(token: String) {
        userDefault.set(token, forKey: tokenKey)
    }
    
    static func setSignedOut() {
        userDefault.removeObject(forKey: tokenKey)
    }
    
    static func setAccountActivation(value: Bool) {
        userDefault.set(value, forKey: activatedKey)
    }
    
    static func isAccountActive() -> Bool {
        return userDefault.bool(forKey: activatedKey)
    }

    
    static func clearEmail() {
        userDefault.removeObject(forKey: tokenKey)
        userDefault.removeObject(forKey: emailKey)
        userDefault.removeObject(forKey: activatedKey)
        userDefault.removeObject(forKey: neverSignedInKey)
    }
    
    static func neverSignedIn() -> Bool {
        return (userDefault.value(forKey: neverSignedInKey) as? Bool) ?? true
    }
    
    static func setSignedIn() {
        userDefault.set(false, forKey: neverSignedInKey)
    }
}
