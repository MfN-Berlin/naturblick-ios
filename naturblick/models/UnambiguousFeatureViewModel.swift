//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import SQLite

class UnambiguousFeatureViewModel: ObservableObject {
    
    @Published private(set) var features = [UnambiguousFeature]()
    
    private static func query(portraitId: Int64) -> QueryType {
        return UnambiguousFeature.Definition.table
            .filter(UnambiguousFeature.Definition.portraitId == portraitId)
        }
        
        func filter(portraitId: Int64) {
            do {
                let speciesDb = Connection.speciesDB
                
                features = try speciesDb.prepareRowIterator(
                    UnambiguousFeatureViewModel.query(portraitId: portraitId)
                )
                .map { row in
                    UnambiguousFeature(
                        description: row[UnambiguousFeature.Definition.description]
                    )
                }
            } catch {
                preconditionFailure(error.localizedDescription)
            }
        }
    }
    
