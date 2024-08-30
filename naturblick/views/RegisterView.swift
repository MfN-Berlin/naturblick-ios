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
                
                HStack {
                    Image(decorative: "create_24px")
                        .observationProperty()
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: .zero) {
                        Text("email")
                            .caption(color: .onSecondarySignalLow)
                        TextField(String(localized: "email"), text: $registerVM.email)
                            .textContentType(.username)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                    }
                }
                
                if let prompt = registerVM.emailPrompt {
                    Text(prompt)
                        .caption(color: .onSecondaryMediumEmphasis)
                }
                
                if showAlreadyExists {
                    Text("user_already_exists")
                        .caption(color: .onSecondarywarning)
                }
                
                HStack {
                    Image(decorative: "visibility")
                        .observationProperty()
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: .zero) {
                        Text("password")
                            .caption(color: .onSecondarySignalLow)
                        SecureField(String(localized: "password"), text: $registerVM.password)
                            .textContentType(.password)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                    }
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
        .alert("validate_email_title", isPresented: $showRegisterSuccess) {
            Button("go_to_login_screen") {
                toLogin()
            }
            if (canOpenEmail()) {
                Button("open_default_email_app") {
                    openMail(completionHandler: { _ in toLogin() })
                }
            }
        } message: {
            Text("validate_email_message")
        }
        .alertHttpError(isPresented: $isPresented, error: error)
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
        RegisterView(accountViewModel: AccountViewModel(backend: Backend(persistence: ObservationPersistenceController(inMemory: true))))
    }
}

