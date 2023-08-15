//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import Foundation
import SQLite

class SpeciesListViewModel: ObservableObject {
    let speciesDb: Connection = Connection.speciesDB
    static let pageSize: Int = 50

    private func searchOrNil(search: String) -> String? {
        return search.isEmpty ? nil : "%\(search)%"
    }
    
    func query(filter: SpeciesListFilter, search: String) throws -> [SpeciesListItem] {
        let searchString = searchOrNil(search: search)
        switch filter {
        case .group(let group):
            let query = Species.Definition.table
                .join(Portrait.Definition.table,
                      on: Portrait.Definition.speciesId == Species.Definition.table[Species.Definition.id])
                .filter(Species.Definition.group == group.id)
                .filter(Portrait.Definition.language == 1)
            let queryWithSearch = searchString != nil ? query.filter(Species.Definition.gername.like(searchString!)) : query
            return try speciesDb.prepareRowIterator(queryWithSearch.order(Species.Definition.gername))
                .map { row in
                    SpeciesListItem(
                        speciesId: row[Species.Definition.table[Species.Definition.id]],
                        sciname: row[Species.Definition.sciname],
                        gername: row[Species.Definition.gername],
                        maleUrl: row[Species.Definition.maleUrl],
                        femaleUrl: row[Species.Definition.femaleUrl],
                        gersynonym: row[Species.Definition.gersynonym],
                        isFemale: nil,
                        wikipedia: row[Species.Definition.wikipedia],
                        hasPortrait: true,
                        group: row[Species.Definition.group],
                        audioUrl: row[Portrait.Definition.audioUrl]
                    )
                }
        case .characters(let number, let query):
            let (querySyntax, bindings) = Character.charactersQuery(number: number, query: query, searchQuery: searchString)
            return try speciesDb.prepareRowIterator(querySyntax, bindings: bindings)
                .map { row in
                    SpeciesListItem(
                        speciesId: row[Species.Definition.id],
                        sciname: row[Species.Definition.sciname],
                        gername: row[Species.Definition.gername],
                        maleUrl: row[Species.Definition.maleUrl],
                        femaleUrl: row[Species.Definition.femaleUrl],
                        gersynonym: row[Species.Definition.gersynonym],
                        isFemale: row[Species.Definition.isFemale],
                        wikipedia: row[Species.Definition.wikipedia],
                        hasPortrait: true,
                        group: row[Species.Definition.group],
                        audioUrl: row[Portrait.Definition.audioUrl]
                    )
                }
        }
    }
    
    func query(search: String, page: Int) throws -> [SpeciesListItem] {
        let searchString = searchOrNil(search: search)
        let query = Species.Definition.baseQuery
        let queryWithSearch = searchString != nil ? query.filter(Species.Definition.gername.like(searchString!)) : query
        return try speciesDb.prepare(queryWithSearch.order(Species.Definition.gername).limit(SpeciesListViewModel.pageSize, offset: page * SpeciesListViewModel.pageSize))
            .map { row in
                SpeciesListItem(
                    speciesId: row[Species.Definition.table[Species.Definition.id]],
                    sciname: row[Species.Definition.sciname],
                    gername: row[Species.Definition.gername],
                    maleUrl: row[Species.Definition.maleUrl],
                    femaleUrl: row[Species.Definition.femaleUrl],
                    gersynonym: row[Species.Definition.gersynonym],
                    isFemale: nil,
                    wikipedia: row[Species.Definition.wikipedia],
                    hasPortrait: row[Species.Definition.optionalPortraitId] != nil,
                    group: row[Species.Definition.group],
                    audioUrl: row[Portrait.Definition.audioUrl]
                )
            }
    }
}
