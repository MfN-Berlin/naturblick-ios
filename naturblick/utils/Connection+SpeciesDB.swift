//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import Foundation
import SQLite

extension Connection {
    static var speciesDB: Connection {
        do {
            guard let path = Bundle.main.path(forResource: "strapi-db", ofType: "sqlite3") else {
                preconditionFailure("Failed to find database file")
            }
            return try Connection(path, readonly: true)
        } catch {
            preconditionFailure("Failed to connect database \(error)")
        }
    }
}
