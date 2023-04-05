//
// Copyright © 2023 Museum für Naturkunde Berlin.
// All Rights Reserved.


import SwiftUI

struct CharacterValueView: View {
    let value: CharacterValue
    let selected: Bool
    var body: some View {
        let stack = VStack {
            if(value.hasImage) {
                Image("character_\(value.id)")
            } else {
                Spacer()
            }
            Text(value.gername)
                .font(.nbCaption)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, .defaultPadding)
                .padding(.bottom, .defaultPadding)
            if(value.hasImage) {
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .background(Color.nbPrimary)
        .cornerRadius(.smallCornerRadius)
        .shadow(color: Color.black.opacity(0.2), radius: .smallCornerRadius, x: 0, y: 0)
        
        if(selected) {
            stack
                .border(Color.primary)
                .overlay(alignment: .topTrailing) {
                    Image("check_circle_24")
                        .resizable()
                        .scaledToFit()
                        .frame(width: .checkedSize, height: .checkedSize)
                        .foregroundColor(.nbPrimary)
                        .padding(.halfPadding)
                }
        } else {
            stack
        }
    }
}

struct CharacterValueView_Previews: PreviewProvider {
    static var previews: some View {
        CharacterValueView(value: CharacterValue.sampleData[2], selected: true)
    }
}
