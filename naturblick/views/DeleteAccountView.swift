//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

class DeleteAccountViewController: HostingController<DeleteAccountView> {
    
    var accountViewModel: AccountViewModel
    let deleteVM: DeleteAccountViewModel
    
    init(accountViewModel: AccountViewModel) {
        self.accountViewModel = accountViewModel
        self.deleteVM = DeleteAccountViewModel(accountViewModel: accountViewModel)
        super.init(rootView: DeleteAccountView(accountViewModel: self.accountViewModel, deleteVM: self.deleteVM))
    }
}

struct DeleteAccountView: HostedView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    var viewName: String? = String(localized: "delete")
    
    @ObservedObject var accountViewModel: AccountViewModel
    @ObservedObject var deleteVM: DeleteAccountViewModel
    
    func configureNavigationItem(item: UINavigationItem) {
        item.leftBarButtonItem = UIBarButtonItem(primaryAction: UIAction(title: String(localized: "cancel")) {_ in
            navigationController?.dismiss(animated: true)
        })
        
        item.rightBarButtonItem = UIBarButtonItem(primaryAction: UIAction(title: String(localized: "delete_account")) {_ in
            deleteVM.deleteAccount()
        })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: .defaultPadding) {
            Text("delete_account_text_rly")
                .body1()
            HStack {
                Image("create_24px").foregroundColor(.onSecondaryMediumEmphasis)
                TextField("email",
                    text: $deleteVM.email,
                    prompt: Text("email")
                )
                .keyboardType(.emailAddress)
                .autocorrectionDisabled(true)
                .autocapitalization(.none)
                    
            }
            if let emailHint = deleteVM.emailHint {
                Text(emailHint)
                    .caption()
            }
            
            HStack {
                Image("visibility").foregroundColor(.onSecondaryMediumEmphasis)
                SecureField(
                    "password",
                    text: $deleteVM.password,
                    prompt: Text("password")
                )
                .autocorrectionDisabled(true)
                .autocapitalization(.none)
            }
            if let passwordHint = deleteVM.passwordHint {
                Text(passwordHint)
                    .caption()
            }
            if deleteVM.showCredentialsError {
                Text("email_or_password_invalid")
                    .body1(color: .onSecondarywarning)
            }
         
            Button("forgot_password") {
                navigationController?.present(PopAwareNavigationController(rootViewController: ForgotPasswordViewController(accountViewModel: accountViewModel)), animated: true)
            }.buttonStyle(ConfirmFullWidthButton()).textCase(.uppercase)
            Spacer()
        }
        .padding(.defaultPadding)
        .actionSheet(isPresented: $deleteVM.showDeleteSuccess) {
            ActionSheet(
                title: Text("delete_success"),
                message: Text("account_delete"),
                buttons: [
                    .default(Text("Ok"), action: {
                        navigationController?.popViewController(animated: true)
                    })
                ]
            )
        }
        .alertHttpError(isPresented: $deleteVM.isPresented, error: deleteVM.error)
    }
}
