//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

struct RegisterView: NavigatableView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    var viewName: String? = "Register"
        
    @StateObject var registerVM = RegisterViewModel()
        
    @State var showRegisterSuccess: Bool = false
    @State var showAlreadyExists = false
    
    @State var isPresented: Bool = false
    @State var error: HttpError? = nil
    
    @ObservedObject var accountViewModel: AccountViewModel
    
    func signUp() {
        let client = BackendClient()
        Task {
            do {
                let _ = try await client.signUp(deviceId: Settings.deviceId(), email: registerVM.email, password: registerVM.password)
                accountViewModel.email = registerVM.email
                showRegisterSuccess = true
            } catch HttpError.clientError(let statusCode) where statusCode == 409 {
                showAlreadyExists = true
            } catch is HttpError {
                self.error = error
                isPresented = true
            } catch {
                preconditionFailure(error.localizedDescription)
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack {
                Text("**Create account**\n\nYou create a Naturblick account here. Please enter an email address. We will send you the activation link to this address.")
                    .tint(Color.onSecondaryButtonPrimary)
                    .font(.nbBody1)
                    .padding()
                
                NBEditText(label: "Email address", icon: Image(systemName: "mail"), text: $registerVM.email, prompt: registerVM.emailPrompt)
                    .padding()
                    .keyboardType(.emailAddress)
                if showAlreadyExists {
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
                    signUp()
                }.buttonStyle(ConfirmButton())
                    .disabled(!registerVM.isRegisterEnabled)
                    .opacity(registerVM.isRegisterEnabled ? 1 : 0.6)
                Spacer(minLength: 10)
            }
        }
        .foregroundColor(.onSecondaryHighEmphasis)
        .actionSheet(isPresented: $showRegisterSuccess) {
            ActionSheet(
                title: Text("Thank you!"),
                message: Text("We have sent you an activation link by email. Please open this link to complete your registration. The link is valid for 12 hours."),
                buttons:
                    registerSuccessButtons()
            )
        }
        .alertHttpError(isPresented: $isPresented, error: error)
    }
        
    func registerSuccessButtons() -> [Alert.Button] {
        var buttons: [Alert.Button] = [Alert.Button.destructive(Text("Continue to login"), action: {
            toLogin()
        })]
        
        if (canOpenEmail()) {
            buttons.append(
                Alert.Button.default(Text("Open my emails"), action: { openMail(completionHandler: { _ in toLogin() }) })
            )
        }
        return buttons
    }
    
    private func toLogin() {
        withNavigation { navigation in
            var viewControllers = navigation.viewControllers
            viewControllers[viewControllers.count - 1] = LoginView(accountViewModel: accountViewModel).setUpViewController()
            navigation.setViewControllers(viewControllers, animated: true)
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView(accountViewModel: AccountViewModel())
    }
}

