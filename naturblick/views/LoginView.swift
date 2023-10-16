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
        
    @StateObject private var loginVM = EmailAndPasswordWithPrompt()
    
    @State  var isPresented: Bool = false
    @State  var error: HttpError? = nil
    
    @State var showCredentialsWrong = false
    @State var showLoginSuccess = false
        
    func signIn() -> Void {
        let client = BackendClient()
        Task {
            do {
                let signInResponse = try await client.signIn(email: loginVM.email, password: loginVM.password)
                accountViewModel.email = loginVM.email
                accountViewModel.bearerToken = signInResponse.access_token
                accountViewModel.neverSignedIn = false
                accountViewModel.activated = true
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

    var body: some View {
        VStack(alignment: .leading, spacing: .defaultPadding) {
            if (accountViewModel.activated) {
                Text("account_activated")
                    .body1()
            } else {
                Text("login_standard")
                    .body1()
            }
            
            OnSecondaryFieldView(icon: "create_24px") {
                TextField(String(localized: "email"), text: $loginVM.email)
                    .keyboardType(.emailAddress)
            }
            if let prompt = loginVM.emailPrompt {
                Text(prompt)
                    .caption()
            }
            OnSecondaryFieldView(image: Image("visibility")) {
                SecureField(String(localized: "password"), text: $loginVM.password)
            }
            if let prompt = loginVM.passwordPrompt {
                Text(prompt)
                    .caption()
            } else if loginVM.passwordPrompt == nil {
                Text("password_format")
                    .caption()
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
            
            Text("delete_account_note_password")
                .body2()
            Spacer()
        }
        .padding(.defaultPadding)
        .actionSheet(isPresented: $showLoginSuccess) {
            ActionSheet(
                title: Text("successful_signin"),
                message: Text("signed_in_as \(loginVM.email)"),
                buttons: [
                    .default(Text("Ok"), action: {
                        navigationController?.popViewController(animated: true)
                    })
                ]
            )
        }
        .alertHttpError(isPresented: $isPresented, error: error)
        .onAppear {
            if let email = accountViewModel.email {
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
