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
        Text("**Willst du deinen Account wirklich löschen?**\n\nMit dem Löschen deines Accounts wird die Verknüpfung zu anderen Geräten aufgehoben. Du verlierst dann die Verbindung zu Beobachtungen auf diesen Geräten.")
            .tint(Color.onSecondaryButtonPrimary)
            .font(.nbBody1)
            .padding()
        TextField("E-Mail-Adresse", text: $email)
        TextField("Passwort", text: $password)
        Button("Account löschen") {
            model.deleteAccount(email: email, password: password)
            //TODO johannes sucess/ fail behandeln
        }.foregroundColor(.black)
            .buttonStyle(.bordered)
        Button("Passwort vergessen") {
            navigateTo = .forgot
        }
    }
}

struct DeleteAccountView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteAccountView(navigateTo: .constant(.delete))
    }
}
