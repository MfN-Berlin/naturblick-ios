//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import SQLite

class GoodToKNowViewModel: ObservableObject {
    
    @Published private(set) var facts = [GoodToKnow]()
    
    private static func query(portraitId: Int64) -> QueryType {
        return GoodToKnow.Definition.table
            .filter(GoodToKnow.Definition.portraitId == portraitId)
        }
        
        func filter(portraitId: Int64) {
            do {
                let speciesDb = Connection.speciesDB
                
                facts = try speciesDb.prepareRowIterator(
                    GoodToKNowViewModel.query(portraitId: portraitId)
                )
                .map { row in
                    GoodToKnow(
                        fact: row[GoodToKnow.Definition.fact]
                    )
                }
            } catch {
                preconditionFailure(error.localizedDescription)
            }
        }
    }
    
