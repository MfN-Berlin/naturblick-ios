//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

class ForgotPasswordViewController: HostingController<ForgotPasswordView> {
    
    var accountViewModel: AccountViewModel
    let forgotPasswordVM: ForgotPasswordViewModel
    
    init(accountViewModel: AccountViewModel) {
        self.accountViewModel = accountViewModel
        self.forgotPasswordVM = ForgotPasswordViewModel(accountViewModel: accountViewModel)
        super.init(rootView: ForgotPasswordView(accountViewModel: self.accountViewModel, forgotPasswordVM: self.forgotPasswordVM))
    }
}

struct ForgotPasswordView: HostedView {

    var holder: ViewControllerHolder = ViewControllerHolder()
    var viewName: String? = String(localized: "forgot")
    
    @ObservedObject var accountViewModel: AccountViewModel
    @ObservedObject var forgotPasswordVM: ForgotPasswordViewModel
    
    @State var action: String?
    
    func configureNavigationItem(item: UINavigationItem) {
        item.leftBarButtonItem = UIBarButtonItem(primaryAction: UIAction(title: String(localized: "cancel")) {_ in
            navigationController?.dismiss(animated: true)
        })
        
        item.rightBarButtonItem = UIBarButtonItem(primaryAction: UIAction(title: String(localized: "reset_password")) {_ in
            forgotPasswordVM.forgotPassword()
        })
    }
    
    var body: some View {
        VStack {
            HStack {
                Image("create_24px").foregroundColor(.onSecondaryMediumEmphasis)
                TextField("email",
                    text: $forgotPasswordVM.email,
                    prompt: Text("email")
                )
                .keyboardType(.emailAddress)
                .autocorrectionDisabled(true)
                .autocapitalization(.none)
                    
            }
            if let emailHint = forgotPasswordVM.emailHint {
                Text(emailHint)
                    .caption()
            }
           
            Text("delete_account_note_password")
                .body1()
            Spacer()
        }
        .foregroundColor(.onSecondaryHighEmphasis)
        .actionSheet(isPresented: $forgotPasswordVM.showSendInfo) {
            ActionSheet(
                title: Text("reset_email_sent_title"),
                message: Text("reset_email_sent_message"),
                buttons: forgotSuccessButtons()
            )
        }
        .alertHttpError(isPresented: $forgotPasswordVM.isPresented, error: forgotPasswordVM.error)
        .onAppear {
            if let email = accountViewModel.email {
                forgotPasswordVM.email = email
            }
        }
        .padding(.defaultPadding)
    }
    
    func forgotSuccessButtons() -> [Alert.Button] {
        var buttons: [Alert.Button] = [Alert.Button.destructive(Text("go_back_to_login_screen"), action: {
            navigationController?.dismiss(animated: true)
        })]
       
        if (canOpenEmail()) {
            buttons.append(
                Alert.Button.default(Text("open_default_email_app"), action: { openMail(completionHandler: { _ in navigationController?.popViewController(animated: true) }) })
            )
        }
        return buttons
    }
}
