//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct DeleteAccountView: View {
    
    @Binding var navigateTo: AccountNavigationDestination?
    
    @State private var email: String = Settings.EMAIL
    @State private var password: String = Settings.PASSWORD
    
    @State private var showDeleteSuccess = false
    
    @State private var showCredentialsError = false
    
    @State private var isPresented: Bool = false
    @State private var error: HttpError? = nil
    
    @EnvironmentObject private var model: AccountViewModel
    
    private func deleteAccount() {
        Task {
            do {
                try await model.deleteAccount(email: email, password: password)
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
    
    var body: some View {
        BaseView {
            VStack {
                Text("**Do you really want to delete your account?**\n\nDeleting your account will unlink all other devices. You will lose the connection to observations on these devices.\n\nPlease, confirm your wish to delete the account by entering your login details.")
                    .tint(Color.onSecondaryButtonPrimary)
                    .font(.nbBody1)
                    .padding()
                TextField("Email address", text: $email).padding()
                TextField("Password", text: $password).padding()
                if showCredentialsError {
                    Text("Credentials not recognized. Please validate your e-mail and password.")
                        .foregroundColor(.onSecondarywarning)
                        .font(.nbBody1)
                        .padding()
                }
                Button("Delete account") {
                    deleteAccount()
                }.foregroundColor(.black)
                    .buttonStyle(.bordered)
                Button("Forgot Password") {
                    navigateTo = .forgot
                }.buttonStyle(.bordered)
                    .foregroundColor(.black)
            }
        }.actionSheet(isPresented: $showDeleteSuccess) {
            ActionSheet(
                title: Text("Success!"),
                message: Text("Your account was deleted."),
                buttons: [
                    .default(Text("Ok"), action: {
                        navigateTo = .login
                    })
                ]
            )
        }.alertHttpError(isPresented: $isPresented, error: error)
    }
}

struct DeleteAccountView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteAccountView(navigateTo: .constant(.delete))
    }
}
