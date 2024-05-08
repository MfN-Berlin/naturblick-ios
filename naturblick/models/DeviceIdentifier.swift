//
// Copyright © 2024 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import SQLite

struct DeviceIdentifier {
    let id: String
    let name: String
}

extension DeviceIdentifier {
    enum D {
        static let table = Table("device_identifier")
        static let id = Expression<String>("id")
        static let name = Expression<String>("name")

        static func setters(deviceIdentifier: DeviceIdentifier) -> [Setter] {
            [
                id <- deviceIdentifier.id,
                name <- deviceIdentifier.name
            ]
        }

        static func instance(row: Row) throws -> DeviceIdentifier {
            return DeviceIdentifier(
                id: try row.get(table[id]),
                name: try row.get(table[name])
            )
        }
    }

    func setters() -> [Setter] {
        DeviceIdentifier.D.setters(deviceIdentifier: self)
    }
}
