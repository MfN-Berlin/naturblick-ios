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
            guard let path = Bundle.main.path(forResource: "strapi-db", ofType: "sqlite3") else {
                preconditionFailure("Failed to find database file")
            }
            
            do {
                let speciesDb = try Connection(path, readonly: true)
                
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
    
