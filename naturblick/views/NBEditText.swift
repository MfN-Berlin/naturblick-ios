//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct NBEditText: View {
    let label: String
    let iconAsset: String
    @Binding var text: String
    var body: some View {
        HStack {
            Image(iconAsset)
                .resizable()
                .frame(width: .editTextIconSize, height: .editTextIconSize)
            TextField(label, text: $text)
        }
    }
}

struct NBEditText_Previews: PreviewProvider {
    static var previews: some View {
        NBEditText(label: "Test", iconAsset: "details", text: .constant("entered text"))
    }
}
