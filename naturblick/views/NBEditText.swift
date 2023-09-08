//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct NBEditText: View {
    let label: String
    let icon: Image
    @Binding var text: String
    private(set) var isSecure: Bool = false
    private(set) var prompt: String? = nil
    
    var body: some View {
        VStack {
            HStack {
                icon
                    .resizable()
                    .frame(width: .editTextIconSize, height: .editTextIconSize)
                if (isSecure) {
                    SecureField(label, text: $text)
                        .autocorrectionDisabled(true)
                        .autocapitalization(.none)
                } else {
                    TextField(label, text: $text)
                        .autocorrectionDisabled(true)
                        .autocapitalization(.none)
                }
            }
            if let prompt = prompt {
                Text(prompt)
                    .font(.nbCaption)
            }
        }.foregroundColor(.onPrimaryHighEmphasis)
    }
}

struct NBEditText_Previews: PreviewProvider {
    static var previews: some View {
        NBEditText(label: "Test", icon: Image("details"), text: .constant("entered text"), prompt: "blabla")
    }
}
