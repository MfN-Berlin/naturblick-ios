//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import Mantis
import SwiftUI

import UIKit
import MapKit
import Combine

protocol IdFlow: ObservableObject {
    var result: [SpeciesResult]? {get}
    func spectrogramCropDone(crop: NBImage, start: Int, end: Int)
    func identify() async throws -> [SpeciesResult]
    func selectSpecies(species: SpeciesListItem?)
    func searchSpecies()
    func isImage() -> Bool
}

class IdFlowSample: IdFlow {
    var result: [SpeciesResult]? = nil
    func spectrogramCropDone(crop: NBImage, start: Int, end: Int) {}
    func identify() async throws -> [SpeciesResult] {[]}
    func selectSpecies(species: SpeciesListItem?) {}
    func searchSpecies() {}
    func isImage() -> Bool { return true }
}
