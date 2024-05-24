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
        Task {
            do {
                try await accountViewModel.signUp(email: registerVM.email, password: registerVM.password)
                showRegisterSuccess = true
            } catch HttpError.clientError(let statusCode) where statusCode == 409 {
                showAlreadyExists = true
            } catch is HttpError {
                self.error = error
                isPresented = true
            } catch {
                Fail.with(error)
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: .defaultPadding) {
                Text("sign_up_text")
                    .body1()
                
                
                OnSecondaryFieldView(icon: "create_24px") {
                    TextField(String(localized: "email"), text: $registerVM.email)
                        .textContentType(.username)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                }
                if let prompt = registerVM.emailPrompt {
                    Text(prompt)
                        .caption(color: .onSecondaryMediumEmphasis)
                }
                
                if showAlreadyExists {
                    Text("user_already_exists")
                        .caption(color: .onSecondarywarning)
                }
                
                OnSecondaryFieldView(image: Image("visibility")) {
                    SecureField(String(localized: "password"), text: $registerVM.password)
                        .textContentType(.newPassword)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                }
                if let prompt = registerVM.passwordPrompt {
                    Text(prompt)
                        .caption(color: .onSecondaryMediumEmphasis)
                } else if registerVM.passwordPrompt == nil {
                    Text("password_format")
                        .caption(color: .onSecondaryMediumEmphasis)
                }
                            
                Text("privacy_rules_text")
                    .body1()
                Toggle(isOn: $registerVM.privacyChecked) {
                    Text("data_protection_consent")
                        .body1()
                }

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

