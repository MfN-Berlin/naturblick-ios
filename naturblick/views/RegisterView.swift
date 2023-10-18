//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

class RegisterViewController: HostingController<RegisterView> {
    
    var accountViewModel: AccountViewModel
    let registerVM: RegisterViewModel
    
    init(accountViewModel: AccountViewModel) {
        self.accountViewModel = accountViewModel
        self.registerVM = RegisterViewModel(accountViewModel: accountViewModel)
        super.init(rootView: RegisterView(registerVM: self.registerVM, accountViewModel: self.accountViewModel))
    }
}

struct RegisterView: HostedView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    var viewName: String? = String(localized: "register")
        
    @ObservedObject var registerVM: RegisterViewModel
    @ObservedObject var accountViewModel: AccountViewModel
    
    func configureNavigationItem(item: UINavigationItem) {
        item.leftBarButtonItem = UIBarButtonItem(primaryAction: UIAction(title: String(localized: "cancel")) { _ in
            navigationController?.dismiss(animated: true)
        })
        
        item.rightBarButtonItem = UIBarButtonItem(primaryAction: UIAction(title: String(localized: "sign_up")) {_ in
            registerVM.signUp()
        })
        
        if registerVM.privacyChecked {
            item.rightBarButtonItem?.isEnabled = true
        } else {
            item.rightBarButtonItem?.isEnabled = false
        }
    }
    
    var body: some View {
        ScrollView {
            VStack {
                Text("sign_up_text")
                    .body1()
                
                HStack {
                    Image("create_24px").foregroundColor(.onSecondaryMediumEmphasis)
                    TextField("email",
                        text: $registerVM.email,
                        prompt: Text("email")
                    )
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled(true)
                    .autocapitalization(.none)
                        
                }
                if let emailHint = registerVM.emailHint {
                    Text(emailHint)
                        .caption()
                }
                
                if registerVM.showAlreadyExists {
                    Text("user_already_exists")
                        .caption(color: .onSecondarywarning)
                }
                
                HStack {
                    Image("visibility").foregroundColor(.onSecondaryMediumEmphasis)
                    SecureField(
                        "password",
                        text: $registerVM.password,
                        prompt: Text("password")
                    )
                    .autocorrectionDisabled(true)
                    .autocapitalization(.none)
                }
                if let passwordHint = registerVM.passwordHint {
                    Text(passwordHint)
                        .caption()
                } else if registerVM.passwordHint == nil {
                    Text("password_format")
                        .caption()
                }
                            
                Text("privacy_rules_text")
                    .body1()
                Toggle(isOn: $registerVM.privacyChecked) {
                    Text("data_protection_consent")
                        .body1()
                }

                Spacer(minLength: 10)
            }
        }
        .padding(.defaultPadding)
        .actionSheet(isPresented: $registerVM.showRegisterSuccess) {
            ActionSheet(
                title: Text("validate_email_title"),
                message: Text("validate_email_message"),
                buttons:
                    registerSuccessButtons()
            )
        }
        .alertHttpError(isPresented: $registerVM.isPresented, error: registerVM.error)
        .onChange(of: registerVM.privacyChecked) { isChecked in
            if let navItem = viewController?.navigationItem {
                print("reconfigure ==")
                configureNavigationItem(item: navItem)
            }
        }
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
            viewControllers[viewControllers.count - 1] = LoginViewController(accountViewModel: accountViewModel)
            navigation.setViewControllers(viewControllers, animated: true)
        }
    }
}
