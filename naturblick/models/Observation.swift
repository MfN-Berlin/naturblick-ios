//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation

struct Observation: Identifiable, Equatable {
    static func == (lhs: Observation, rhs: Observation) -> Bool {
        lhs.id == rhs.id
    }
    
    let observation: DBObservation
    let species: Species?
    
    var id: UUID {
        observation.occurenceId
    }
}
