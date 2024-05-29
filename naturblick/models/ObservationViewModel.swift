//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation

class ObservationViewModel: ObservableObject {
    @Published var observation: Observation? = nil
    init(viewObservation: UUID, persistenceController: ObservationPersistenceController) {
        persistenceController.$observations.map {
            $0.first {
                $0.observation.id == viewObservation
            }
        }.assign(to: &$observation)
    }
    
}
