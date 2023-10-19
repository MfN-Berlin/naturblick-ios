//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

class ResetPasswordViewViewController: HostingController<ResetPasswordView> {
    
    let resetVM: ResetPasswordViewModel
    let token: String
    
    init(token: String) {
        self.token = token
        self.resetVM = ResetPasswordViewModel(token: self.token)
        super.init(rootView: ResetPasswordView(resetVM: self.resetVM))
    }
}

struct ResetPasswordView: HostedView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    var viewName: String? = String(localized: "reset")
    
    @ObservedObject var resetVM: ResetPasswordViewModel

    func configureNavigationItem(item: UINavigationItem) {
        item.leftBarButtonItem = UIBarButtonItem(primaryAction: UIAction(title: String(localized: "cancel")) {_ in
            navigationController?.dismiss(animated: true)
        })
        
        item.rightBarButtonItem = UIBarButtonItem(primaryAction: UIAction(title: String(localized: "reset_password")) {_ in
            resetVM.resetPassword()
        })
    }
    
    var body: some View {
        VStack {
            HStack {
                Image("visibility").foregroundColor(.onSecondaryMediumEmphasis)
                SecureField(
                    "password",
                    text: $resetVM.password,
                    prompt: Text("password")
                )
                .autocorrectionDisabled(true)
                .autocapitalization(.none)
            }
            if let passwordHint = resetVM.passwordHint {
                Text(passwordHint)
                    .caption()
            } else if resetVM.passwordHint == nil {
                Text("password_format")
                    .caption()
            }
            
            Spacer()
        }
        .foregroundColor(.onSecondaryHighEmphasis)
        .actionSheet(isPresented: $resetVM.showResetSuccess) {
            ActionSheet(
                title: Text("reset_password"),
                message: Text("password_reset_successful"),
                buttons:
                    [
                        .default(Text("Ok"), action: {
                            withNavigation { navigation in
                                var viewControllers = navigation.viewControllers
                                viewControllers[viewControllers.count - 1] = AccountView().setUpViewController()
                                navigation.setViewControllers(viewControllers, animated: true)
                            }
                            
                        })
                    ]
            )
        }
        .alertHttpError(isPresented: $resetVM.isPresented, error: resetVM.error)
        .padding(.defaultPadding)
    }
}
