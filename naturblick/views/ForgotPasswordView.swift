//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct ForgotPasswordView: View {
    
    @ObservedObject private var forgotPasswordVM = ForgotPasswordViewModel()
    @State var action: String?
    
    var body: some View {
        BaseView {
            VStack {
                
                NavigationLink(destination: LoginView(), tag: AccountView.loginAction, selection: $action) {
                    EmptyView()
                }
                NBEditText(label: "Email address", icon: Image(systemName: "mail"), text: $forgotPasswordVM.email, prompt: forgotPasswordVM.emailPrompt)
                    .padding()
                    .keyboardType(.emailAddress)
               
                Button("Reset password") {
                    forgotPasswordVM.forgotPassword()
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
                buttons: forgotSuccessButtons()
            )
        }.alertHttpError(isPresented: $forgotPasswordVM.isPresented, error: forgotPasswordVM.error)
    }
    
    func forgotSuccessButtons() -> [Alert.Button] {
        var buttons: [Alert.Button] = [Alert.Button.destructive(Text("Go back to login"), action: {
            action = AccountView.loginAction
        })]
       
        if (canOpenEmail()) {
            buttons.append(
                Alert.Button.default(Text("Open my emails"), action: { openMail(completionHandler: { _ in action = AccountView.loginAction }) })
            )
        }
        return buttons
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}
