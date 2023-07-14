//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation

struct ObservationResponse: Decodable {
    let data: [DBObservation]
    let partial: Bool
    let syncId: Int64?
}
