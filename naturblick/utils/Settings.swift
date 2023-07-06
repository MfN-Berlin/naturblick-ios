//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation

struct Settings {
    private static let userDefault = UserDefaults.standard
    
    private static let emailKey = "email"
    private static let tokenKey = "token"
    
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
    
    static func clearEmail() {
        userDefault.removeObject(forKey: tokenKey)
        userDefault.removeObject(forKey: emailKey)
    }
}
