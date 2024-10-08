//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation


struct SpeciesResult : Decodable, Identifiable {
    let id: Int64
    let score: Double
}
