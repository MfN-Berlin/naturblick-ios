//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import Combine

class CharactersViewController: HostingController<CharactersView> {
    let model: CharactersViewModel
    let flow: CreateFlowViewModel
    private var subscriptions = Set<AnyCancellable>()
    var count: Int64 = 0 {
        didSet {
            if count > 0 {
                let countStr = "\(count)"
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: String(localized: "show_results \(countStr)"), style: .done, target: self, action: #selector(CharactersViewController.showResults))
            } else {
                navigationItem.rightBarButtonItem = nil
            }
        }
    }
    
    @objc func showResults() {
        AnalyticsTracker.trackSpeciesSelection(filter: model.filter)
        navigationController?.pushViewController(
            SpeciesListView(filter: model.filter, flow: flow, isCharacterResult: true).setUpViewController(), animated: true)
    }
    
    init(group: Group, flow: CreateFlowViewModel) {
        self.model = CharactersViewModel()
        self.flow = flow
        super.init(rootView: CharactersView(group: group, charactersViewModel: model))
        model.$count.assign(to: \.count, on: self).store(in: &subscriptions)
    }
}

struct CharactersView: HostedView {

    var holder: ViewControllerHolder = ViewControllerHolder()
    var viewName: String? {
        isGerman() ? group.gerName : group.engName
    }
    
    let group: Group
    @ObservedObject var charactersViewModel: CharactersViewModel
    
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
            }
            .task {
                charactersViewModel.configure(group: group)
            }
        }
    }
}

struct CharactersView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CharactersView(group: Group.groups[0], charactersViewModel: CharactersViewModel())
        }
    }
}
