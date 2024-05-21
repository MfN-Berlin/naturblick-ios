//
// Copyright © 2024 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import SwiftUI

class AccountViewModel : ObservableObject {
    @AppStorage("naturblick_neverSignedIn") private var storageNeverSignedIn: Bool = true
    @AppStorage("naturblick_activated") private var storageActivated: Bool = false
    
    private let client = BackendClient()
    
    var neverSignedIn: Bool = true {
        willSet {
            storageNeverSignedIn = newValue
            objectWillChange.send()
        }
    }
  
    var activated: Bool = false {
        willSet {
            storageActivated = newValue
            objectWillChange.send()
        }
    }
   
    @MainActor
    func signUp(email: String, password: String) async throws {
        try await client.signUp(deviceId: Settings.deviceId(), email: email, password: password)
        Keychain.shared.setEmail(email: email)
    }
    
    @MainActor
    func signIn(email: String, password: String) async throws {
        let signInResponse = try await client.signIn(email: email, password: password)
        Keychain.shared.setEmail(email: email)
        Keychain.shared.setToken(token: signInResponse.access_token)
        self.neverSignedIn = false
        self.activated = true
    }
    
    @MainActor
    func signOut() {
        Keychain.shared.deleteEmail()
        Keychain.shared.deleteToken()
        self.neverSignedIn = true
        self.activated = false
    }
    
    @MainActor
    func delete(email: String, password: String) async throws {
        try await client.deleteAccount(email: email, password: password)
        signOut()
    }
    
    @MainActor
    func forgotPassword(email: String) async throws {
        try await client.forgotPassword(email: email)
    }
    
    init() {
        neverSignedIn = storageNeverSignedIn
        activated = storageActivated
    }
}
