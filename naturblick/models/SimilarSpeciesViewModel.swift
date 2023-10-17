//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import SQLite

class SimilarSpeciesViewModel: ObservableObject {
    
    @Published private(set) var mixups = [SimilarSpecies]()
    
    private static func query(portraitId: Int64) -> QueryType {
        return SimilarSpecies.Definition.table
            .select(SimilarSpecies.Definition.table[*], Species.Definition.table[*], Species.Definition.optionalPortraitId)
            .join(
                Species.Definition.table,
                on: Species.Definition.table[Species.Definition.id] == SimilarSpecies.Definition.similarToId
            )
            .join(.leftOuter, Portrait.Definition.table, on: Species.Definition.table[Species.Definition.id] == Portrait.Definition.speciesId)
            .filter(Species.Definition.optionalLanguage == getLanguageId() || Species.Definition.optionalLanguage == nil)
            .filter(SimilarSpecies.Definition.portraitId == portraitId)
        }
        
        func filter(portraitId: Int64) {
            do {
                let speciesDb = Connection.speciesDB
                mixups = try speciesDb.prepareRowIterator(
                    SimilarSpeciesViewModel.query(portraitId: portraitId)
                )
                .map { row in
                    SimilarSpecies(
                        portraitId: row[SimilarSpecies.Definition.portraitId],
                        similarToId: row[SimilarSpecies.Definition.similarToId],
                        differences: row[SimilarSpecies.Definition.differences],
                        species: Species(
                            id: row[Species.Definition.table[Species.Definition.id]],
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
                            iucnCategory: row[Species.Definition.iucnCategory],
                            hasPortrait: row[Species.Definition.optionalPortraitId] != nil
                        )
                    )
                }
            } catch {
                preconditionFailure(error.localizedDescription)
            }
        }
    }
