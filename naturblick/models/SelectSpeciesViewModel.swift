//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import SQLite

class SelectSpeciesViewModel: ObservableObject {
    @Published var speciesResults: [(SpeciesResult, SpeciesListItem)] = []
    
    func resolveSpecies(results: [SpeciesResult]) {
        do {
            let speciesDb = Connection.speciesDB
            let query = Species.Definition.baseQuery.filter(results.map { r in r.id }.contains(Species.Definition.table[Species.Definition.id]))
            speciesResults = try speciesDb.prepareRowIterator(query)
                .map { row in
                    let id = row[Species.Definition.table[Species.Definition.id]]
                    return (results.filter { r in r.id == id}.first!, SpeciesListItem(
                        speciesId: id,
                        sciname: row[Species.Definition.sciname],
                        gername: row[Species.Definition.gername],
                        maleUrl: row[Species.Definition.maleUrl],
                        femaleUrl: row[Species.Definition.femaleUrl],
                        gersynonym: row[Species.Definition.gersynonym],
                        isFemale: nil,
                        wikipedia: row[Species.Definition.wikipedia],
                        hasPortrait: row[Species.Definition.optionalPortraitId] != nil,
                        group: row[Species.Definition.group]
                    ))
                }
                .sorted { $0.0.score > $1.0.score }
        } catch {
            preconditionFailure("\(error)")
        }
    }
}
	
	
