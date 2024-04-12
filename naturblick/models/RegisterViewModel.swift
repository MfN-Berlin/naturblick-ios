//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import SwiftUI

class EmailWithPrompt: ObservableObject {
    @Published var email: String = ""
    
    var emailPrompt: LocalizedStringKey? {
        if (email.count > 0 && !email.isEmail()) {
            return LocalizedStringKey("email_is_not_valid")
        }
        return nil
    }
}

class EmailAndPasswordWithPrompt: EmailWithPrompt {
    @Published var password: String = ""
    
    func isPasswordValid() -> Bool {
        passwordPrompt == nil && !password.isEmpty
    }
    
    var passwordPrompt: LocalizedStringKey? {
        if (password.count == 0) {
            return nil
        }
        
        let passwordIsTooShort = password.count < 9
        if (passwordIsTooShort) {
            return LocalizedStringKey("password_too_short")
        }
        
        let passwordContainsNoLowerCaseLetters = !password.containsLowercase()
        if (passwordContainsNoLowerCaseLetters) {
            return LocalizedStringKey("password_no_lower_case")
        }
        
        let passwordContainsNoUpperCaseLetters = !password.containsUppercase()
        if (passwordContainsNoUpperCaseLetters) {
            return LocalizedStringKey("password_no_upper_case")
        }
        
        let passwordContainsNoDigits = !password.containsDigits()
        if (passwordContainsNoDigits) {
            return LocalizedStringKey("password_no_digits")
        }
        
        return nil
    }
}

class RegisterViewModel: EmailAndPasswordWithPrompt {
    
    @Published var privacyChecked: Bool = false
    
    var isRegisterEnabled: Bool {
        isPasswordValid() && privacyChecked
    }
}
