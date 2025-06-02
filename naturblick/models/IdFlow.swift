//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation

protocol IdFlow: ObservableObject, SelectionFlow {
    var backend: Backend {get}
    var result: [SpeciesResult]? {get}
    var isCreate: Bool {get}
    var obsIdent: String? {get}
    func spectrogramCropDone(sound: NBSound, crop: NBThumbnail, start: Int, end: Int)
    func identify() async throws -> [SpeciesResult]
    func searchSpecies()
    func cancel()
    func isImage() -> Bool
}

