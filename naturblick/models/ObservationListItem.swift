//
// Copyright © 2023 Museum für Naturkunde Berlin.
// All Rights Reserved.


import Foundation

struct ObservationListItem: Identifiable {
    let id: UUID
    let species: SpeciesListItem?
    let time: Date
}

extension ObservationListItem {
    static let sampleData = ObservationListItem(
        id: UUID(),
        species: SpeciesListItem.sampleData,
        time: Date()
    )
}
