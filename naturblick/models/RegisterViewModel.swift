//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation


class EmailWithPrompt: HttpErrorViewModel {
    @Published var email: String = "johannes.ebbighausen@gmail.com" //TODO johannes entfernen
    
    var emailHint: String? {
        if (email.count > 0 && !email.isEmail()) {
            return "Not a valid e-mail address"
        }
        return nil
    }
}

class EmailAndPasswordWithPrompt: EmailWithPrompt {
    @Published var password: String = "asdfAsdf1" //TODO johannes entfernen
    
    func isPasswordValid() -> Bool {
        passwordHint == nil && !password.isEmpty
    }
    
    var passwordHint: String? {
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

class LoginViewModel: EmailAndPasswordWithPrompt {
    
    @Published var showCredentialsWrong = false
    @Published var showLoginSuccess = false
    var accountViewModel: AccountViewModel
    
    init(showCredentialsWrong: Bool = false, showLoginSuccess: Bool = false, accountViewModel: AccountViewModel) {
        self.showCredentialsWrong = showCredentialsWrong
        self.showLoginSuccess = showLoginSuccess
        self.accountViewModel = accountViewModel
    }
    
    func signIn() -> Void {
        Task {
            do {
                let signInResponse = try await BackendClient().signIn(email: email, password: password)
                accountViewModel.email = email
                accountViewModel.bearerToken = signInResponse.access_token
                accountViewModel.neverSignedIn = false
                accountViewModel.activated = true
                showLoginSuccess = true
            } catch HttpError.clientError(let statusCode) where statusCode == 400 {
                showCredentialsWrong = true
            } catch {
                let _ = handle(error)
            }
        }
    }
}

class RegisterViewModel: EmailAndPasswordWithPrompt {
    
    var accountViewModel: AccountViewModel
    @Published var privacyChecked: Bool = false
    @Published var showRegisterSuccess: Bool = false
    @Published var showAlreadyExists = false
    
    var isRegisterEnabled: Bool {
        isPasswordValid() && privacyChecked
    }
    
    init(accountViewModel: AccountViewModel, privacyChecked: Bool = false, showRegisterSuccess: Bool = false, showAlreadyExists: Bool = false) {
        self.accountViewModel = accountViewModel
        self.privacyChecked = privacyChecked
        self.showRegisterSuccess = showRegisterSuccess
        self.showAlreadyExists = showAlreadyExists
    }
    
    func signUp() {
        let client = BackendClient()
        Task {
            do {
                let _ = try await client.signUp(deviceId: Settings.deviceId(), email: email, password: password)
                accountViewModel.email = email
                showRegisterSuccess = true
            } catch HttpError.clientError(let statusCode) where statusCode == 409 {
                showAlreadyExists = true
            } catch {
                let _ = handle(error)
            }
        }
    }
}

class ForgotPasswordViewModel: EmailAndPasswordWithPrompt {
    var accountViewModel: AccountViewModel
    
    @Published var showSendInfo: Bool = false

    init(accountViewModel: AccountViewModel, showSendInfo: Bool = false) {
        self.accountViewModel = accountViewModel
        self.showSendInfo = showSendInfo
    }
    
    func forgotPassword() {
        let client = BackendClient()
        Task {
            do {
                try await client.forgotPassword(email: email)
                showSendInfo = true
            } catch {
                let _ = handle(error)
            }
        }
    }
}


class DeleteAccountViewModel : EmailAndPasswordWithPrompt {
    var accountViewModel: AccountViewModel
    @Published var showDeleteSuccess = false
    
    @Published var showCredentialsError = false
    
    init(accountViewModel: AccountViewModel, showDeleteSuccess: Bool = false, showCredentialsError: Bool = false) {
        self.accountViewModel = accountViewModel
        self.showDeleteSuccess = showDeleteSuccess
        self.showCredentialsError = showCredentialsError
    }
    
    func deleteAccount() {
        let client = BackendClient()
        Task {
            do {
                try await client.deleteAccount(email: email, password: password)
                accountViewModel.signOut()
                showDeleteSuccess = true
            }  catch HttpError.clientError(let statusCode) where statusCode == 400 {
                showCredentialsError = true
            } catch {
                let _ = handle(error)
            }
        }
    }
}

class ResetPasswordViewModel : EmailAndPasswordWithPrompt {
    var token: String
    
    @Published var showResetSuccess: Bool
    
    @AppSecureStorage(NbAppSecureStorageKey.BearerToken) var bearerToken: String?
    
    init(token: String, showResetSuccess: Bool = false) {
        self.showResetSuccess = showResetSuccess
        self.token = token
    }
    
    func resetPassword() {
        let client = BackendClient()
        Task {
            do {
                try await client.resetPassword(token: token, password: password)
                bearerToken = nil
                showResetSuccess = true
            }
            catch is HttpError {
                self.error = error
                isPresented = true
            } catch {
                let _ = handle(error)
            }
        }
    }
}

