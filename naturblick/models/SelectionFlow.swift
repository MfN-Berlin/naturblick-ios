//
// Copyright © 2024 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation

protocol SelectionFlow: ObservableObject {
    func selectSpecies(species: SpeciesListItem?)
}
class VoidSelectionFlow: SelectionFlow {
    func selectSpecies(species: SpeciesListItem?) {}
}

