//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation

// email unused
@MainActor
class ResetPasswordViewModel : EmailAndPasswordWithPrompt {
    
    private let client = BackendClient()
    
    @Published var showResetSuccess: Bool = false
    @Published var isPresented: Bool = false
    var error: HttpError? = nil
    
    func resetPassword(token: String) {
        Task {
            do {
                try await client.resetPassword(token: token, password: password)
                showResetSuccess = true
            }
            catch is HttpError {
                self.error = error
                isPresented = true
            } catch {
                preconditionFailure(error.localizedDescription)
            }
        }
    }
}
