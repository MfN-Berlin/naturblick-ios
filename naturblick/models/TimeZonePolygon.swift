//
// Copyright © 2024 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import SQLite

struct TimeZonePolygon: Identifiable {
    let id: Int64
    let zoneId: String
}

extension TimeZonePolygon {
    struct D {
        static let table = Table("time_zone_polygon")
        static let id = Expression<Int64>("rowid")
        static let zoneId = Expression<String>("zone_id")
    }
}
