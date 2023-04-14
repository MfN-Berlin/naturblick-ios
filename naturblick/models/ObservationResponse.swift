//
// Copyright © 2023 Museum für Naturkunde Berlin.
// All Rights Reserved.


import Foundation

struct ObservationResponse: Decodable {
    let data: [Observation]
    let partial: Bool
    let syncId: Int64?
}
