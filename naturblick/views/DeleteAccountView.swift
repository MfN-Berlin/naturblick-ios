//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct DeleteAccountView: View {
    
    @Binding var navigateTo: AccountNavigationDestination?
    
    @State private var email: String = ""
    @State private var password: String = ""
    
    @EnvironmentObject private var model: AccountViewModel
    
    var body: some View {
        Text("**Do you really want to delete your account?**\n\nDeleting your account will unlink all other devices. You will lose the connection to observations on these devices.\n\nPlease, confirm your wish to delete the account by entering your login details.")
            .tint(Color.onSecondaryButtonPrimary)
            .font(.nbBody1)
            .padding()
        TextField("Email address", text: $email)
        TextField("Password", text: $password)
        Button("Delete account") {
            model.deleteAccount(email: email, password: password)
            //TODO johannes sucess/ fail behandeln
        }.foregroundColor(.black)
            .buttonStyle(.bordered)
        Button("Forgot Password") {
            navigateTo = .forgot
        }
    }
}

struct DeleteAccountView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteAccountView(navigateTo: .constant(.delete))
    }
}
