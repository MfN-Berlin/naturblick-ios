//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct CharacterView: View {
    let character: Character
    let values: [CharacterValue]
    @Binding var selected: Set<Int64>

    private func toggleSelection(id: Int64) {
        var updated = selected

        if(character.single) {
            for value in values.filter({$0.id != id}) {
                updated.remove(value.id)
            }
        }

        if updated.contains(id) {
            updated.remove(id)
        } else {
            updated.insert(id)
        }

        selected = updated
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(character.gername)
                .subtitle1()
                .padding(.bottom, .defaultPadding)
            if let description = character.gerdescription {
                Text(description)
                    .body2()
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
                            toggleSelection(id: value.id)
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
            selected: .constant([1])
        )
    }
}
