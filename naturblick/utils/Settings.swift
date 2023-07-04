//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation

struct Settings {
    
    private static let userDefault = UserDefaults.standard
    
    private static let emailKey = "email"
    private static let neverSignedInKey = "neverSignedIn"
    private static let tokenKey = "token"
    
    static let EMAIL = "johannes.ebbighausen@gmail.com"
    static let PASSWORD = "asdfAsdf1"
    
    
    static func setEmailAndRequireSignIn(email: String) {
        setEmail(email: email)
        userDefault.set(true, forKey: neverSignedInKey)
    }
    
    
    static func getEmail() -> String? {
        userDefault.string(forKey: emailKey)
    }
    
    static private func setEmail(email: String) {
        userDefault.set(email, forKey: emailKey)
    }
    
    static func didNeverSignIn() -> Bool {
        // defaults to false, if key does not exist
        userDefault.bool(forKey: neverSignedInKey)
    }
    
    static func getToken() -> String? {
        userDefault.string(forKey: tokenKey)
    }
    
    static func setToken(token: String, email: String) {
        setEmail(email: email)
        userDefault.set(token, forKey: tokenKey)
        userDefault.removeObject(forKey: neverSignedInKey)
    }
    
    static func setSignedOut() {
        userDefault.removeObject(forKey: tokenKey)
    }
    
    static func clearEmail() {
        userDefault.removeObject(forKey: neverSignedInKey)
        userDefault.removeObject(forKey: tokenKey)
        userDefault.removeObject(forKey: emailKey)
    }

}
