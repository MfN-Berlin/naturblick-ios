//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation

struct SigninResponse : Decodable {
    let access_token: String
}

@MainActor
class AccountViewModel: ObservableObject {
    
    @Published private(set) var neverSignedIn = true
    @Published private(set) var email: String? = nil
    @Published private(set) var hasToken = false
    @Published private(set) var fullySignedOut = true
    
    @Published private(set) var activated = false
    
    private let client = BackendClient()
    
    init() {
        email = Settings.getEmail()
        hasToken = Settings.getToken() != nil
        neverSignedIn = Settings.didNeverSignIn()
        $hasToken.combineLatest($email, { ht, e in !ht && e == nil }).assign(to: &$fullySignedOut)
        
        $email.map({ (e: String?) -> Bool in
            return e != nil
        }).assign(to: &$activated)   //TODO johannes
    }
    
    func signOutAfterRegister() {
        neverSignedIn = true
        email = nil
        hasToken = false
        Settings.clearEmail()
    }
    
    func signUp(email: String, password: String) async throws {
        self.email = email
        let _ =  try await client.signUp(deviceId: Configuration.deviceIdentifier, email: email, password: password)
    }
    
    func signIn(email: String, password: String) async throws {
        let signInResponse = try await client.signIn(email: email, password: password)
        Settings.setToken(token: signInResponse.access_token, email: email)
        self.email = email
        self.hasToken = true
        self.neverSignedIn = false
    }
    
    func deleteAccount(email: String, password: String) async throws {
        try await client.deleteAccount(email: email, password: password)
        Settings.clearEmail()
    }
    
    func resetPassword(email: String) async throws {
        try await client.resetPassword(email: email)
    }
    
}
