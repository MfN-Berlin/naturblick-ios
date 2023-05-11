//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import SQLite

@MainActor
class ObservationViewModel: ObservableObject {
    @Published private(set) var species: Species? =  nil

    func load(observation: Observation) async {
        guard let speciesId: Int64 = observation.newSpeciesId else {
            return
        }
        guard let path = Bundle.main.path(forResource: "strapi-db", ofType: "sqlite3") else {
            preconditionFailure("Failed to find database file")
        }
        do {
            let db = try Connection(path, readonly: true)
            let rowOpt = try db.pluck(
                Species.Definition.table.filter(Species.Definition.id == speciesId)
            )
            guard let row = rowOpt else {
                return
            }
            species = Species(
                id: row[Species.Definition.id],
                group: row[Species.Definition.group],
                sciname: row[Species.Definition.sciname],
                gername: row[Species.Definition.gername],
                engname: row[Species.Definition.engname],
                wikipedia: row[Species.Definition.wikipedia], maleUrl: row[Species.Definition.maleUrl],
                femaleUrl: row[Species.Definition.femaleUrl],
                gersynonym: row[Species.Definition.gersynonym],
                engsynonym: row[Species.Definition.engsynonym],
                redListGermany: row[Species.Definition.redListGermany],
                iucnCategory: row[Species.Definition.iucnCategory]
            )
            species = species
        } catch {
            preconditionFailure(error.localizedDescription)
        }
    }
}
