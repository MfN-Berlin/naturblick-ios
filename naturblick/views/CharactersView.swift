//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import BottomSheet

struct CharactersView: NavigatableView {

    var holder: ViewControllerHolder = ViewControllerHolder()
    var viewName: String? {
        isGerman() ? group.gerName : group.engName
    }
    
    let group: Group
    @ObservedObject var flow: CreateFlowViewModel
    
    @StateObject private var charactersViewModel = CharactersViewModel()
    
    private var charactersViewModelCountStr: String {
        "\(charactersViewModel.count)"
    }
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack {
                    ForEach(charactersViewModel.characters, id: \.0.id) { character, values in
                        CharacterView(character: character, values: values, selected: $charactersViewModel.selected)
                        if character.id != charactersViewModel.characters.last?.0.id {
                            Divider()
                        }
                    }
                }
                .padding(.bottom, geo.safeAreaInsets.bottom + .defaultPadding + .doublePadding)
            }
            .task {
                charactersViewModel.configure(group: group)
            }
            .bottomSheet(bottomSheetPosition: $charactersViewModel.bottomSheetPosition, switchablePositions: [.dynamicBottom, .dynamic]) {
                Button(String(localized: "show_results \(charactersViewModelCountStr)")) {
                    AnalyticsTracker.trackSpeciesSelection(filter: charactersViewModel.filter)
                    navigationController?.pushViewController(
                        SpeciesListView(filter: charactersViewModel.filter, flow: flow, isCharacterResult: true).setUpViewController(), animated: true)
                }
                .accentColor(Color.onPrimaryButtonPrimary)
                .buttonStyle(.borderedProminent)
                .padding(.horizontal, .defaultPadding)
                .padding(.bottom, geo.safeAreaInsets.bottom + .defaultPadding)
                .disabled(charactersViewModel.selected.isEmpty)
            }
            .customBackground(
                RoundedRectangle(cornerRadius: .largeCornerRadius)
                    .fill(Color.secondaryColor)
                    .nbShadow()
            )
        }
    }
}

struct CharactersView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CharactersView(group: Group.groups[0], flow: CreateFlowViewModel(persistenceController: ObservationPersistenceController(inMemory: true)))
        }
    }
}
