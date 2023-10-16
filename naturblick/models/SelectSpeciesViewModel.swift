//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import SQLite

class SelectSpeciesViewModel: ObservableObject {
    @Published var speciesResults: [(SpeciesResult, SpeciesListItem)]? = nil
    
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
                        gername: isGerman() ? row[Species.Definition.gername] : row[Species.Definition.engname],
                        maleUrl: row[Species.Definition.maleUrl],
                        femaleUrl: row[Species.Definition.femaleUrl],
                        gersynonym: isGerman() ? row[Species.Definition.gersynonym] : row[Species.Definition.engsynonym],
                        isFemale: nil,
                        wikipedia: row[Species.Definition.wikipedia],
                        hasPortrait: row[Species.Definition.optionalPortraitId] != nil,
                        group: row[Species.Definition.group],
                        audioUrl: row[Portrait.Definition.audioUrl]
                    ))
                }
                .sorted { $0.0.score > $1.0.score }
        } catch {
            preconditionFailure("\(error)")
        }
    }
}
	
	
