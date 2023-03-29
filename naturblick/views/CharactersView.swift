//
// Copyright © 2023 Museum für Naturkunde Berlin.
// All Rights Reserved.


import SwiftUI

struct CharactersView: View {
    let group: Group
    @StateObject private var charactersViewModel = CharactersViewModel()
    @State private var selected: Set<Int64> = []
    var body: some View {
        ScrollView {
            VStack {
                ForEach(charactersViewModel.characters, id: \.0.id) { character, values in
                    CharacterView(character: character, values: values, selected: $selected) { id in

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
                    if character.id != charactersViewModel.characters.last?.0.id {
                        Divider()
                    }
                }
            }
        }
        .task {
            charactersViewModel.filter(group: group)
        }
    }
}

struct CharactersView_Previews: PreviewProvider {
    static var previews: some View {
        CharactersView(group: Group.groups[0])
    }
}
