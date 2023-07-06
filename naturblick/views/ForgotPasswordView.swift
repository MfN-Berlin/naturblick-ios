//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct ForgotPasswordView: View {
    
    @ObservedObject private var forgotPasswordVM = ForgotPasswordViewModel()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        BaseView {
            VStack {
                NBEditText(label: "Email address", icon: Image(systemName: "mail"), text: $forgotPasswordVM.email, prompt: forgotPasswordVM.emailPrompt).padding()
               
                Button("Reset password") {
                    forgotPasswordVM.resetPassword()
                }.foregroundColor(.black)
                    .buttonStyle(.bordered)
                Text("**Note**\n\nWhen you set a new password, all phones linked to the account will be automatically logged out for security reasons. All your observations will remain linked to your account.")
                    .tint(Color.onSecondaryButtonPrimary)
                    .font(.nbBody1)
                    .padding()
                Spacer()
            }
        }.actionSheet(isPresented: $forgotPasswordVM.showSendInfo) {
            ActionSheet(
                title: Text("New password"),
                message: Text("We have sent a password reset link to the email address you provided. The link is valid for 12 hours. If you do not receive an email after 10 minutes, the email address you provided is not associated with an existing account."),
                buttons: [
                    .default(Text("Open my emails"), action: {
                        //TODO johannes hier zum EMail Client
                    }),
                    .destructive(Text("Go back to login"), action: {
                        dismiss()
                    })
                ]
            )
        }.alertHttpError(isPresented: $forgotPasswordVM.isPresented, error: forgotPasswordVM.error)
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}
