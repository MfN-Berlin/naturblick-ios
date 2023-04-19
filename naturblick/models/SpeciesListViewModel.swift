//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import Foundation
import SQLite

class SpeciesListViewModel: ObservableObject {

    @Published private(set) var species = [SpeciesListItem]()

    private static func query(db: Connection, filter: SpeciesListFilter) throws -> [SpeciesListItem] {
        switch filter {
        case .group(let group):
            return try db.prepareRowIterator(
                Species.Definition.table
                    .join(Portrait.Definition.table,
                          on: Portrait.Definition.speciesId == Species.Definition.table[Species.Definition.id])
                    .filter(Species.Definition.group == group.id)
                    .filter(Portrait.Definition.language == 1) // Only in german to start with
                    .order(Species.Definition.gername)
            )
            .map { row in
                SpeciesListItem(
                    speciesId: row[Species.Definition.table[Species.Definition.id]],
                    sciname: row[Species.Definition.sciname],
                    gername: row[Species.Definition.gername],
                    maleUrl: row[Species.Definition.maleUrl],
                    femaleUrl: row[Species.Definition.femaleUrl],
                    gersynonym: row[Species.Definition.gersynonym],
                    isFemale: nil
                )
            }
        case .characters(let number, let query):
            let (querySyntax, bindings) = Character.charactersQuery(number: number, query: query)
            return try db.prepareRowIterator(querySyntax, bindings: bindings)
                .map { row in
                    SpeciesListItem(
                        speciesId: row[Species.Definition.id],
                        sciname: row[Species.Definition.sciname],
                        gername: row[Species.Definition.gername],
                        maleUrl: row[Species.Definition.maleUrl],
                        femaleUrl: row[Species.Definition.femaleUrl],
                        gersynonym: row[Species.Definition.gersynonym],
                        isFemale: row[Species.Definition.isFemale]
                    )
                }
        }
    }

    func filter(filter: SpeciesListFilter) {
        guard let path = Bundle.main.path(forResource: "strapi-db", ofType: "sqlite3") else {
            preconditionFailure("Failed to find database file")
        }

        do {
            let speciesDb = try Connection(path, readonly: true)
            species = try SpeciesListViewModel.query(db: speciesDb, filter: filter)
        } catch {
            preconditionFailure(error.localizedDescription)
        }
    }
}
