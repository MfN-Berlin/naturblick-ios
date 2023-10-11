//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

struct ResetPasswordView: NavigatableView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    var viewName: String? = "Reset"
    
    let token: String
    
    @AppSecureStorage(NbAppSecureStorageKey.BearerToken) var bearerToken: String?
    
    @StateObject private var resetPasswordVM = EmailAndPasswordWithPrompt()
    
    @State var showResetSuccess: Bool = false
    @State var isPresented: Bool = false
    @State var error: HttpError? = nil
    
    func resetPassword(token: String) {
        let client = BackendClient()
        Task {
            do {
                try await client.resetPassword(token: token, password: resetPasswordVM.password)
                bearerToken = nil
                showResetSuccess = true
            }
            catch is HttpError {
                self.error = error
                isPresented = true
            } catch {
                preconditionFailure(error.localizedDescription)
            }
        }
    }
    
    var body: some View {
        VStack {
            NBEditText(label: "Password", icon: Image(systemName: "eye"), text: $resetPasswordVM.password, isSecure: true, prompt: resetPasswordVM.passwordPrompt).padding()
            if resetPasswordVM.passwordPrompt == nil {
                Text("The password must be at least 9 characters long. It must consist of numbers, upper and lower case letters.")
                    .tint(Color.onSecondaryButtonPrimary)
                    .font(.nbCaption)
                    .padding([.leading, .trailing])
            }
            
            Button("Reset password") {
                resetPassword(token: token)
            }.buttonStyle(ConfirmButton())
    
            Spacer()
        }
        .foregroundColor(.onSecondaryHighEmphasis)
        .actionSheet(isPresented: $showResetSuccess) {
            ActionSheet(
                title: Text("Reset password"),
                message: Text("Password reset was successful."),
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
        .alertHttpError(isPresented: $isPresented, error: error)
    }
}
