//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation

class SharedSettings : ObservableObject {
 
    @Published var email: String?
    @Published var hasToken: Bool
    @Published var neverSignedIn: Bool
    @Published var activated: Bool
        
    init(email: String?, hasToken: Bool, neverSignedIn: Bool, activated: Bool) {
        self.email = email
        self.hasToken = hasToken
        self.neverSignedIn = neverSignedIn
        self.activated = activated
    }
    
    func signOut() {
        email = nil
        hasToken = false
        neverSignedIn = true
        Settings.clearEmail()
    }
    
    func setEmail(email: String?) {
        self.email = email
        Settings.setEmail(email: email)
    }
    
    func setToken(token: String) {
        self.hasToken = true
        Settings.setToken(token: token)
    }
    
    func setSignedIn() {
        self.neverSignedIn = false
        Settings.setSignedIn()
    }
    
    func setSignedOut() {
        self.hasToken = false
        Settings.setSignedOut()
    }
    
    func setActivated(value: Bool) {
        self.activated = value
        Settings.setAccountActivation(value: value)
    }
}

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
