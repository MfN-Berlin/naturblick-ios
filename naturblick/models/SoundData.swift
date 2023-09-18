//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation

struct SoundData {
    var sound: NBSound? = nil
    var crop: NBImage? = nil
    var start: CGFloat? = nil
    var end: CGFloat? = nil
    var result: [SpeciesResult]? = nil
    
    var identified: Identified? {
        if let result = result, let crop = crop {
            return Identified(crop: crop, result: result)
        } else {
            return nil
        }
    }
}
