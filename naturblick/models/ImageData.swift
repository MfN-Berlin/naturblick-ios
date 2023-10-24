//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation

struct ImageData {
    var image: NBImage? = nil
    var crop: NBThumbnail? = nil
    var result: [SpeciesResult]? = nil
    
    var identified: Identified? {
        if let result = result, let crop = crop {
            return Identified(crop: crop, result: result)
        } else {
            return nil
        }
    }
}
