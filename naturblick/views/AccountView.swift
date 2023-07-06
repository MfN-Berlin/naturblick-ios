//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct AccountButton<Destination> : View where Destination : View {
    
    let text: String
    let destination: Destination
    
    var body: some View {
        Button(action: {}, label: {
            NavigationLink(destination: destination) {
                 Text(text)
             }
        }).buttonStyle(.bordered)
            .background(Color.onPrimaryButtonSecondary)
            .foregroundColor(.onPrimaryHighEmphasis)
            .cornerRadius(4)
    }
    
    
}

struct AccountView: View {
    
    @StateObject private var model = AccountViewModel()
            
    var body: some View {
        NavigationView {
            BaseView {
                VStack {
                    Text("**Naturblick account**")
                        .tint(Color.onSecondaryButtonPrimary)
                        .font(.nbBody1)
                        .padding()
                    
                    if (model.email == nil) {
                        Text("A Naturblick account enables you to back up and view your observations across multiple mobile devices.\n\nHowever, you can still use Naturblick without an account.")
                            .tint(Color.onSecondaryButtonPrimary)
                            .font(.nbBody1)
                            .padding()
                        
                        AccountButton(text: "Go to login", destination: LoginView())
                        AccountButton(text: "Register now", destination: RegisterView())
                        
                        
                    } else if (model.hasToken) {
                        Text("A Naturblick account enables you to back up and view your observations across multiple mobile devices.\n\nYou are signed in as: \(model.email!)\n\n**Delete account**\n\nDeleting your account will remove the link to other devices and we will automatically delete the email address you provided.")
                            .tint(Color.onSecondaryButtonPrimary)
                            .font(.nbBody1)
                            .padding()
                        
                        AccountButton(text: "Go to delete account", destination: DeleteAccountView())
                        Text("**Advice for the connection with old devices**\n\nTo transfer observations from old devices to new ones, we recommend that you log in on both devices. If you pass on or recycle your phone, uninstall Naturblick on your phone or simply reset it to its default settings. This will not delete your old observations. Do not delete the account, as this would break the link between the observations.")
                            .tint(Color.onSecondaryButtonPrimary)
                            .font(.nbBody1)
                            .padding()
                        
                    } else if (!model.hasToken && model.email != nil) {
                        Text("You have been logged out because you have reset your password or deleted your account.\n\n**New password**\n\nLog in with your new password to link your observations on this phone to your account.")
                            .tint(Color.onSecondaryButtonPrimary)
                            .font(.nbBody1)
                            .padding()
                        AccountButton(text: "Go to login", destination: LoginView())
                        Text("**Account deleted**\n\nRegister a new account or use Naturblick without an account.")
                            .tint(Color.onSecondaryButtonPrimary)
                            .font(.nbBody1)
                            .padding()
                        
                        AccountButton(text: "Register now", destination: RegisterView())
                        
                        Button("Continue without account") {
                            model.signOut()
                        }.buttonStyle(.bordered)
                            .background(Color.onPrimaryButtonSecondary)
                            .foregroundColor(.onPrimaryHighEmphasis)
                            .cornerRadius(4)
                    }
                    Spacer()
                }
            }.navigationTitle("Account")
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}
