//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

struct RegisterView: View {
    
    @Binding var navigateTo: AccountNavigationDestination?
    
    @State private var email: String = "johannes.ebbighausen@gmail.com"
    @State private var password: String = "asdfAsdf1"
    @State private var privacy: Bool = false
    @State private var showRegisterSuccess: Bool = false
    
    @EnvironmentObject private var model: AccountViewModel
    
    @State private var isPresented: Bool = false
    @State private var error: HttpError? = nil
    
    func register() {
        Task {
            do {
                let _ = try await model.register(email: email, password: password)
                showRegisterSuccess = true
            } catch is HttpError {
                self.error = error
                self.isPresented = true
            } catch {
                preconditionFailure(error.localizedDescription)
            }
        }
    }
    
    var body: some View {
        BaseView {
            ScrollView {
                VStack {
                    Text("**Create account**\n\nYou create a Naturblick account here. Please enter an email address. We will send you the activation link to this address.")
                        .tint(Color.onSecondaryButtonPrimary)
                        .font(.nbBody1)
                        .padding()
                    
                    TextField("Email address", text: $email).font(.nbBody1)
                        .padding()
                    TextField("Password", text: $password).font(.nbBody1)
                        .padding()
                    Text("The password must be at least 9 characters long. It must consist of numbers, upper and lower case letters.").tint(Color.onSecondaryButtonPrimary)
                        .font(.nbCaption)
                        .padding([.leading, .trailing])
                    
                    Text("**Privacy statement**\n\nFor the registration we need your email address. The registration is only valid after you have clicked on a confirmation link in an email sent to you by us. The email address will be used by us exclusively for the administration of the account. The registration/login is voluntary and can be revoked at any time. Your personal data will be deleted from our system when the account is deleted.\n\nThe processing of the data is carried out in compliance with the applicable data protection regulations. The transmission of your entries is encrypted. In order to protect your data from loss, manipulation or access by unauthorized persons, the Museum für Naturkunde Berlin uses state-of-the-art technical and organizational measures.\n\nWe take data protection very seriously. You can find more information about data protection in the app's imprint.")
                        .tint(Color.onSecondaryButtonPrimary)
                        .font(.nbBody1)
                        .padding()
                    
                    Toggle("I have read and understood privacy statement.", isOn: $privacy).font(.nbBody1)
                        .padding()
                    
                    Button("Register") {
                        register()
                    }.disabled(!privacy)
                        .foregroundColor(.black)
                        .buttonStyle(.bordered)
                    Spacer(minLength: 10)
                }
            }
        }.actionSheet(isPresented: $showRegisterSuccess) {
            ActionSheet(
                title: Text("Thank you!"),
                message: Text("We have sent you an activation link by email. Please open this link to complete your registration. The link is valid for 12 hours."),
                buttons: [
                    .default(Text("Open my emails"), action: {}),
                    .destructive(Text("Continue to login"), action: {
                        navigateTo = .login
                    })
                ]
            )
        }
        .alertHttpError(isPresented: $isPresented, error: error)
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView(navigateTo: .constant(.register))
    }
}

