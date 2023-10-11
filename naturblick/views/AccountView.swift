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
        VStack {
            Text("Naturblick account")
                .tint(Color.onSecondaryButtonPrimary)
                .font(.nbSubtitle1)
                .padding([.top, .bottom], .defaultPadding)
            
            if (accountViewModel.email == nil) {
                Text("A Naturblick account enables you to back up and view your observations across multiple mobile devices.\n\nHowever, you can still use Naturblick without an account.")
                    .tint(Color.onSecondaryButtonPrimary)
                    .font(.nbBody1)
                
                Button("Go to login") {
                    navigationController?.pushViewController(LoginView(accountViewModel: accountViewModel).setUpViewController(), animated: true)
                }.buttonStyle(ConfirmFullWidthButton())
                .padding([.top, .bottom], .defaultPadding)
                
                Button("Register now") {
                    navigationController?.pushViewController(RegisterView(accountViewModel: accountViewModel).setUpViewController(), animated: true)
                }.buttonStyle(ConfirmFullWidthButton())
            } else if (accountViewModel.bearerToken != nil) {
                Text("A Naturblick account enables you to back up and view your observations across multiple mobile devices.\n\nYou are signed in as: \(accountViewModel.email!)\n\n**Delete account**\n\nDeleting your account will remove the link to other devices and we will automatically delete the email address you provided.")
                    .tint(Color.onSecondaryButtonPrimary)
                    .font(.nbBody1)
                Button("Go to delete account") {
                    navigationController?.pushViewController(DeleteAccountView(accountViewModel: accountViewModel).setUpViewController(), animated: true)
                }.buttonStyle(DestructiveFullWidthButton())
                    .padding([.top, .bottom], .defaultPadding)
                
                Text("**Advice for the connection with old devices**\n\nTo transfer observations from old devices to new ones, we recommend that you log in on both devices. If you pass on or recycle your phone, uninstall Naturblick on your phone or simply reset it to its default settings. This will not delete your old observations. Do not delete the account, as this would break the link between the observations.")
                    .tint(Color.onSecondaryButtonPrimary)
                    .foregroundColor(.onPrimaryHighEmphasis)
                    .font(.nbBody1)
            } else if (accountViewModel.bearerToken == nil && accountViewModel.email != nil) {
                if (accountViewModel.neverSignedIn) {
                    Text("Log into your account.")
                        .tint(Color.onSecondaryButtonPrimary)
                        .font(.nbBody1)
                    Button("Go to login") {
                        navigationController?.pushViewController(LoginView(accountViewModel: accountViewModel).setUpViewController(), animated: true)
                    }.buttonStyle(ConfirmButton())
                        .padding([.top, .bottom], .defaultPadding)
                    Button("Continue without account") {
                        accountViewModel.signOut()
                    }.buttonStyle(ConfirmFullWidthButton())
                        .padding([.bottom], .defaultPadding)
                    Text("**Activation link**\n\nYou can access your Naturblick account only after confirming your registration. To do so, please click on the activation link that we have sent to your email address.")
                        .tint(Color.onSecondaryButtonPrimary)
                        .font(.caption)
                } else {
                    Text("You have been logged out because you have reset your password or deleted your account.\n\n**New password**\n\nLog in with your new password to link your observations on this phone to your account.")
                        .tint(Color.onSecondaryButtonPrimary)
                        .font(.nbBody1)
                    Button("Go to login") {
                        navigationController?.pushViewController(LoginView(accountViewModel: accountViewModel).setUpViewController(), animated: true)
                    }.buttonStyle(ConfirmFullWidthButton())
                        .padding([.top, .bottom], .defaultPadding)
                    Text("**Account deleted**\n\nRegister a new account or use Naturblick without an account.")
                        .tint(Color.onSecondaryButtonPrimary)
                        .font(.nbBody1)
                    Button("Register") {
                        navigationController?.pushViewController(RegisterView(accountViewModel: accountViewModel).setUpViewController(), animated: true)
                    }.buttonStyle(ConfirmFullWidthButton())
                        .padding([.top, .bottom], .defaultPadding)
                    Button("Continue without account") {
                        accountViewModel.signOut()
                    }.buttonStyle(AuxiliaryOnSecondaryFullwidthButton())
                }
            }
            Spacer()
        }
        .foregroundColor(.onSecondaryHighEmphasis)
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
        }.padding(.defaultPadding)
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
