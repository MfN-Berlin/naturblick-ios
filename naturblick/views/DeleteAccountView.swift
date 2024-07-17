//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct DeleteAccountView: NavigatableView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    var viewName: String? = String(localized: "delete")
    
    @ObservedObject var accountViewModel: AccountViewModel
    
    @StateObject var deleteVM = EmailAndPasswordWithPrompt()
    
    @State var showDeleteSuccess = false
    
    @State var showCredentialsError = false
    
    @State var isPresented: Bool = false
    @State var error: HttpError? = nil
    
    func deleteAccount() {
        let client = BackendClient()
        Task {
            do {
                try await accountViewModel.delete(email: deleteVM.email, password: deleteVM.password)
                showDeleteSuccess = true
            } catch HttpError.clientError(let statusCode) where statusCode == 400 {
                showCredentialsError = true
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
            Text("delete_account_text_rly")
                .body1()
            
            HStack {
                Image(decorative: "create_24px")
                    .observationProperty()
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: .zero) {
                    Text("email")
                        .caption(color: .onSecondarySignalLow)
                    TextField(String(localized: "email"), text: $deleteVM.email)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled(true)
                        .autocapitalization(.none)
                }
            }
            
            if let prompt = deleteVM.emailPrompt {
                Text(prompt)
                    .caption()
            }
            
            HStack {
                Image(decorative: "visibility")
                    .observationProperty()
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: .zero) {
                    Text("password")
                        .caption(color: .onSecondarySignalLow)
                    SecureField(String(localized: "password"), text: $deleteVM.password)
                        .autocorrectionDisabled(true)
                        .autocapitalization(.none)
                }
            }
            if let prompt = deleteVM.passwordPrompt {
                Text(prompt)
                    .caption()
            }
            if showCredentialsError {
                Text("email_or_password_invalid")
                    .body1(color: .onSecondarywarning)
            }
            Button("delete_account") {
                deleteAccount()
            }.buttonStyle(DestructiveFullWidthButton()).textCase(.uppercase)
            Button("forgot_password") {
                navigationController?.pushViewController(ForgotPasswordView(accountViewModel: accountViewModel).setUpViewController(), animated: true)
            }.buttonStyle(ConfirmFullWidthButton()).textCase(.uppercase)
            Spacer()
        }
        .padding(.defaultPadding)
        .alert("delete_success", isPresented: $showDeleteSuccess) {
            Button("ok") {
                navigationController?.popViewController(animated: true)
            }
        } message: {
            Text("account_delete")
        }
        .alertHttpError(isPresented: $isPresented, error: error)
    }
}

struct DeleteAccountView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteAccountView(accountViewModel: AccountViewModel())
    }
}
