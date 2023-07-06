//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation


class EmailWithPrompt: ObservableObject {
    @Published var email: String = ""
    
    var emailPrompt: String? {
        if (email.count > 0 && !email.isEmail()) {
            return "Not a valid e-mail address"
        }
        return nil
    }
}

class EmailAndPasswordWithPrompt: EmailWithPrompt {
    @Published var password: String = ""
    
    func isPasswordValid() -> Bool {
        passwordPrompt == nil && !password.isEmpty
    }
    
    var passwordPrompt: String? {
        if (password.count == 0) {
            return nil
        }
        
        let passwordIsTooShort = password.count < 9
        if (passwordIsTooShort) {
            return "Must be at least 9 characters"
        }
        
        let passwordContainsNoLowerCaseLetters = !password.containsLowercase()
        if (passwordContainsNoLowerCaseLetters) {
            return "Must contain lower case letters"
        }
        
        let passwordContainsNoUpperCaseLetters = !password.containsUppercase()
        if (passwordContainsNoUpperCaseLetters) {
            return "Must contain upper case letters"
        }
        
        let passwordContainsNoDigits = !password.containsDigits()
        if (passwordContainsNoDigits) {
            return "Must contain digits"
        }
        
        return nil
    }
}

@MainActor
class RegisterViewModel: EmailAndPasswordWithPrompt {
    @Published var privacyChecked: Bool = false
    
    @Published var showRegisterSuccess: Bool = false
    @Published var showAlreadyExists = false
    
    @Published var isPresented: Bool = false
    var error: HttpError? = nil
    
    private let client = BackendClient()
    
    func signUp() {
        Task {
            do {
                let _ = try await client.signUp(deviceId: Configuration.deviceIdentifier, email: email, password: password)
                Settings.setEmail(email: email)
                showRegisterSuccess = true
            } catch HttpError.clientError(let statusCode) where statusCode == 409 {
                showAlreadyExists = true
            } catch is HttpError {
                self.error = error
                isPresented = true
            } catch {
                preconditionFailure(error.localizedDescription)
            }
        }
    }
    
    var isRegisterEnabled: Bool {
        isPasswordValid() && privacyChecked
    }
}
