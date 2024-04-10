//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct CharacterValueView: View {
    let value: CharacterValue
    let selected: Bool
    var body: some View {

        let stack = VStack(spacing: .zero) {
            if(value.hasImage) {
                Image("character_\(value.id)")
            } else {
                Spacer()
            }
            Text(value.name)
                .caption()
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, .defaultPadding)
                .padding(.bottom, .defaultPadding)
            if(value.hasImage) {
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(.white)
        
        if(selected) {
            stack
                .border(Color.onSecondaryButtonSecondary)
                .cornerRadius(.smallCornerRadius)
                .shadow(color: Color.black.opacity(0.2), radius: .smallCornerRadius, x: 0, y: 0)
                .overlay(alignment: .topTrailing) {
                    Image("check_circle_24")
                        .resizable()
                        .scaledToFit()
                        .frame(width: .checkedSize, height: .checkedSize)
                        .foregroundColor(.onSecondaryButtonSecondary)
                        .padding(.halfPadding)
                }
        } else {
            stack
                .cornerRadius(.smallCornerRadius)
                .shadow(color: Color.black.opacity(0.2), radius: .smallCornerRadius, x: 0, y: 0)
        }
    }
}

struct CharacterValueView_Previews: PreviewProvider {
    static var previews: some View {
        CharacterValueView(value: CharacterValue.sampleData[2], selected: true)
    }
}
