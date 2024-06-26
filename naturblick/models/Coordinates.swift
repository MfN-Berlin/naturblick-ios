//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import Foundation
import CoreLocation
import MapKit
import SQLite
import SwiftUI

struct Coordinates: Equatable {
    let latitude: Double
    let longitude: Double
}

extension Coordinates: Codable {
    public init(from decoder: Decoder) throws {
        let singleValue = try decoder.singleValueContainer()
        let components = try singleValue.decode([Double].self)
        guard components.count == 2 else {
            throw DecodingError.dataCorruptedError(in: singleValue, debugDescription: "Coordinate array must have exactly 2 elements")
        }
        self.init(latitude: components[1], longitude: components[0])
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode([longitude as Double, latitude as Double])
    }
}

extension Coordinates {
    init(location: CLLocation) {
        self.init(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }
    
    init(region: MKCoordinateRegion) {
        self.init(latitude: region.center.latitude, longitude: region.center.longitude)
    }
    
    var region: MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: latitude,
                longitude: longitude
            ),
            latitudinalMeters: 750,
            longitudinalMeters: 750
        )
    }
    
    var location: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func asString() -> String {
        String(format: "Latitude: %.2f / Longitude: %.2f", latitude, longitude)
    }
    
    static let defaultCoordinates = Coordinates(latitude: 51.163375, longitude: 10.447683)
}

extension MKCoordinateRegion {
    static let defaultRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.163375,
                                       longitude: 10.447683),
        latitudinalMeters: 1000000,
        longitudinalMeters: 1000000
    )
}

extension Coordinates {
    func timezone() throws -> TimeZone? {
        return try getVertices()
            .filter{ insideOf(polygon: $1) }
            .filter { dbZoneId, _ in
                if try Connection.speciesDB.pluck(TimeZonePolygon.D.table.filter(TimeZonePolygon.D.id == dbZoneId)) != nil {
                    return true
                } else {
                    return false
                }
            }.map { dbZoneId, _ in
                if let polygonRow = try Connection.speciesDB.pluck(TimeZonePolygon.D.table.filter(TimeZonePolygon.D.id == dbZoneId)), let timezone = TimeZone(identifier: polygonRow[TimeZonePolygon.D.zoneId]) {
                    return timezone
                }
                return TimeZone(identifier: TimeZone.current.identifier)!
            }.first
    }
   
    /*
     * Based on: https://github.com/piruin/geok/blob/master/geok/src/commonMain/kotlin/me/piruin/geok/LatLng.kt#L122
     */
    private func insideOf(polygon: [TimeZoneVertex]) -> Bool {
        var i = 0
        var j = polygon.count - 1
        var result = false

        while (i < polygon.count) {
            let u = (polygon[j].longitude - polygon[i].longitude) *
                (self.latitude - polygon[i].latitude) /
                (polygon[j].latitude - polygon[i].latitude) +
                polygon[i].longitude
             if ( (polygon[i].latitude > self.latitude) != (polygon[j].latitude > self.latitude) &&
                 self.longitude < u
             ) {
                 result = !result
             }
            j = i
            i = i + 1
         }
         return result
    }
    
    private func getVertices() throws -> Dictionary<Int64, [TimeZoneVertex]> {
        let vertices: [TimeZoneVertex] = try Connection.speciesDB.prepareRowIterator(TimeZoneVertex.D.table.select(*)).map(TimeZoneVertex.D.instance)
        let res = vertices.reduce(into: [Int64: [TimeZoneVertex]]()) { res, element in
            if res[element.polygonId] == nil {
                res[element.polygonId] = [element]
            } else {
                res[element.polygonId]?.append(element)
            }
        }
        return res
    }
}
