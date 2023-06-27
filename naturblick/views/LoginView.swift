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
                    Text("Your Naturblick account is activated. Log in with your email address and password on all devices you want to connect to the account.")
                        .tint(Color.onSecondaryButtonPrimary)
                        .font(.nbBody1)
                        .padding()
                } else {
                    Text("Connect all observations on this phone to your account.")
                        .tint(Color.onSecondaryButtonPrimary)
                        .font(.nbBody1)
                        .padding()
                }
                
                TextField("Email address", text: $email)
                TextField("Password", text: $password)
                
                Button("Login") {
                    model.login(email: email, password: password)
                    //TODO johannes handle sucess/ fail
                    dismiss()
                }.foregroundColor(.black)
                    .buttonStyle(.bordered)
                Button("Forgot Password") {
                    navigateTo = .forgot
                }.buttonStyle(.bordered).foregroundColor(.black)
                
                if (!model.activated) {
                    Text("**Note**\n\nWhen you set a new password, all phones linked to the account will be automatically logged out for security reasons. All your observations will remain linked to your account.")
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
