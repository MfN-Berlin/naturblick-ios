//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import SQLite

struct PortraitImageSize {
    let width: Int64
    let height: Int64
    let url: String
}

extension PortraitImageSize {
    struct Definition {
        static let table = Table("portrait_image_size")
        static let portraitImageId = Expression<Int64>("portrait_image_id")
        static let portraitImageIdOpt = Expression<Int64?>("portrait_image_id")
        static let width = Expression<Int64>("width")
        static let height = Expression<Int64>("height")
        static let url = Expression<String>("url")
    }
}
