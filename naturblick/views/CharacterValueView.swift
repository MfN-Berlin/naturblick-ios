//
// Copyright © 2023 Museum für Naturkunde Berlin.
// All Rights Reserved.


import SwiftUI

struct CharacterValueView: View {
    let value: CharacterValue
    var body: some View {
        VStack {
            if(value.hasImage) {
                Image("character_\(value.id)")
            } else {
                Spacer()
            }
            Text(value.gername)
                .font(.nbCaption)
                .multilineTextAlignment(.center)
                .padding(.horizontal, .defaultPadding)
                .padding(.bottom, .defaultPadding)
            if(value.hasImage) {
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .background(Color.white)
        .cornerRadius(.smallCornerRadius)
        .shadow(color: Color.black.opacity(0.2), radius: .smallCornerRadius, x: 0, y: 0)
    }
}

struct CharacterValueView_Previews: PreviewProvider {
    static var previews: some View {
        CharacterValueView(value: CharacterValue.sampleData[2])
    }
}
