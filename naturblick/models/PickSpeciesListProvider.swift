//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import Foundation
import SQLite

class PickSpeciesListProvider {
    let speciesDb: Connection = Connection.speciesDB
    static let pageSize: Int = 50

    private func searchOrNil(search: String) -> String? {
        return search.isEmpty ? nil : "%\(search)%"
    }
    
    func query(search: String, page: Int) throws -> [SpeciesListItem] {
        return try speciesDb.prepare(Species.query(searchString: search).limit(PickSpeciesListProvider.pageSize, offset: page * PickSpeciesListProvider.pageSize))
            .map { row in
                SpeciesListItem(
                    speciesId: row[Species.Definition.table[Species.Definition.id]],
                    sciname: row[Species.Definition.sciname],
                    speciesName: isGerman() ? row[Species.Definition.gername] : row[Species.Definition.engname],
                    maleUrl: row[Species.Definition.maleUrl],
                    femaleUrl: row[Species.Definition.femaleUrl],
                    synonym: isGerman() ? row[Species.Definition.gersynonym] : row[Species.Definition.engsynonym],
                    isFemale: nil,
                    wikipedia: row[Species.Definition.wikipedia],
                    hasPortrait: row[Species.Definition.optionalPortraitId] != nil,
                    group: Group.fromRow(row: row),
                    audioUrl: row[Portrait.Definition.audioUrl]
                )
            }
    }
}
