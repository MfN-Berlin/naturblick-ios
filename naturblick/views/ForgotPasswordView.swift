//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

struct ForgotPasswordView: NavigatableView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    var viewName: String? = "Forgot"
    
    @ObservedObject var accountViewModel: AccountViewModel
       
    @StateObject private var forgotPasswordVM = EmailAndPasswordWithPrompt()
    @State var action: String?
    
    @State var error: HttpError? = nil
    @State var showSendInfo: Bool = false
    @State var isPresented: Bool = false
    
    @Environment(\.dismiss) var dismiss
    
    func forgotPassword() {
        let client = BackendClient()
        Task {
            do {
                try await client.forgotPassword(email: forgotPasswordVM.email)
                showSendInfo = true
            } catch is HttpError {
                self.error = error
                self.isPresented = true
            } catch {
                preconditionFailure(error.localizedDescription)
            }
        }
    }
    
    var body: some View {
        VStack {
            NBEditText(label: "Email address", icon: Image(systemName: "mail"), text: $forgotPasswordVM.email, prompt: forgotPasswordVM.emailPrompt)
                .padding()
                .keyboardType(.emailAddress)
           
            Button("Reset password") {
                forgotPassword()
            }.buttonStyle(ConfirmButton())
            Text("**Note**\n\nWhen you set a new password, all phones linked to the account will be automatically logged out for security reasons. All your observations will remain linked to your account.")
                .tint(Color.onSecondaryButtonPrimary)
                .font(.nbBody1)
                .padding()
            Spacer()
        }
        .foregroundColor(.onSecondaryHighEmphasis)
        .actionSheet(isPresented: $showSendInfo) {
            ActionSheet(
                title: Text("New password"),
                message: Text("We have sent a password reset link to the email address you provided. The link is valid for 12 hours. If you do not receive an email after 10 minutes, the email address you provided is not associated with an existing account."),
                buttons: forgotSuccessButtons()
            )
        }.alertHttpError(isPresented: $isPresented, error: error)
            .onAppear {
                if let email = accountViewModel.email {
                    forgotPasswordVM.email = email
                }
            }
    }
    
    func forgotSuccessButtons() -> [Alert.Button] {
        var buttons: [Alert.Button] = [Alert.Button.destructive(Text("Go back to login"), action: {
            dismiss()
        })]
       
        if (canOpenEmail()) {
            buttons.append(
                Alert.Button.default(Text("Open my emails"), action: { openMail(completionHandler: { _ in dismiss() }) })
            )
        }
        return buttons
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView(accountViewModel: AccountViewModel())
    }
}
