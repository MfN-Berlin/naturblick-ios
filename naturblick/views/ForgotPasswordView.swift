//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct ForgotPasswordView: View {
    
    @Binding var navigateTo: AccountNavigationDestination?
    
    @State private var email: String = ""
    @State private var showSendInfo: Bool = false
    
    var body: some View {
        BaseView {
            VStack {
                TextField("E-Mail-Adresse", text: $email).font(.nbBody1)
                    .padding()
                
                Button("Passwort zurücksetzen") {
                    showSendInfo = true
                }.foregroundColor(.black)
                    .buttonStyle(.bordered)
                Text("**Hinweis Passwort vergessen**\n\nWenn du ein neues Passwort vergibst, werden alle Handys, die mit dem Account verknüpft sind, aus Sicherheitsgründen automatisch ausgeloggt. Alle deine Beobachtungen bleiben weiterhin mit deinem Account verknüpft und werden dir angezeigt.")
                    .tint(Color.onSecondaryButtonPrimary)
                    .font(.nbBody1)
                    .padding()
                Spacer()
            }
        }.actionSheet(isPresented: $showSendInfo) {
            ActionSheet(
                title: Text("Neues Passwort"),
                message: Text("Wir haben an die von dir angegebene E-Mail-Adresse einen Link zum Zurücksetzen des Passworts gesendet. Der Link ist gültig für 12 Stunden. Solltest du nach 10 Minuten keine E-Mail erhalten, ist uns die angegebene E-Mail-Adresse nicht bekannt."),
                buttons: [
                    .default(Text("Meine E-Mails öffnen"), action: {
                        //TODO johannes hier zum EMail Client
                    }),
                    .destructive(Text("Zurück zum Login"), action: {
                        navigateTo = .login
                    })
                ]
            )
        }
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView(navigateTo: .constant(.forgot))
    }
}
