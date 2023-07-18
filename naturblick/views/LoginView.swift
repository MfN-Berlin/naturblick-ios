//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

struct SigninResponse : Decodable {
    let access_token: String
}

struct LoginView: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var sharedSettings: SharedSettings
    
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
                sharedSettings.setEmail(email: loginVM.email)
                sharedSettings.setToken(token: signInResponse.access_token)
                sharedSettings.setSignedIn()
                sharedSettings.setActivated(value: true)
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
        BaseView {
            VStack {
                if (sharedSettings.activated) {
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
                
                NavigationLink(destination: ForgotPasswordView()) {
                    Text("Forgot Password")
                }.buttonStyle(.bordered).foregroundColor(.black)
                
                if (!sharedSettings.activated) {
                    Text("**Note**\n\nWhen you set a new password, all phones linked to the account will be automatically logged out for security reasons. All your observations will remain linked to your account.")
                        .tint(Color.onSecondaryButtonPrimary)
                        .font(.nbBody1)
                        .padding()
                }
                
                Spacer()
            }
        }.actionSheet(isPresented: $showLoginSuccess) {
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
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
