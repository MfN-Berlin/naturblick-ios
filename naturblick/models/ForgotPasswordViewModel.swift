//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation

@MainActor
class ForgotPasswordViewModel : EmailWithPrompt {
    
    private let client = BackendClient()
    var error: HttpError? = nil
    @Published var showSendInfo: Bool = false
    @Published var isPresented: Bool = false
    
    func resetPassword() {
        Task {
            do {
                try await client.resetPassword(email: email)
                showSendInfo = true
            } catch is HttpError {
                self.error = error
                self.isPresented = true
            } catch {
                preconditionFailure(error.localizedDescription)
            }
        }
    }
    
}
