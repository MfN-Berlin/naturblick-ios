//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

struct SigninResponse : Decodable {
    let access_token: String
}

struct LoginView: NavigatableView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    var viewName: String? = String(localized: "login")
    
    @ObservedObject var accountViewModel: AccountViewModel
    @ObservedObject var keychain = Keychain.shared
    @StateObject private var loginVM = EmailAndPasswordWithPrompt()
    
    @State  var isPresented: Bool = false
    @State  var error: HttpError? = nil
    
    @State var showCredentialsWrong = false
    @State var showLoginSuccess = false
        
    func signIn() -> Void {
        Task {
            do {
                try await accountViewModel.signIn(email: loginVM.email, password: loginVM.password)
                showLoginSuccess = true
            } catch HttpError.clientError(let statusCode) where statusCode == 400 {
                showCredentialsWrong = true
            } catch is HttpError {
                self.error = error
                self.isPresented = true
            } catch {
                Fail.with(error)
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: .defaultPadding) {
            if accountViewModel.activated {
                Text("account_activated")
                    .body1()
            } else {
                Text("login_standard")
                    .body1()
            }
               
            HStack {
                Image(decorative: "create_24px")
                    .observationProperty()
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: .zero) {
                    Text("email")
                        .caption(color: .onSecondarySignalLow)
                    TextField(String(localized: "email"), text: $loginVM.email)
                        .textContentType(.username)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                }
            }
            
            if let prompt = loginVM.emailPrompt {
                Text(prompt)
                    .caption(color: .onSecondaryMediumEmphasis)
            }
            
            HStack {
                Image(decorative: "visibility")
                    .observationProperty()
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: .zero) {
                    Text("password")
                        .caption(color: .onSecondarySignalLow)
                    SecureField(String(localized: "password"), text: $loginVM.password)
                        .textContentType(.password)
                        .textInputAutocapitalization(.never)
                }
            }
            
            if let prompt = loginVM.passwordPrompt {
                Text(prompt)
                    .caption(color: .onSecondaryMediumEmphasis)
            } else if loginVM.passwordPrompt == nil {
                Text("password_format")
                    .caption(color: .onSecondaryMediumEmphasis)
            }
            if showCredentialsWrong {
                Text("email_or_password_invalid")
                    .body1(color: .onSecondarywarning)
            }
            
            Button("sign_in") {
                signIn()
            }.buttonStyle(ConfirmFullWidthButton()).textCase(.uppercase)
            
            Button("forgot_password") {
                navigationController?.pushViewController(ForgotPasswordView(accountViewModel: accountViewModel).setUpViewController(), animated: true)
            }.buttonStyle(AuxiliaryOnSecondaryFullwidthButton()).textCase(.uppercase)
            Spacer()
        }
        .padding(.defaultPadding)
        .alert("successful_signin", isPresented: $showLoginSuccess) {
            Button("ok") {
                navigationController?.popViewController(animated: true)
            }
        } message: {
            Text("signed_in_as \(loginVM.email)")
        }
        .alertHttpError(isPresented: $isPresented, error: error)
        .onAppear {
            if let email = keychain.email {
                loginVM.email = email
            }
        }
        
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(accountViewModel: AccountViewModel())
    }
}
