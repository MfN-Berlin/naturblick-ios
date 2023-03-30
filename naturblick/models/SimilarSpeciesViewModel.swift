//
// Copyright © 2023 Museum für Naturkunde Berlin.
// All Rights Reserved.


import Foundation
import SQLite

class SimilarSpeciesViewModel: ObservableObject {
    
    @Published private(set) var mixups = [SimilarSpecies]()
    
    private static func query(portraitId: Int64) -> QueryType {
        return SimilarSpecies.Definition.table
            .join(
                Species.Definition.table,
                on: Species.Definition.id == SimilarSpecies.Definition.similarToId
            )
            .filter(SimilarSpecies.Definition.portraitId == portraitId)

        }
        
        func filter(portraitId: Int64) {
            guard let path = Bundle.main.path(forResource: "strapi-db", ofType: "sqlite3") else {
                preconditionFailure("Failed to find database file")
            }
            
            do {
                let speciesDb = try Connection(path, readonly: true)
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
                            iucnCategory: row[Species.Definition.iucnCategory]
                        )
                    )
                }
            } catch {
                preconditionFailure(error.localizedDescription)
            }
        }
    }
