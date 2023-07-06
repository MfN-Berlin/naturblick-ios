//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct DeleteAccountView: View {
    
    @ObservedObject var deleteVM = DeleteAccountViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        BaseView {
            VStack {
                Text("**Do you really want to delete your account?**\n\nDeleting your account will unlink all other devices. You will lose the connection to observations on these devices.\n\nPlease, confirm your wish to delete the account by entering your login details.")
                    .tint(Color.onSecondaryButtonPrimary)
                    .font(.nbBody1)
                    .padding()
                NBEditText(label: "Email address", icon: Image(systemName: "mail"), text: $deleteVM.email, prompt: deleteVM.emailPrompt).padding()
                NBEditText(label: "Password", icon: Image(systemName: "eye"), text: $deleteVM.password, isSecure: true, prompt: deleteVM.passwordPrompt).padding()
                if deleteVM.showCredentialsError {
                    Text("Credentials not recognized. Please validate your e-mail and password.")
                        .foregroundColor(.onSecondarywarning)
                        .font(.nbBody1)
                        .padding()
                }
                Button("Delete account") {
                    deleteVM.deleteAccount()
                }.buttonStyle(.bordered)
                    .background(Color.onPrimaryButtonSecondary)
                    .foregroundColor(.onPrimaryHighEmphasis)
                    .cornerRadius(4)
          
                AccountButton(text: "Forgot Password", destination: ForgotPasswordView())
                Spacer()
            }
        }.actionSheet(isPresented: $deleteVM.showDeleteSuccess) {
            ActionSheet(
                title: Text("Success!"),
                message: Text("Your account was deleted."),
                buttons: [
                    .default(Text("Ok"), action: {
                        dismiss()
                    })
                ]
            )
        }.alertHttpError(isPresented: $deleteVM.isPresented, error: deleteVM.error)
    }
}

struct DeleteAccountView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteAccountView()
    }
}
