//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct AccountView: View {
    
    @AppSecureStorage(NbAppSecureStorageKey.BearerToken) var bearerToken: String?
    @AppSecureStorage(NbAppSecureStorageKey.Email) var email: String?
    
    @AppStorage("hasToken") var hasToken: Bool = false
    @AppStorage("neverSignedIn") var neverSignedIn: Bool = true
    @AppStorage("activated") var activated: Bool = false
    
    static let loginAction = "login"
    static let accountAction = "account"
    
    private func signOut() {
        email = nil
        neverSignedIn = true
        bearerToken = nil
        activated = false
        hasToken = false
    }
    
    var body: some View {
        BaseView {
            VStack {
                Text("**Naturblick account**")
                    .tint(Color.onSecondaryButtonPrimary)
                    .font(.nbBody1)
                    .padding()
                
                if (email == nil) {
                    Text("A Naturblick account enables you to back up and view your observations across multiple mobile devices.\n\nHowever, you can still use Naturblick without an account.")
                        .tint(Color.onSecondaryButtonPrimary)
                        .font(.nbBody1)
                        .padding()
                    NavigationLink(destination: LoginView()) {
                        Text("Go to login")
                    }.buttonStyle(.bordered).foregroundColor(.black)
                    NavigationLink(destination: RegisterView()) {
                        Text("Register now")
                    }.buttonStyle(.bordered).foregroundColor(.black)
                } else if (hasToken) {
                    Text("A Naturblick account enables you to back up and view your observations across multiple mobile devices.\n\nYou are signed in as: \(email!)\n\n**Delete account**\n\nDeleting your account will remove the link to other devices and we will automatically delete the email address you provided.")
                        .tint(Color.onSecondaryButtonPrimary)
                        .font(.nbBody1)
                        .padding()
                    NavigationLink(destination: DeleteAccountView()) {
                        Text("Go to delete account")
                    }.buttonStyle(.bordered).foregroundColor(.black)
                    Text("**Advice for the connection with old devices**\n\nTo transfer observations from old devices to new ones, we recommend that you log in on both devices. If you pass on or recycle your phone, uninstall Naturblick on your phone or simply reset it to its default settings. This will not delete your old observations. Do not delete the account, as this would break the link between the observations.")
                        .tint(Color.onSecondaryButtonPrimary)
                        .font(.nbBody1)
                        .padding()

                } else if (bearerToken == nil && email != nil) {
                    if (neverSignedIn) {
                        Text("Log into your account.")
                            .tint(Color.onSecondaryButtonPrimary)
                            .font(.nbBody1)
                            .padding()
                        NavigationLink(destination: LoginView()) {
                            Text("Go to login")
                        }.buttonStyle(.bordered).foregroundColor(.black)
                        Button("Continue without account") {
                            signOut()
                        }.buttonStyle(.bordered).foregroundColor(.black)
                        Text("**Activation link**\n\nYou can access your Naturblick account only after confirming your registration. To do so, please click on the activation link that we have sent to your email address.")
                            .tint(Color.onSecondaryButtonPrimary)
                            .font(.caption)
                            .padding()
                    } else {
                        Text("You have been logged out because you have reset your password or deleted your account.\n\n**New password**\n\nLog in with your new password to link your observations on this phone to your account.")
                            .tint(Color.onSecondaryButtonPrimary)
                            .font(.nbBody1)
                            .padding()
                        NavigationLink(destination: LoginView()) {
                            Text("Go to login")
                        }.buttonStyle(.bordered).foregroundColor(.black)
                        Text("**Account deleted**\n\nRegister a new account or use Naturblick without an account.")
                            .tint(Color.onSecondaryButtonPrimary)
                            .font(.nbBody1)
                            .padding()
                        NavigationLink(destination: RegisterView()) {
                            Text("Register")
                        }.buttonStyle(.bordered).foregroundColor(.black)
                        Button("Continue without account") {
                            signOut()
                        }.foregroundColor(.black)
                        .buttonStyle(.bordered)
                    }
                }
                Spacer()
            }
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}
