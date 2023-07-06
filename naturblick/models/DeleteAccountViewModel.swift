//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation

@MainActor
class DeleteAccountViewModel : EmailAndPasswordWithPrompt {
    @Published var showDeleteSuccess = false
    
    @Published var showCredentialsError = false
    
    @Published var isPresented: Bool = false
    var error: HttpError? = nil
    
    private let client = BackendClient()
        
    func deleteAccount() {
        Task {
            do {
                try await client.deleteAccount(email: email, password: password)
                Settings.setSignedOut()
                Settings.setEmail(email: nil)
                showDeleteSuccess = true
            }  catch HttpError.clientError(let statusCode) where statusCode == 400 {
                showCredentialsError = true
            } catch is HttpError {
                self.error = error
                self.isPresented = true
            } catch {
                preconditionFailure(error.localizedDescription)
            }
        }
    }

}
