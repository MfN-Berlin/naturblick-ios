//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation

struct SigninResponse : Decodable {
    let access_token: String
}

@MainActor
class LoginViewModel : EmailAndPasswordWithPrompt {
    @Published  var isPresented: Bool = false
    var error: HttpError? = nil
    
    @Published var showCredentialsWrong = false
    @Published var showLoginSuccess = false
    @Published private(set) var activated = Settings.getEmail() != nil
    
    private let client = BackendClient()
    
    func signIn() -> Void {
        Task {
            do {
                let signInResponse = try await client.signIn(email: email, password: password)
                Settings.setEmail(email: email)
                Settings.setToken(token: signInResponse.access_token)
                activated = true
                showLoginSuccess = true
            } catch HttpError.clientError(let statusCode) where statusCode == 400 {
                showCredentialsWrong = true
            } catch is HttpError {
                self.error = error
                self.isPresented = true
            } catch {
                preconditionFailure(error.localizedDescription)
            }
        }
    }
}
