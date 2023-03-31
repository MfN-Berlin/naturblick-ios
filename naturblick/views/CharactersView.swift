//
// Copyright © 2023 Museum für Naturkunde Berlin.
// All Rights Reserved.


import SwiftUI
import BottomSheet

struct CharactersView: View {
    let group: Group
    @StateObject private var charactersViewModel = CharactersViewModel()

    var body: some View {
        ScrollView {
            VStack {
                ForEach(charactersViewModel.characters, id: \.0.id) { character, values in
                    CharacterView(character: character, values: values, selected: $charactersViewModel.selected)
                    if character.id != charactersViewModel.characters.last?.0.id {
                        Divider()
                    }
                }
            }
        }
        .task {
            charactersViewModel.configure(group: group)
        }
        .bottomSheet(bottomSheetPosition: $charactersViewModel.bottomSheetPosition, switchablePositions: [.dynamicBottom, .dynamic]) {
            NavigationLink(destination: SpeciesListView(filter: charactersViewModel.filter)) {
                Text("\(charactersViewModel.count) Ergebnissse anzeigen")
            }
            .buttonStyle(.borderedProminent)
            .padding(.defaultPadding)
            .padding(.bottom, .defaultPadding * 2)
            .disabled(charactersViewModel.selected.isEmpty)
        }
        .navigationTitle(group.gerName)
    }
}

struct CharactersView_Previews: PreviewProvider {
    static var previews: some View {
        CharactersView(group: Group.groups[0])
    }
}
