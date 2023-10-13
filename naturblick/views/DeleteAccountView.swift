//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct DeleteAccountView: NavigatableView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    var viewName: String? = "Delete Account"
    
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
            Text("**Do you really want to delete your account?**\n\nDeleting your account will unlink all other devices. You will lose the connection to observations on these devices.\n\nPlease, confirm your wish to delete the account by entering your login details.")
                .tint(Color.onSecondaryButtonPrimary)
                .font(.nbBody1)
                .padding()
            NBEditText(label: "Email address", icon: Image("create_24px"), text: $deleteVM.email, prompt: deleteVM.emailPrompt)
                .padding()
                .keyboardType(.emailAddress)
            NBEditText(label: "Password", icon: Image(systemName: "eye"), text: $deleteVM.password, isSecure: true, prompt: deleteVM.passwordPrompt).padding()
            if showCredentialsError {
                Text("Credentials not recognized. Please validate your e-mail and password.")
                    .foregroundColor(.onSecondarywarning)
                    .font(.nbBody1)
                    .padding()
            }
            Button("Delete account") {
                deleteAccount()
            }.buttonStyle(DestructiveFullWidthButton())
                .padding([.trailing, .bottom], .defaultPadding)
            Button {
                navigationController?.pushViewController(ForgotPasswordView(accountViewModel: accountViewModel).setUpViewController(), animated: true)
            } label: {
                Text("Forgot password")
            }.buttonStyle(ConfirmFullWidthButton())
        }
        .foregroundColor(.onSecondaryHighEmphasis)
        .actionSheet(isPresented: $showDeleteSuccess) {
            ActionSheet(
                title: Text("Success!"),
                message: Text("Your account was deleted."),
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
