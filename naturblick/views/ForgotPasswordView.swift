//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

struct ForgotPasswordView: NavigatableView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    var viewName: String? = String(localized: "forgot")
    
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
            NBEditText(label: String(localized: "email"), icon: Image("create_24px"), text: $forgotPasswordVM.email, prompt: forgotPasswordVM.emailPrompt)
                .keyboardType(.emailAddress)
           
            Button("reset_password") {
                forgotPassword()
            }.buttonStyle(ConfirmFullWidthButton())
                .padding([.top, .bottom], .defaultPadding)
            Text("delete_account_note_password")
                .body1()
            Spacer()
        }
        .foregroundColor(.onSecondaryHighEmphasis)
        .actionSheet(isPresented: $showSendInfo) {
            ActionSheet(
                title: Text("reset_email_sent_title"),
                message: Text("reset_email_sent_message"),
                buttons: forgotSuccessButtons()
            )
        }.alertHttpError(isPresented: $isPresented, error: error)
        .onAppear {
            if let email = accountViewModel.email {
                forgotPasswordVM.email = email
            }
        }
        .padding(.defaultPadding)
    }
    
    func forgotSuccessButtons() -> [Alert.Button] {
        var buttons: [Alert.Button] = [Alert.Button.destructive(Text("go_back_to_login_screen"), action: {
            dismiss()
        })]
       
        if (canOpenEmail()) {
            buttons.append(
                Alert.Button.default(Text("open_default_email_app"), action: { openMail(completionHandler: { _ in dismiss() }) })
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
