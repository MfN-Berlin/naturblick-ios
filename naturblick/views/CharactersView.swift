//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import BottomSheet

struct CharactersView: NavigatableView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    var title: String? 
    
    let group: Group
    
    init(group: Group) {
        self.title = group.gerName
        self.group = group
    }
    
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
            .accentColor(Color.onPrimaryButtonPrimary)
            .buttonStyle(.borderedProminent)
            .padding(.defaultPadding)
            .padding(.bottom, .defaultPadding * 2)
            .disabled(charactersViewModel.selected.isEmpty)
        }
    }
}

struct CharactersView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CharactersView(group: Group.groups[0])
        }
    }
}
