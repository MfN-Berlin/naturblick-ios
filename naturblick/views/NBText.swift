//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct NBText: View {
    let label: String
    let icon: Image
    let text: String
    private(set) var prompt: String?
    
    var body: some View {
        VStack {
            HStack {
                Label {
                    Text(label)
                } icon: {icon
                    .resizable()
                    .frame(width: .editTextIconSize, height: .editTextIconSize)
                }
                Text(text)
            }
            if let prompt = prompt {
                Text(prompt)
                    .font(.nbCaption)
            }
        }
    }
}

struct NBText_Previews: PreviewProvider {
    static var previews: some View {
        NBText(label: "Test", icon: Image("details"), text: "entered text", prompt: "blabla")
    }
}
