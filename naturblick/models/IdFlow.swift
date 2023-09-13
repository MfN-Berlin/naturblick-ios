//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import Mantis

protocol IdFlow: ObservableObject {
    var result: [SpeciesResult]? {get}
    func identify() async throws
    func selectSpecies(species: SpeciesListItem)
}
