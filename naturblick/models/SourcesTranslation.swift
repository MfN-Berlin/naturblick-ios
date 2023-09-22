//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import SQLite

extension Dictionary<String, String> {
    struct Definition {
        static let table = Table("sources_translations")
        static let language = Expression<Int64>("language")
        static let key = Expression<String>("key")
        static let value = Expression<String>("value")
        
        static func rowsToKeyValuePairs(speciesDB: Connection, language: Int64) throws -> [(String, String)] {
            try speciesDB.prepare(table.select(key, value).filter(self.language == language)).map { row in
                (try row.get(key), try row.get(value))
            }
        }
    }
    
    init(speciesDB: Connection, language: Int64) throws {
        self.init(uniqueKeysWithValues: try Definition.rowsToKeyValuePairs(speciesDB: speciesDB, language: language))
    }
    
    func replaceAll(text: String?) -> String? {
        guard let text = text else {
            return text
        }
        return reduce(text) {partialResult, element in
            partialResult.replacingOccurrences(of: element.key, with: element.value)
        }
    }
}
