//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation

@MainActor
class AccountViewModel: ObservableObject {
    @Published private(set) var email: String? = Settings.getEmail()
    @Published private(set) var hasToken = Settings.getToken() != nil
    @Published private(set) var neverSignedIn = Settings.neverSignedIn()
    
    private let client = BackendClient()
   
    func signOut() {
        email = nil
        hasToken = false
        neverSignedIn = true
        Settings.clearEmail()
    }
    
    func reInit() {
        email = Settings.getEmail()
        hasToken = Settings.getToken() != nil
    }
}
