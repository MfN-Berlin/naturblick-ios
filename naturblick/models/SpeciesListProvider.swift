//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import Foundation
import SQLite

class SpeciesListProvider {
    let speciesDb: Connection = Connection.speciesDB
  
    private func searchOrNil(search: String) -> String? {
        return search.isEmpty ? nil : "%\(search)%"
    }
    
    private func filterSearchString(_ query: Table, _ searchString: String?) -> Table {
        return query.filter(Species.Definition.table[Species.Definition.gername].like(searchString!) ||
                            Species.Definition.sciname.like(searchString!) ||
                            Species.Definition.gersynonym.like(searchString!) ||
                            Species.Definition.table[Species.Definition.engname].like(searchString!) ||
                            Species.Definition.engsynonym.like(searchString!))
    }
    
    func query(filter: SpeciesListFilter, search: String) throws -> [SpeciesListItem] {
        let searchString = searchOrNil(search: search)
        switch filter {
        case .group(let group):
            return try speciesDb.prepareRowIterator(Species.query(searchString: search)
                .filter(Species.Definition.group == group.id)
                .filter(Portrait.Definition.language == Int(getLanguageId())))
                .map { row in
                    SpeciesListItem(
                        speciesId: row[Species.Definition.table[Species.Definition.id]],
                        sciname: row[Species.Definition.sciname],
                        speciesName: isGerman() ? row[Species.Definition.table[Species.Definition.gername]] : row[Species.Definition.table[Species.Definition.engname]],
                        maleUrl: row[Species.Definition.maleUrl],
                        maleUrlOrig: row[Species.Definition.maleUrlOrig],
                        femaleUrl: row[Species.Definition.femaleUrl],
                        synonym: isGerman() ? row[Species.Definition.gersynonym] : row[Species.Definition.engsynonym],
                        isFemale: nil,
                        wikipedia: row[Species.Definition.wikipedia],
                        hasPortrait: true,
                        group: Group.fromRow(row: row),
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
                        maleUrlOrig: row[Species.Definition.maleUrlOrig],
                        femaleUrl: row[Species.Definition.femaleUrl],
                        synonym: isGerman() ? row[Species.Definition.gersynonym] : row[Species.Definition.engsynonym],
                        isFemale: row[Species.Definition.isFemale],
                        wikipedia: row[Species.Definition.wikipedia],
                        hasPortrait: true,
                        group: Group(id: row[Character.groupName], groupType: GroupType(nature: row[Character.groupNature])),
                        audioUrl: nil
                    )
                }
        }
    }
}
