//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

struct SigninResponse : Decodable {
    let access_token: String
}

struct LoginView: NavigatableView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    var viewName: String? = "Login"
    
    @ObservedObject var accountViewModel: AccountViewModel
    
    @Environment(\.dismiss) var dismiss
    
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
        VStack {
            if (accountViewModel.activated) {
                Text("Your Naturblick account is activated. Log in with your email address and password on all devices you want to connect to the account.")
                    .tint(Color.onSecondaryButtonPrimary)
                    .font(.nbBody1)
                    .padding()
            } else {
                Text("Connect all observations on this phone to your account.")
                    .tint(Color.onSecondaryButtonPrimary)
                    .font(.nbBody1)
                    .padding()
            }
            
            NBEditText(label: "Email address", icon: Image(systemName: "mail"), text: $loginVM.email, prompt: loginVM.emailPrompt)
                .padding()
                .keyboardType(.emailAddress)
            NBEditText(label: "Password", icon: Image(systemName: "eye"), text: $loginVM.password, isSecure: true, prompt: loginVM.passwordPrompt).padding()
            if showCredentialsWrong {
                Text("Credentials not recognized. Please validate your e-mail and password.")
                    .foregroundColor(.onSecondarywarning)
                    .font(.nbBody1)
                    .padding()
            }
            
            Button("Login") {
                signIn()
            }.foregroundColor(.black)
                .buttonStyle(.bordered)
            
            Button {
                navigationController?.pushViewController(ForgotPasswordView(accountViewModel: accountViewModel).setUpViewController(), animated: true)
            } label: {
                Text("Forgot password")
            }.buttonStyle(.bordered).foregroundColor(.black)
            
            if (!accountViewModel.activated) {
                Text("**Note**\n\nWhen you set a new password, all phones linked to the account will be automatically logged out for security reasons. All your observations will remain linked to your account.")
                    .tint(Color.onSecondaryButtonPrimary)
                    .font(.nbBody1)
                    .padding()
            }
            
            Spacer()
        }
        .foregroundColor(.onSecondaryHighEmphasis)
        .actionSheet(isPresented: $showLoginSuccess) {
            ActionSheet(
                title: Text("Success!"),
                message: Text("You are signed in as: \(loginVM.email)"),
                buttons: [
                    .default(Text("Ok"), action: {
                        dismiss()
                    })
                ]
            )
        }.alertHttpError(isPresented: $isPresented, error: error)
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
