//
// Copyright © 2024 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import SwiftUI

class AccountViewModel : ObservableObject {
    @AppStorage("naturblick_neverSignedIn") private var storageNeverSignedIn: Bool = true
    @AppStorage("naturblick_activated") private var storageActivated: Bool = false
    
    let backend: Backend
    
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
        try await backend.signUp(deviceId: Settings.deviceId(), email: email, password: password)
        Keychain.shared.setEmail(email: email)
    }
    
    @MainActor
    func signIn(email: String, password: String) async throws {
        let signInResponse = try await backend.signIn(email: email, password: password)
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
        try await backend.deleteAccount(email: email, password: password)
        signOut()
    }
    
    @MainActor
    func forgotPassword(email: String) async throws {
        try await backend.forgotPassword(email: email)
    }
    
    init(backend: Backend) {
        self.backend = backend
        neverSignedIn = storageNeverSignedIn
        activated = storageActivated
    }
}
