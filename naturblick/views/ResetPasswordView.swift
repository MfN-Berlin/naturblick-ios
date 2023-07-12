//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct ResetPasswordView: View {
    
    let token: String = "TODO"
    
    @ObservedObject private var resetPasswordVM = ResetPasswordViewModel()
    @State var action: String?
    
    var body: some View {
        BaseView {
            VStack {
                NavigationLink(destination: LoginView(), tag: AccountView.loginAction, selection: $action) {
                    EmptyView()
                }
                NBEditText(label: "Password", icon: Image(systemName: "eye"), text: $resetPasswordVM.password, isSecure: true, prompt: resetPasswordVM.passwordPrompt).padding()
                if resetPasswordVM.passwordPrompt == nil {
                    Text("The password must be at least 9 characters long. It must consist of numbers, upper and lower case letters.")
                        .tint(Color.onSecondaryButtonPrimary)
                        .font(.nbCaption)
                        .padding([.leading, .trailing])
                }
                
                Button("Reset password") {
                    resetPasswordVM.resetPassword(token: token)
                }.foregroundColor(.black)
                    .buttonStyle(.bordered)
                
                Spacer()
            }
        }
        .actionSheet(isPresented: $resetPasswordVM.showResetSuccess) {
            ActionSheet(
                title: Text("Reset password"),
                message: Text("Password reset was successful."),
                buttons:
                    [
                        .default(Text("Ok"), action: {
                            action = AccountView.loginAction
                        })
                    ]
            )
        }
        .alertHttpError(isPresented: $resetPasswordVM.isPresented, error: resetPasswordVM.error)
    }
}

