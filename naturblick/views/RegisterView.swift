//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

struct RegisterView: View {
    
    @ObservedObject var registerVM = RegisterViewModel()
    
    @State var action: String?
    
    
    var body: some View {
        BaseView {
            ScrollView {
                VStack {
                    
                    NavigationLink(destination: LoginView(), tag: AccountView.loginAction, selection: $action) {
                        EmptyView()
                    }
                    
                    Text("**Create account**\n\nYou create a Naturblick account here. Please enter an email address. We will send you the activation link to this address.")
                        .tint(Color.onSecondaryButtonPrimary)
                        .font(.nbBody1)
                        .padding()
                    
                    NBEditText(label: "Email address", icon: Image(systemName: "mail"), text: $registerVM.email, prompt: registerVM.emailPrompt).padding()
                    if registerVM.showAlreadyExists {
                        Text("Email already exists.")
                            .foregroundColor(.onSecondarywarning)
                            .font(.nbBody1)
                            .padding()
                    }
                    
                    
                    NBEditText(label: "Password", icon: Image(systemName: "eye"), text: $registerVM.password, isSecure: true, prompt: registerVM.passwordPrompt).padding()
                    if registerVM.passwordPrompt == nil {
                        Text("The password must be at least 9 characters long. It must consist of numbers, upper and lower case letters.")
                            .tint(Color.onSecondaryButtonPrimary)
                            .font(.nbCaption)
                            .padding([.leading, .trailing])
                    }
                    
                    Text("**Privacy statement**\n\nFor the registration we need your email address. The registration is only valid after you have clicked on a confirmation link in an email sent to you by us. The email address will be used by us exclusively for the administration of the account. The registration/login is voluntary and can be revoked at any time. Your personal data will be deleted from our system when the account is deleted.\n\nThe processing of the data is carried out in compliance with the applicable data protection regulations. The transmission of your entries is encrypted. In order to protect your data from loss, manipulation or access by unauthorized persons, the Museum für Naturkunde Berlin uses state-of-the-art technical and organizational measures.\n\nWe take data protection very seriously. You can find more information about data protection in the app's imprint.")
                        .tint(Color.onSecondaryButtonPrimary)
                        .font(.nbBody1)
                        .padding()
                    
                    Toggle("I have read and understood privacy statement.", isOn: $registerVM.privacyChecked).font(.nbBody1)
                        .padding()
                    
                    Button("Register") {
                        registerVM.signUp()
                    }.disabled(!registerVM.isRegisterEnabled)
                        .foregroundColor(.black)
                        .buttonStyle(.bordered)
                        .opacity(registerVM.isRegisterEnabled ? 1 : 0.6)
                    Spacer(minLength: 10)
                }
            }
        }.actionSheet(isPresented: $registerVM.showRegisterSuccess) {
            ActionSheet(
                title: Text("Thank you!"),
                message: Text("We have sent you an activation link by email. Please open this link to complete your registration. The link is valid for 12 hours."),
                buttons:
                    registerSuccessButtons()
            )
        }
        .alertHttpError(isPresented: $registerVM.isPresented, error: registerVM.error)
    }
    
    func registerSuccessButtons() -> [Alert.Button] {
        var buttons: [Alert.Button] = [Alert.Button.destructive(Text("Continue to login"), action: {
            action = AccountView.loginAction
        })]
       
        if (canOpenEmail()) {
            buttons.append(
                Alert.Button.default(Text("Open my emails"), action: { openMail(completionHandler: { _ in action = AccountView.loginAction }) })
            )
        }
        return buttons
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}

