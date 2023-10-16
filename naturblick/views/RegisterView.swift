//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

struct RegisterView: NavigatableView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    var viewName: String? = String(localized: "register")
        
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
                Text("sign_up_text")
                    .body1()
                
                
                OnSecondaryFieldView(icon: "create_24px") {
                    TextField(String(localized: "email"), text: $registerVM.email)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled(true)
                        .autocapitalization(.none)
                }
                if let prompt = registerVM.emailPrompt {
                    Text(prompt)
                        .caption()
                }
                
                if showAlreadyExists {
                    Text("user_already_exists")
                        .foregroundColor(.onSecondarywarning)
                }
                
                OnSecondaryFieldView(image: Image("visibility")) {
                    SecureField(String(localized: "password"), text: $registerVM.password)
                        .autocorrectionDisabled(true)
                        .autocapitalization(.none)
                }
                if let prompt = registerVM.passwordPrompt {
                    Text(prompt)
                        .caption()
                } else if registerVM.passwordPrompt == nil {
                    Text("password_format")
                        .caption()
                }
                            
                Text("privacy_rules_text")
                    .body1()

                Toggle("data_protection_consent", isOn: $registerVM.privacyChecked)
                    .font(.nbBody1)
                    .foregroundColor(.onSecondaryMediumEmphasis)
                
                Button("sign_up") {
                    signUp()
                }.buttonStyle(ConfirmFullWidthButton())
                    .disabled(!registerVM.isRegisterEnabled)
                    .opacity(registerVM.isRegisterEnabled ? 1 : 0.6)
                Spacer(minLength: 10)
            }
        }
        .padding(.defaultPadding)
        .actionSheet(isPresented: $showRegisterSuccess) {
            ActionSheet(
                title: Text("validate_email_title"),
                message: Text("validate_email_message"),
                buttons:
                    registerSuccessButtons()
            )
        }
        .alertHttpError(isPresented: $isPresented, error: error)
    }
        
    func registerSuccessButtons() -> [Alert.Button] {
        var buttons: [Alert.Button] = [Alert.Button.destructive(Text("go_to_login_screen"), action: {
            toLogin()
        })]
        
        if (canOpenEmail()) {
            buttons.append(
                Alert.Button.default(Text("open_default_email_app"), action: { openMail(completionHandler: { _ in toLogin() }) })
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

