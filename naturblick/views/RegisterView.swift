//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

struct RegisterView: View {
    
    @Binding var navigateTo: AccountNavigationDestination?
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var privacy: Bool = false
    @State private var showRegisterSuccess: Bool = false
    
    @EnvironmentObject private var model: AccountViewModel
    
    var body: some View {
        BaseView {
            ScrollView {
                VStack {
                    Text("**Naturblick-Account erstellen**\n\nHier kannst du einen Naturblick-Account erstellen. Bitte, gib dafür eine E-Mail-Adresse an. Wir senden dir dann den Aktivierungslink an diese Adresse.")
                        .tint(Color.onSecondaryButtonPrimary)
                        .font(.nbBody1)
                        .padding()
                    
                    TextField("E-Mail-Adresse", text: $email).font(.nbBody1)
                        .padding()
                    TextField("Passwort", text: $password).font(.nbBody1)
                        .padding()
                    Text("Das Passwort muss mindestens 9 Zeichen lang sein. Es muss aus Zahlen, Groß- und Kleinbuchstaben bestehen.").tint(Color.onSecondaryButtonPrimary)
                        .font(.nbCaption)
                        .padding([.leading, .trailing])
                    
                    Text("**Datenschutzerklärung**\n\nFür die Registrierung benötigen wir deine E-Mail-Adresse. Die Anmeldung wird erst gültig, nachdem du in einer von uns an dich verschickten E-Mail einen Bestätigungslink angeklickt hast. Die E-Mail-Adresse wird von uns ausschließlich für die Verwaltung des Accounts verwendet. Die Registrierung/Anmeldung erfolgt freiwillig und kann jederzeit widerrufen werden. Deine personenbezogenen Daten werden mit dem Löschen des Accounts aus unserem System gelöscht.\n\nDie Verarbeitung der Daten erfolgt unter Beachtung der geltenden datenschutzrechtlichen Bestimmungen. Die Übertragung deiner Eingaben erfolgt verschlüsselt. Um die Daten vor Verlust, Manipulation oder Zugriff durch unberechtigte Personen zu schützen, werden durch das Museum für Naturkunde technisch-organisatorische Maßnahmen eingesetzt, die dem aktuellen Stand der Technik entsprechen.\n\nWir nehmen Datenschutz sehr wichtig. Weitere Informationen zum Datenschutz findest du im Impressum der App.")
                        .tint(Color.onSecondaryButtonPrimary)
                        .font(.nbBody1)
                        .padding()
                    
                    Toggle("Ich habe die Datenschutzerklärung zur Kenntnis genommen.", isOn: $privacy).font(.nbBody1)
                        .padding()
                    
                    Button("Registrieren") {
                        model.register(email: email, password: password)
                        showRegisterSuccess = true
                    }.disabled(privacy)
                        .foregroundColor(.black)
                        .buttonStyle(.bordered)
                }
            }
        }.actionSheet(isPresented: $showRegisterSuccess) {
            ActionSheet(
                title: Text("Vielen Dank"),
                message: Text("Wir haben dir per E-Mail einen Aktivierungslink geschickt. Bitte öffne diesen Link um deine Registrierung abzuschließen. Der Link ist gültig für 12 Stunden."),
                buttons: [
                    .default(Text("Meine E-Mails öffnen"), action: {}),
                    .destructive(Text("Weiter zum Login"), action: {
                        navigateTo = .login
                    })
                ]
            )
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView(navigateTo: .constant(.register))
    }
}

