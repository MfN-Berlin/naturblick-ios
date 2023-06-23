//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

enum AccountNavigationDestination {
    case login
    case forgot
    case register
    case delete
}

struct AccountView: View {
    
    @StateObject private var model = AccountViewModel()
    
    @State var navigateTo: AccountNavigationDestination? = nil
        
    var body: some View {
        BaseView {
            VStack {
                Text("**Dein Naturblick-Account**")
                    .tint(Color.onSecondaryButtonPrimary)
                    .font(.nbBody1)
                    .padding()
                
                if (model.fullySignedOut) {
                    Text("Mit einem Naturblick-Account kannst du deine Beobachtungen bei einem Handywechsel über mehrere mobile Geräte hinweg sichern und auf allen verbundenen Handys anzeigen lassen.\n\nDu kannst Naturblick aber natürlich auch ohne Account wie bisher verwenden.")
                        .tint(Color.onSecondaryButtonPrimary)
                        .font(.nbBody1)
                        .padding()
                    Button("Zum Login") {
                        navigateTo = .login
                    }.buttonStyle(.bordered).foregroundColor(.black)
                    Button("Jetzt registrieren") {
                        navigateTo = .register
                    }.buttonStyle(.bordered).foregroundColor(.black)
                } else if (model.email != nil && model.hasToken) {
                    Text("Mit deinem Naturblick-Account sind deine Beobachtungen über mehrere mobile Geräte gesichert und werden dir auf allen verbundenen Handys angezeigt.\n\nDu bist eingeloggt als: \(model.email!)\n\n**Account löschen**\n\nMit dem Löschen deines Accounts wird die Verknüpfung zu anderen Geräten aufgehoben und wir löschen automatisch die von dir angegebene E-Mail-Adresse.")
                        .tint(Color.onSecondaryButtonPrimary)
                        .font(.nbBody1)
                        .padding()
                    Button("Zum Account Löschen") {
                        navigateTo = .delete
                    }.buttonStyle(.bordered).foregroundColor(.black)
                    Text("**Hinweis für die Verbindung mit alten Geräten**\n\nFür die Übertragung von Beobachtungen von alten Geräten auf neue, empfehlen wir dir, dich einfach auf beiden Geräten einzuloggen. Solltest du das Handy dann weitergeben oder recyceln, deinstalliere Naturblick auf deinem Handy oder setze es einfach auf die Werkseinstellungen zurück. Deine alten Beobachtungen werden dadurch nicht gelöscht. Lösche den Account nicht, da dadurch die Verknüpfung der Beobachtungen aufgehoben werden würde.")
                        .tint(Color.onSecondaryButtonPrimary)
                        .font(.nbBody1)
                        .padding()

                } else if (model.email != nil && !model.hasToken && !model.neverSignedIn) {
                    Text("Du wurdest automatisch ausgeloggt, da du dein Passwort zurückgesetzt oder deinen Account gelöscht hast.\n\n**Neues Passwort**\n\nMelde dich mit deinem neuen Passwort an, um deine Beobachtungen auf diesem Handy wieder mit deinem Account zu verknüpfen.")
                        .tint(Color.onSecondaryButtonPrimary)
                        .font(.nbBody1)
                        .padding()
                    Button("Zum Login") {
                        navigateTo = .login
                    }.buttonStyle(.bordered).foregroundColor(.black)
                    Text("**Account gelöscht**\n\nRegistriere dich erneut oder nutze Naturblick ohne Account.")
                        .tint(Color.onSecondaryButtonPrimary)
                        .font(.nbBody1)
                        .padding()
                    Button("Registrieren") {
                        navigateTo = .register
                    }.buttonStyle(.bordered).foregroundColor(.black)
                    Button("Weiter ohne Account") {
                        model.signOutAfterRegister()
                    }.foregroundColor(.black)
                    .buttonStyle(.bordered)
                }
                Spacer()
            }
        }.background {
            SwiftUI.Group {
                NavigationLink(
                    tag: .login, selection: $navigateTo,
                    destination: {
                        LoginView(navigateTo: $navigateTo).environmentObject(model)
                    }
                ) {
                }
                NavigationLink(
                    tag: .forgot, selection: $navigateTo,
                    destination: {
                        ForgotPasswordView(navigateTo: $navigateTo).environmentObject(model)
                    }
                ) {
                }
                NavigationLink(
                    tag: .delete, selection: $navigateTo,
                    destination: {
                        DeleteAccountView(navigateTo: $navigateTo).environmentObject(model)
                    }
                ) {
                }
                NavigationLink(
                    tag: .register, selection: $navigateTo,
                    destination: {
                        RegisterView(navigateTo: $navigateTo).environmentObject(model)
                    }
                ) {
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
