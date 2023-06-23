//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation

class AccountViewModel: ObservableObject {
    
    @Published private(set) var neverSignedIn = true
    @Published private(set) var email: String? = nil
    @Published private(set) var hasToken = false
    @Published private(set) var fullySignedOut = true
    
    @Published private(set) var activated = true //TODO johannes 
    
    init() {
        email = Settings.getEmail()
        hasToken = Settings.getToken() != nil
        neverSignedIn = Settings.didNeverSignIn()
        $hasToken.combineLatest($email, { ht, e in !ht && e == nil }).assign(to: &$fullySignedOut)
    }
    
    func signOutAfterRegister() {
        neverSignedIn = true
        email = nil
        hasToken = false
        Settings.clearEmail()
    }
    
    func register(email: String, password: String) {
        self.email = email
    }
    
    func login(email: String, password: String) {
        //TODO johannes login
    }
    
    func deleteAccount(email: String, password: String) {
        //TODO johannes deleteAccount
    }
    
}
