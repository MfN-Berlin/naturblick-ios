//
// Copyright © 2023 Museum für Naturkunde Berlin.
// All Rights Reserved.


import Foundation
import SQLite

struct GoodToKnow: Identifiable {
    var id: String {
        return fact
    }
    let fact: String
}

extension GoodToKnow {
    struct Definition {
        static let table = Table("good_to_know")
        static let portraitId = Expression<Int64>("portrait_id")
        static let fact = Expression<String>("fact")
    }
}
