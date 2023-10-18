//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

struct SigninResponse : Decodable {
    let access_token: String
}

class LoginViewController: HostingController<LoginView> {
    
    var accountViewModel: AccountViewModel
    let loginVM: LoginViewModel
    
    init(accountViewModel: AccountViewModel) {
        self.accountViewModel = accountViewModel
        self.loginVM = LoginViewModel(accountViewModel: accountViewModel)
        super.init(rootView: LoginView(accountViewModel: self.accountViewModel, loginVM: self.loginVM))
    }
}

struct LoginView: HostedView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    var viewName: String? = String(localized: "login")
    
    @ObservedObject var accountViewModel: AccountViewModel
    @ObservedObject var loginVM: LoginViewModel
        
    func configureNavigationItem(item: UINavigationItem) {
        item.leftBarButtonItem = UIBarButtonItem(primaryAction: UIAction(title: String(localized: "cancel")) { _ in
            navigationController?.dismiss(animated: true)
        })
        
        item.rightBarButtonItem = UIBarButtonItem(primaryAction: UIAction(title: String(localized: "sign_in")) {_ in
            loginVM.signIn()
        })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: .defaultPadding) {
            if (accountViewModel.activated) {
                Text("account_activated")
                    .body1()
            } else {
                Text("login_standard")
                    .body1()
            }
            
            HStack {
                Image("create_24px").foregroundColor(.onSecondaryMediumEmphasis)
                TextField("email",
                    text: $loginVM.email,
                    prompt: Text("email")
                )
                .keyboardType(.emailAddress)
                .autocorrectionDisabled(true)
                .autocapitalization(.none)
                    
            }
            if let emailHint = loginVM.emailHint {
                Text(emailHint)
                    .caption()
            }
            
            HStack {
                Image("visibility").foregroundColor(.onSecondaryMediumEmphasis)
                SecureField(
                    "password",
                    text: $loginVM.password,
                    prompt: Text("password")
                )
                .autocorrectionDisabled(true)
                .autocapitalization(.none)
            }
            if let passwordHint = loginVM.passwordHint {
                Text(passwordHint)
                    .caption()
            } else if loginVM.passwordHint == nil {
                Text("password_format")
                    .caption()
            }
            if loginVM.showCredentialsWrong {
                Text("email_or_password_invalid")
                    .body1(color: .onSecondarywarning)
            }
            
            Button("forgot_password") {
                navigationController?.present(PopAwareNavigationController(rootViewController: ForgotPasswordViewController(accountViewModel: accountViewModel)), animated: true)
            }
            .buttonStyle(AuxiliaryOnSecondaryFullwidthButton())
            .textCase(.uppercase)
            .foregroundColor(.onSecondaryMediumEmphasis)
            
            Text("delete_account_note_password")
                .body2()
            Spacer()
        }
        .padding(.defaultPadding)
        .actionSheet(isPresented: $loginVM.showLoginSuccess) {
            ActionSheet(
                title: Text("successful_signin"),
                message: Text("signed_in_as \(loginVM.email)"),
                buttons: [
                    .default(Text("Ok"), action: {
                        navigationController?.popViewController(animated: true)
                    })
                ]
            )
        }
        .alertHttpError(isPresented: $loginVM.isPresented, error: loginVM.error)
        .onAppear {
            if let email = accountViewModel.email {
                loginVM.email = email
            }
        }
    }
}
