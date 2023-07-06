//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

struct LoginView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject private var loginVM = LoginViewModel()

    var body: some View {
        BaseView {
            VStack {
                if (loginVM.activated) {
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
                
                NBEditText(label: "Email address", icon: Image(systemName: "mail"), text: $loginVM.email, prompt: loginVM.emailPrompt).padding()
                NBEditText(label: "Password", icon: Image(systemName: "eye"), text: $loginVM.password, isSecure: true, prompt: loginVM.passwordPrompt).padding()
                if loginVM.showCredentialsWrong {
                    Text("Credentials not recognized. Please validate your e-mail and password.")
                        .foregroundColor(.onSecondarywarning)
                        .font(.nbBody1)
                        .padding()
                }
                
                Button("Login") {
                    loginVM.signIn()
                }.buttonStyle(.bordered)
                    .background(Color.onPrimaryButtonSecondary)
                    .foregroundColor(.onPrimaryHighEmphasis)
                    .cornerRadius(4)
                
                AccountButton(text: "Forgot Password", destination: ForgotPasswordView())
                
                if (!loginVM.activated) {
                    Text("**Note**\n\nWhen you set a new password, all phones linked to the account will be automatically logged out for security reasons. All your observations will remain linked to your account.")
                        .tint(Color.onSecondaryButtonPrimary)
                        .font(.nbBody1)
                        .padding()
                }
                
                Spacer()
            }
        }.actionSheet(isPresented: $loginVM.showLoginSuccess) {
            ActionSheet(
                title: Text("Success!"),
                message: Text("You are signed in as: \(loginVM.email)"),
                buttons: [
                    .default(Text("Ok"), action: {
                        dismiss()
                    })
                ]
            )
        }.alertHttpError(isPresented: $loginVM.isPresented, error: loginVM.error)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
