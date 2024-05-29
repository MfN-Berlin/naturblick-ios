//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

struct ForgotPasswordView: NavigatableView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    var viewName: String? = String(localized: "forgot")
    
    @ObservedObject var accountViewModel: AccountViewModel
    @ObservedObject var keychain = Keychain.shared
    @StateObject private var forgotPasswordVM = EmailAndPasswordWithPrompt()
    @State var action: String?
    
    @State var error: HttpError? = nil
    @State var showSendInfo: Bool = false
    @State var isPresented: Bool = false
    
    @Environment(\.dismiss) var dismiss
    
    func forgotPassword() {
        Task {
            do {
                try await accountViewModel.forgotPassword(email: forgotPasswordVM.email)
                showSendInfo = true
            } catch is HttpError {
                self.error = error
                self.isPresented = true
            } catch {
                Fail.with(error)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: .zero) {
            OnSecondaryFieldView(icon: "create_24px") {
                TextField(String(localized: "email"), text: $forgotPasswordVM.email)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled(true)
                    .autocapitalization(.none)
            }
            if let prompt = forgotPasswordVM.emailPrompt {
                Text(prompt)
                    .caption()
            }
           
            Button("reset_password") {
                forgotPassword()
            }
            .buttonStyle(ConfirmFullWidthButton())
            .padding([.top])
            Text("delete_account_note_password")
                .body1()
                .padding([.top])
            Spacer()
        }
        .padding(.defaultPadding)
        .foregroundColor(.onSecondaryHighEmphasis)
        .alert("reset_email_sent_title", isPresented: $showSendInfo) {
            Button("go_back_to_login_screen") {
                dismiss()
            }
            if (canOpenEmail()) {
                Button("open_default_email_app", role: .none) {
                    openMail(completionHandler: { _ in dismiss() })
                }
            }
        } message: {
            Text("reset_email_sent_message")
        }
        .alertHttpError(isPresented: $isPresented, error: error)
        .onAppear {
            if let email = keychain.email {
                forgotPasswordVM.email = email
            }
        }
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView(accountViewModel: AccountViewModel())
    }
}
