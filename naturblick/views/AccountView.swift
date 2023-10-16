//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI


class AccountViewModel : ObservableObject {
    @AppSecureStorage(NbAppSecureStorageKey.BearerToken) var bearerToken: String?
    @AppSecureStorage(NbAppSecureStorageKey.Email) var email: String?
    
    @AppStorage("neverSignedIn") var neverSignedIn: Bool = true
    @AppStorage("activated") var activated: Bool = false
    
    func signOut() {
        email = nil
        neverSignedIn = true
        bearerToken = nil
        activated = false
    }
}


struct AccountView: NavigatableView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    var viewName: String? = "Account"
    
    var token: String? = nil
    
    @StateObject var accountViewModel = AccountViewModel()
    @StateObject private var errorHandler = HttpErrorViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: .defaultPadding) {
            Text("your_account")
                .subtitle1()
            
            if (accountViewModel.email == nil) {
                Text("account_text_sign_in_or_sign_up1")
                    .body1()
                Text("account_text_sign_in_or_sign_up2")
                    .body1()
                Button("to_sign_in") {
                    navigationController?.pushViewController(LoginView(accountViewModel: accountViewModel).setUpViewController(), animated: true)
                }.buttonStyle(ConfirmFullWidthButton()).textCase(.uppercase)
                Button("to_sign_up") {
                    navigationController?.pushViewController(RegisterView(accountViewModel: accountViewModel).setUpViewController(), animated: true)
                }.buttonStyle(ConfirmFullWidthButton()).textCase(.uppercase)
            } else if (accountViewModel.bearerToken != nil) {
                Text("your_account_text")
                    .body1()
                Text("signed_in_as \(accountViewModel.email!)")
                    .body1()
                Text("delete_account_title")
                    .body1()
                Text("delete_account_text")
                    .body1()
                
                Button("to_delete_account") {
                    navigationController?.pushViewController(DeleteAccountView(accountViewModel: accountViewModel).setUpViewController(), animated: true)
                }.buttonStyle(DestructiveFullWidthButton()).textCase(.uppercase)
                
                Text("delete_account_note_link")
                    .body2()
            } else if (accountViewModel.bearerToken == nil && accountViewModel.email != nil) {
                if (accountViewModel.neverSignedIn) {
                    Text("continue_with_sign_in")
                        .body1()
                    Button("to_sign_in") {
                        navigationController?.pushViewController(LoginView(accountViewModel: accountViewModel).setUpViewController(), animated: true)
                    }.buttonStyle(ConfirmFullWidthButton()).textCase(.uppercase)
                    Button("sign_out") {
                        accountViewModel.signOut()
                    }.buttonStyle(ConfirmFullWidthButton()).textCase(.uppercase)
                    Text("activation_link_note")
                        .caption()
                } else {
                    Text("signed_out")
                        .body1()
                    Button("to_sign_in") {
                        navigationController?.pushViewController(LoginView(accountViewModel: accountViewModel).setUpViewController(), animated: true)
                    }.buttonStyle(ConfirmFullWidthButton()).textCase(.uppercase)
                    
                    Text("signed_out_deleted_account")
                        .body1()
                    
                    Button("sign_up") {
                        navigationController?.pushViewController(RegisterView(accountViewModel: accountViewModel).setUpViewController(), animated: true)
                    }.buttonStyle(ConfirmFullWidthButton()).textCase(.uppercase)
                    Button("sign_out") {
                        accountViewModel.signOut()
                    }.buttonStyle(AuxiliaryOnSecondaryFullwidthButton()).textCase(.uppercase)
                }
            }
            Spacer()
        }
        .padding(.defaultPadding)
        .onAppear {
            activateAccount()
        }
        .alertHttpError(isPresented: $errorHandler.isPresented, error: errorHandler.error) { details in
            Button("Try again") {
                activateAccount()
            }
            Button("Cancel") {
                navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func activateAccount() {
        if let token = token {
            Task {
                do {
                    try await BackendClient().activateAccount(token: token)
                    accountViewModel.activated = true
                } catch {
                    let _ = errorHandler.handle(error)
                }
            }
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}
