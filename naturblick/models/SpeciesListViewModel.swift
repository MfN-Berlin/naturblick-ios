//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import Foundation
import SQLite

class SpeciesListViewModel: ObservableObject {
    let filter: SpeciesListFilter
    let speciesDb: Connection
    @Published private(set) var species = [SpeciesListItem]()
    @Published var query: String = ""

    init(filter: SpeciesListFilter) {
        self.filter = filter
        guard let path = Bundle.main.path(forResource: "strapi-db", ofType: "sqlite3") else {
            preconditionFailure("Failed to find database file")
        }

        do {
            speciesDb = try Connection(path, readonly: true)
            $query.map { [self] searchQuery in
                do {
                    if query.isEmpty {
                        return try SpeciesListViewModel.query(db: speciesDb, filter: filter, searchQuery: nil)
                    } else {
                        return try SpeciesListViewModel.query(db: speciesDb, filter: filter, searchQuery: searchQuery)
                    }
                } catch {
                    preconditionFailure(error.localizedDescription)
                }
            }
            .assign(to: &$species)
        } catch {
            preconditionFailure(error.localizedDescription)
        }
    }

    private static func query(db: Connection, filter: SpeciesListFilter, searchQuery: String?) throws -> [SpeciesListItem] {
        switch filter {
        case .group(let group):
            let query = Species.Definition.table
                .join(Portrait.Definition.table,
                      on: Portrait.Definition.speciesId == Species.Definition.table[Species.Definition.id])
                .filter(Species.Definition.group == group.id)
                .filter(Portrait.Definition.language == 1)
            let queryWithSearch = searchQuery != nil ? query.filter(Species.Definition.gername.like("%\(searchQuery!)%")) : query
            return try db.prepareRowIterator(queryWithSearch.order(Species.Definition.gername))
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
            let searchString = searchQuery != nil ? "%\(searchQuery!)%" : nil
            let (querySyntax, bindings) = Character.charactersQuery(number: number, query: query, searchQuery: searchString)
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
}
