//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import Combine

struct AccountView: NavigatableView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    var viewName: String? = String(localized: "account")
    
    var token: String?
    let backend: Backend
    @StateObject var accountViewModel: AccountViewModel
    @StateObject private var errorHandler = HttpErrorViewModel()
    @ObservedObject var keychain = Keychain.shared
    
    init(backend: Backend, token: String? = nil) {
        self.token = token
        self.backend = backend
        _accountViewModel = StateObject(wrappedValue: AccountViewModel(backend: backend))
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .defaultPadding) {
                Text("your_account")
                    .subtitle1()
                
                if (keychain.email == nil) {
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
                } else if (keychain.token != nil) {
                    Text("your_account_text")
                        .body1()
                    Text("signed_in_as \(keychain.email!)")
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
                } else if (keychain.token == nil && keychain.email != nil) {
                    if accountViewModel.neverSignedIn {
                        Text("continue_with_sign_in")
                            .body1()
                        Button("to_sign_in") {
                            navigationController?.pushViewController(LoginView(accountViewModel: accountViewModel).setUpViewController(), animated: true)
                        }.buttonStyle(ConfirmFullWidthButton()).textCase(.uppercase)
                        Button("sign_out") {
                            accountViewModel.signOut()
                        }.buttonStyle(ConfirmFullWidthButton()).textCase(.uppercase)
                        Text("activation_link_note")
                            .caption(color: .onSecondaryMediumEmphasis)
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
        }
        .padding(.defaultPadding)
        .onAppear {
            activateAccount()
        }
        .alertHttpError(isPresented: $errorHandler.isPresented, error: errorHandler.error) { details in
            Button("try_again") {
                activateAccount()
            }
            Button("cancel") {
                navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func activateAccount() {
        if let token = token {
            Task {
                do {
                    try await backend.activateAccount(token: token)
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
        AccountView(backend: Backend(persistence: ObservationPersistenceController(inMemory: true)))
    }
}
