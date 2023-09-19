//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import BottomSheet

struct CharactersView: NavigatableView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    var viewName: String? {
        group.gerName
    }
    
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
            Button("\(charactersViewModel.count) Ergebnissse anzeigen") {
                navigationController?.pushViewController(SpeciesListView(filter: charactersViewModel.filter).setUpViewController(), animated: true)
            }
            .accentColor(Color.onPrimaryButtonPrimary)
            .buttonStyle(.borderedProminent)
            .padding(.defaultPadding)
            .padding(.bottom, .defaultPadding * 2)
            .disabled(charactersViewModel.selected.isEmpty)
        }
        .customBackground(
            RoundedRectangle(cornerRadius: .largeCornerRadius)
                .fill(Color.secondaryColor)
                .nbShadow()
        )
    }
}

struct CharactersView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CharactersView(group: Group.groups[0])
        }
    }
}
