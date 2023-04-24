//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import SQLite

struct UnambiguousFeature: Identifiable {
    var id: String {
        return description
    }
    let description: String
}

extension UnambiguousFeature {
    struct Definition {
        static let table = Table("unambiguous_feature")
        static let portraitId = Expression<Int64>("portrait_id")
        static let description = Expression<String>("description")
    }
}
