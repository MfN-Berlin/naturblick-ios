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
                try await client.deleteAccount(email: deleteVM.email, password: deleteVM.password)
                accountViewModel.signOut()
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
        VStack {
            Text("delete_account_text")
            NBEditText(label: String(localized: "email"), icon: Image("create_24px"), text: $deleteVM.email, prompt: deleteVM.emailPrompt)
                .keyboardType(.emailAddress)
            NBEditText(label: String(localized: "password"), icon: Image(systemName: "eye"), text: $deleteVM.password, isSecure: true, prompt: deleteVM.passwordPrompt)
            if showCredentialsError {
                Text("email_or_password_invalid")
            }
            Button("delete_account") {
                deleteAccount()
            }.buttonStyle(DestructiveFullWidthButton()).textCase(.uppercase)
            Button("forgot_password") {
                navigationController?.pushViewController(ForgotPasswordView(accountViewModel: accountViewModel).setUpViewController(), animated: true)
            } .buttonStyle(ConfirmFullWidthButton()).textCase(.uppercase)

        }
        .padding(.defaultPadding)
        .foregroundColor(.onSecondaryHighEmphasis)
        .tint(Color.onSecondaryButtonPrimary)
        .font(.nbBody1)
        .actionSheet(isPresented: $showDeleteSuccess) {
            ActionSheet(
                title: Text("delete_success"),
                message: Text("account_delete"),
                buttons: [
                    .default(Text("Ok"), action: {
                        navigationController?.popViewController(animated: true)
                    })
                ]
            )
        }.alertHttpError(isPresented: $isPresented, error: error)
    }
}

struct DeleteAccountView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteAccountView(accountViewModel: AccountViewModel())
    }
}
