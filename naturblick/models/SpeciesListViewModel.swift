//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import Foundation
import SQLite

class SpeciesListViewModel: ObservableObject {
    let speciesDb: Connection = Connection.speciesDB
  
    private func searchOrNil(search: String) -> String? {
        return search.isEmpty ? nil : "%\(search)%"
    }
    
    private func filterSearchString(_ query: Table, _ searchString: String?) -> Table {
        return query.filter(Species.Definition.gername.like(searchString!) ||
                            Species.Definition.sciname.like(searchString!) ||
                            Species.Definition.gersynonym.like(searchString!) ||
                            Species.Definition.engname.like(searchString!) ||
                            Species.Definition.engsynonym.like(searchString!))
    }
    
    func query(filter: SpeciesListFilter, search: String) throws -> [SpeciesListItem] {
        let searchString = searchOrNil(search: search)
        switch filter {
        case .group(let group):
            let query = Species.Definition.table
                .join(.leftOuter, Portrait.Definition.table,
                      on: Portrait.Definition.speciesId == Species.Definition.table[Species.Definition.id])
                .filter(Species.Definition.group == group.id)
                .filter(Portrait.Definition.language == 1)
                .order(Species.Definition.gername)
            let queryWithSearch = searchString != nil ? filterSearchString(query, searchString) : query
            return try speciesDb.prepareRowIterator(queryWithSearch.order(Species.Definition.gername))
                .map { row in
                    SpeciesListItem(
                        speciesId: row[Species.Definition.table[Species.Definition.id]],
                        sciname: row[Species.Definition.sciname],
                        speciesName: isGerman() ? row[Species.Definition.gername] : row[Species.Definition.engname],
                        maleUrl: row[Species.Definition.maleUrl],
                        femaleUrl: row[Species.Definition.femaleUrl],
                        synonym: isGerman() ? row[Species.Definition.gersynonym] : row[Species.Definition.engname],
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
                        speciesName: isGerman() ? row[Species.Definition.gername] : row[Species.Definition.engname],
                        maleUrl: row[Species.Definition.maleUrl],
                        femaleUrl: row[Species.Definition.femaleUrl],
                        synonym: isGerman() ? row[Species.Definition.gersynonym] : row[Species.Definition.engsynonym],
                        isFemale: row[Species.Definition.isFemale],
                        wikipedia: row[Species.Definition.wikipedia],
                        hasPortrait: true,
                        group: row[Species.Definition.group],
                        audioUrl: nil
                    )
                }
        }
    }
}
