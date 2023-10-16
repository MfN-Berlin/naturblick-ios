//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import Foundation
import SQLite

class PickSpeciesListViewModel: ObservableObject {
    let speciesDb: Connection = Connection.speciesDB
    static let pageSize: Int = 50

    private func searchOrNil(search: String) -> String? {
        return search.isEmpty ? nil : "%\(search)%"
    }
    
    func query(search: String, page: Int) throws -> [SpeciesListItem] {
        let searchString = searchOrNil(search: search)
        let query = Species.Definition.baseQuery
        let queryWithSearch = searchString != nil ? query.filter(Species.Definition.gername.like(searchString!)) : query
        return try speciesDb.prepare(queryWithSearch.order(Species.Definition.gername).limit(PickSpeciesListViewModel.pageSize, offset: page * PickSpeciesListViewModel.pageSize))
            .map { row in
                SpeciesListItem(
                    speciesId: row[Species.Definition.table[Species.Definition.id]],
                    sciname: row[Species.Definition.sciname],
                    gername: isGerman() ? row[Species.Definition.gername] : row[Species.Definition.engname],
                    maleUrl: row[Species.Definition.maleUrl],
                    femaleUrl: row[Species.Definition.femaleUrl],
                    gersynonym: isGerman() ? row[Species.Definition.gersynonym] : row[Species.Definition.engsynonym],
                    isFemale: nil,
                    wikipedia: row[Species.Definition.wikipedia],
                    hasPortrait: row[Species.Definition.optionalPortraitId] != nil,
                    group: row[Species.Definition.group],
                    audioUrl: row[Portrait.Definition.audioUrl]
                )
            }
    }
}
