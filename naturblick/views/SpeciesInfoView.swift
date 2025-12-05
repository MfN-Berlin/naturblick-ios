//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)
import SwiftUI
import CachedAsyncImage

struct SpeciesInfoView<Flow>: NavigatableView where Flow: SelectionFlow {
    var holder: ViewControllerHolder = ViewControllerHolder()
    let backend: Backend
    let countView: Bool
    
    var viewName: String? {
        if let speciesName = species.speciesName {
            if let gender = species.gender {
                return "\(speciesName) \(gender)"
            } else {
                return speciesName
            }
        }
        return nil
    }
    let selectionFlow: Bool
    let species: SpeciesListItem
    @ObservedObject var flow: Flow
    
    func configureNavigationItem(item: UINavigationItem) {
        if navigationController?.viewControllers.first == viewController {
            item.leftBarButtonItem = UIBarButtonItem(primaryAction: UIAction(title: String(localized: "back")) {_ in
                viewController?.dismiss(animated: true)
            })
        }
        let share = UIBarButtonItem(primaryAction: UIAction(image: UIImage(systemName: "square.and.arrow.up", withConfiguration: UIImage.SymbolConfiguration(weight: .regular))) {action in
            let controller = UIActivityViewController(activityItems: [URL(string: "https://naturblick.museumfuernaturkunde.berlin/species/portrait/\(species.speciesId)")!], applicationActivities: nil)
            controller.popoverPresentationController?.barButtonItem = action.sender as? UIBarButtonItem
            viewController?.present(controller, animated: true)
        })
        if !(flow is VoidSelectionFlow) {
            if selectionFlow {
                item.rightBarButtonItem = UIBarButtonItem(primaryAction: UIAction(title: String(localized: "create_with_species")) {_ in
                    viewController?.dismiss(animated: true)
                    flow.selectSpecies(species: species)
                })
            } else {
                item.rightBarButtonItems = [share, UIBarButtonItem(primaryAction: UIAction(image: UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(weight: .regular))) {_ in
                    flow.selectSpecies(species: species)
                })]
            }
        } else {
            item.rightBarButtonItem = share
        }
    }
    
    func navigate(species: SpeciesListItem) {
        navigationController?.pushViewController(SpeciesInfoView(backend: backend, countView: countView, selectionFlow: selectionFlow, species: species, flow: flow).setUpViewController(), animated: true)
    }
    
    var body: some View {
        SwiftUI.Group {
            if species.hasPortrait {
                PortraitView(species: species, present: {view, completion in navigationController?.present(view, animated: true, completion: completion)}, similarSpeciesDestination: navigate)
            } else {
                PortraitMiniView(species: species) { view, completion in
                    navigationController?.present(view, animated: true, completion: completion)
                }
            }
        }.task {
            if (countView) {
                try! backend.persistence.addViewPortrait(speciesId: species.speciesId)
            }
        }
    }
}

struct SpeciesInfoView_Previews: PreviewProvider {
    static var previews: some View {
        SpeciesInfoView(backend: Backend(persistence: ObservationPersistenceController(inMemory: true)), countView: false, selectionFlow: false, species: .sampleData, flow: VoidSelectionFlow())
    }
}

