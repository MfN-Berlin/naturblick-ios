//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

struct LoginView: View {
    
    @Binding var navigateTo: AccountNavigationDestination?
    
    @State private var email: String = ""
    @State private var password: String = ""
    
    @EnvironmentObject private var model: AccountViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var isPresented: Bool = false
    @State private var error: HttpError? = nil
    
    @State private var showCredentialsWrong = false
    @State private var showLoginSuccess = false
    
    private func signIn() -> Void {
        Task {
            do {
                let _ = try await model.signIn(email: email, password: password)
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
                if (model.activated) {
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
                
                TextField("Email address", text: $email).padding()
                TextField("Password", text: $password).padding()
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
                Button("Forgot Password") {
                    navigateTo = .forgot
                }.buttonStyle(.bordered).foregroundColor(.black)
                
                if (!model.activated) {
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
                message: Text("You are signed in as: \(email)"),
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
        LoginView(navigateTo: .constant(.login))
    }
}
