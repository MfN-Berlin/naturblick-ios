//
// Copyright © 2023 Museum für Naturkunde Berlin.
// All Rights Reserved.


import SwiftUI

struct CharacterView: View {
    let character: Character
    let values: [CharacterValue]
    @Binding var selected: Set<Int64>
    let onToggle: (Int64) -> ()

    var body: some View {
        VStack(alignment: .leading) {
            Text(character.gername)
                .font(.nbSubtitle1)
                .padding(.bottom, .defaultPadding)
            if let description = character.gerdescription {
                Text(description)
                    .font(.nbBody1)
                    .padding(.bottom, .defaultPadding)
            }
            LazyVGrid(columns: [
                GridItem(spacing: .defaultPadding),
                GridItem(spacing: .defaultPadding),
                GridItem(spacing: .defaultPadding)
            ], spacing: .defaultPadding) {
                ForEach(values) { value in
                    CharacterValueView(value: value, selected: selected.contains(value.id))
                        .onTapGesture {
                            onToggle(value.id)
                        }
                }
            }
        }.padding(.defaultPadding)
    }
}

struct CharacterView_Previews: PreviewProvider {
    static var previews: some View {
        CharacterView(
            character: Character.sampleData,
            values: CharacterValue.sampleData,
            selected: .constant([1]),
            onToggle: {_ in}
        )
    }
}
