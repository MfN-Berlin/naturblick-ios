//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import Mantis
import SwiftUI

protocol IdFlow: ObservableObject {
    var result: [SpeciesResult]? {get}
    var spectrogram: UIImage? {get}
    func spectrogramDownloaded(spectrogram: UIImage)
    func spectrogramCropDone(crop: NBImage, start: CGFloat, end: CGFloat)
    func identify() async throws
    func selectSpecies(species: SpeciesListItem)
}

class IdFlowSample: IdFlow {
    var result: [SpeciesResult]? = nil
    var spectrogram: UIImage? = nil
    func spectrogramDownloaded(spectrogram: UIImage) {}
    func spectrogramCropDone(crop: NBImage, start: CGFloat, end: CGFloat) {}
    func identify() async throws {}
    func selectSpecies(species: SpeciesListItem) {}
}
