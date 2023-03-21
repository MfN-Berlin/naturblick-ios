//
// Copyright © 2023 Museum für Naturkunde Berlin.
// All Rights Reserved.

import Foundation
import SQLite

class SpeciesListViewModel: ObservableObject {

    @Published private(set) var species = [Species]()

    func filter(filter: SpeciesListFilter) {
        guard let path = Bundle.main.path(forResource: "strapi-db", ofType: "sqlite3") else {
            preconditionFailure("Failed to find database file")
        }

        do {
            let speciesDb = try Connection(path, readonly: true)

            species = try speciesDb.prepareRowIterator(Species.Definition.table).map { row in
                Species(
                    id: row[Species.Definition.id],
                    group: row[Species.Definition.group],
                    sciname: row[Species.Definition.sciname],
                    gername: row[Species.Definition.gername],
                    engname: row[Species.Definition.engname],
                    wikipedia: row[Species.Definition.wikipedia],
                    maleUrl: row[Species.Definition.maleUrl],
                    femaleUrl: row[Species.Definition.femaleUrl],
                    gersynonym: row[Species.Definition.gersynonym],
                    engsynonym: row[Species.Definition.engsynonym],
                    redListGermany: row[Species.Definition.redListGermany],
                    iucnCategory: row[Species.Definition.iucnCategory]
                )
            }
        } catch {
            preconditionFailure(error.localizedDescription)
        }
    }
}
