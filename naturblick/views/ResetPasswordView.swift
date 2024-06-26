//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

struct ResetPasswordView: NavigatableView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    var viewName: String? = String(localized: "reset")
    
    let token: String
        
    @StateObject private var resetPasswordVM = EmailAndPasswordWithPrompt()
    
    @State var showResetSuccess: Bool = false
    @State var isPresented: Bool = false
    @State var error: HttpError? = nil
    
    func resetPassword(token: String) {
        let client = BackendClient()
        Task {
            do {
                try await client.resetPassword(token: token, password: resetPasswordVM.password)
                Keychain.shared.deleteToken()
                showResetSuccess = true
            }
            catch is HttpError {
                self.error = error
                isPresented = true
            } catch {
                Fail.with(error)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: .defaultPadding) {
            HStack {
                Image(decorative: "visibility")
                    .observationProperty()
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: .zero) {
                    Text("password")
                        .caption(color: .onSecondarySignalLow)
                    SecureField(String(localized: "password"), text: $resetPasswordVM.password)
                        .textContentType(.newPassword)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                }
            }
    
            if let prompt = resetPasswordVM.passwordPrompt {
                Text(prompt)
                    .caption()
            } else if resetPasswordVM.passwordPrompt == nil {
                Text("password_format")
                    .caption()
            }
            
            Button("reset_password") {
                resetPassword(token: token)
            }.buttonStyle(ConfirmFullWidthButton())
                .padding([.top], .defaultPadding)
    
            Spacer()
        }
        .foregroundColor(.onSecondaryHighEmphasis)
        .alert("reset_password", isPresented: $showResetSuccess) {
            Button("ok") {
                withNavigation { navigation in
                    var viewControllers = navigation.viewControllers
                    viewControllers[viewControllers.count - 1] = AccountView().setUpViewController()
                    navigation.setViewControllers(viewControllers, animated: true)
                }
            }
        } message: {
            Text("password_reset_successful")
        }
        .alertHttpError(isPresented: $isPresented, error: error)
        .padding(.defaultPadding)
    }
}
