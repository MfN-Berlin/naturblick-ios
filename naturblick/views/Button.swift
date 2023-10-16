//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct Button: View {
    let text: String
    let icon: String?
    let action: () -> Void
    let role: ButtonRole?
    init(_ text: String, icon: String? = nil, role: ButtonRole? = nil, action: @escaping () -> Void) {
        self.text = text
        self.icon = icon
        self.role = role
        self.action = action
    }
    
    var body: some View {
        if let icon = icon {
            SwiftUI.Button(role: role, action: {
                action()
            }) {
                Label(title: {
                    Text(LocalizedStringKey(text))
                        .button()
                }) {
                    Image(icon)
                }
            }
        } else {
            SwiftUI.Button(role: role, action: {
                action()
            }) {
                Text(LocalizedStringKey(text))
                    .button()
            }
        }
    }
}

struct Button_Previews: PreviewProvider {
    static var previews: some View {
        Button("Test") {
            print("Klicked")
        }
    }
}
