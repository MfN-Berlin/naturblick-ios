//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import SQLite

struct SimilarSpecies: Identifiable {
    var id: Int64 {
        return similarToId
    }
    let portraitId: Int64
    let similarToId: Int64
    let differences: String
    let species: Species
}

extension SimilarSpecies {
    struct Definition {
        static let table = Table("similar_species")
        static let portraitId = Expression<Int64>("portrait_id")
        static let similarToId = Expression<Int64>("similar_to_id")
        static let differences = Expression<String>("differences")
    }
}

