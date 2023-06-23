//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct LoginView: View {
    
    @Binding var navigateTo: AccountNavigationDestination?
    
    @State private var email: String = ""
    @State private var password: String = ""
    
    @EnvironmentObject private var model: AccountViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        BaseView {
            VStack {
                if (model.activated) {
                    Text("Dein Naturblick-Account ist aktiviert. Logge dich mit deiner E-Mail-Adresse und Passwort auf allen Geräten ein, die du mit dem Account verbinden möchtest.")
                        .tint(Color.onSecondaryButtonPrimary)
                        .font(.nbBody1)
                        .padding()
                } else {
                    Text("Verbinde alle Beobachtungen auf diesem Handy mit deinem Account.")
                        .tint(Color.onSecondaryButtonPrimary)
                        .font(.nbBody1)
                        .padding()
                }
                
                TextField("E-Mail-Adresse", text: $email)
                TextField("Passwort", text: $password)
                
                Button("Login") {
                    model.login(email: email, password: password)
                    //TODO johannes handle sucess/ fail
                    dismiss()
                }.foregroundColor(.black)
                    .buttonStyle(.bordered)
                Button("Passwort vergessen") {
                    navigateTo = .forgot
                }.buttonStyle(.bordered).foregroundColor(.black)
                
                if (!model.activated) {
                    Text("**Hinweis Passwort vergessen**\n\nWenn du ein neues Passwort vergibst, werden alle Handys, die mit dem Account verknüpft sind, aus Sicherheitsgründen automatisch ausgeloggt. Alle deine Beobachtungen bleiben weiterhin mit deinem Account verknüpft und werden dir angezeigt.")
                        .tint(Color.onSecondaryButtonPrimary)
                        .font(.nbBody1)
                        .padding()
                }
                
                Spacer()
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(navigateTo: .constant(.login))
    }
}
