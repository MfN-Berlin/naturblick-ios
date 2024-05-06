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

    var rows: Int {
        values.count / 3 + (values.count % 3) > 0 ? 1 : 0
    }
    func value(row: Int, col: Int) -> CharacterValue? {
        if row * 3 + col < values.count {
            return values[row * 3 + col]
        } else {
            return nil
        }
    }
    var body: some View {
        VStack(alignment: .leading, spacing: .defaultPadding) {
            Text(character.name)
                .subtitle1()
            if let description = character.description {
                Text(description)
                    .body2()
            }
            VStack {
                ForEach(0 ..< rows, id: \.self) { row in
                    HStack {
                        ForEach(0 ..< 3, id: \.self) { col in
                            if let value = value(row: row, col: col) {
                                CharacterValueView(value: value, selected: selected.contains(value.id))
                                    .onTapGesture {
                                        toggleSelection(id: value.id)
                                    }
                            } else {
                                Text("").frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
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
