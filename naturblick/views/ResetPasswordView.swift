//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

enum ResetPasswordAction {
    case Reset
    case Login
    case Account
}

struct ResetPasswordView: View {
    
    let token: String?
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var resetPasswordVM = ResetPasswordViewModel()
    @State private var action: ResetPasswordAction = .Reset
    
    var body: some View {
        BaseView {
            SwiftUI.Group {
                if action == .Reset {
                    VStack {
                        NBEditText(label: "Password", icon: Image(systemName: "eye"), text: $resetPasswordVM.password, isSecure: true, prompt: resetPasswordVM.passwordPrompt).padding()
                        if resetPasswordVM.passwordPrompt == nil {
                            Text("The password must be at least 9 characters long. It must consist of numbers, upper and lower case letters.")
                                .tint(Color.onSecondaryButtonPrimary)
                                .font(.nbCaption)
                                .padding([.leading, .trailing])
                        }
                        
                        if let token = token {
                            Button("Reset password") {
                                resetPasswordVM.resetPassword(token: token)
                            }.foregroundColor(.black)
                                .buttonStyle(.bordered)
                        }
                        
                        Spacer()
                    }
                } else if action == .Login {
                    LoginView().onDisappear {
                        action = .Account
                    }
                } else if action == .Account {
                    AccountView()
                }
            }
        }
        .actionSheet(isPresented: $resetPasswordVM.showResetSuccess) {
            ActionSheet(
                title: Text("Reset password"),
                message: Text("Password reset was successful."),
                buttons:
                    [
                        .default(Text("Ok"), action: {
                            dismiss()
                        })
                    ]
            )
        }
        .alertHttpError(isPresented: $resetPasswordVM.isPresented, error: resetPasswordVM.error)
    }
}

