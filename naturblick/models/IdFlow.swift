//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation

protocol IdFlow: ObservableObject, SelectionFlow {
    var result: [SpeciesResult]? {get}
    var isCreate: Bool {get}
    var obsIdent: String? {get}
    func spectrogramCropDone(sound: NBSound, crop: NBThumbnail, start: Int, end: Int)
    func identify() async throws -> [SpeciesResult]
    func searchSpecies()
    func isImage() -> Bool
}

class IdFlowSample: VoidSelectionFlow, IdFlow {
    var result: [SpeciesResult]? = nil
    var isCreate: Bool = true
    var obsIdent: String? = nil
    func spectrogramCropDone(sound: NBSound, crop: NBThumbnail, start: Int, end: Int) {}
    func identify() async throws -> [SpeciesResult] {[]}
    func searchSpecies() {}
    func isImage() -> Bool { return true }
    
}
