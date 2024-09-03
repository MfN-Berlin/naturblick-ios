//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation

struct Observation: Identifiable, Equatable, Hashable {
    
    let observation: DBObservation
    let species: Species?
    
    var id: UUID {
        observation.occurenceId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(observation.occurenceId)
    }
}
