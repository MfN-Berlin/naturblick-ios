//
// Copyright © 2023 Museum für Naturkunde Berlin.
// All Rights Reserved.


import Foundation
import SQLite

struct PortraitImage {
    let width: Int64
    let height: Int64
    let url: String
}

extension PortraitImage {
    struct Definition {
        static let table = Table("portrait_image_size")
        static let portraitImageId = Expression<Int64>("portrait_image_id")
        static let width = Expression<Int64>("width")
        static let height = Expression<Int64>("height")
        static let url = Expression<String>("url")
    }
}
