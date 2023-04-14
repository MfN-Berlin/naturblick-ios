//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import SQLite

struct PortraitImageMeta: Identifiable {
    let id: Int64
    let owner: String
    let ownerLink: String?
    let source: String
    let text: String
    let license: String
}

extension PortraitImageMeta {
    struct Definition {
        static let table = Table("portrait_image")
        static let id = Expression<Int64>("rowid")
        static let owner = Expression<String>("owner")
        static let ownerLink = Expression<String?>("owner_link")
        static let source = Expression<String>("source")
        static let text = Expression<String>("text")
        static let license = Expression<String>("license")
    }
}

extension PortraitImageMeta {
    static let sampleData = PortraitImageMeta(
        id: 1,
        owner: "Jörg Hempel",
        ownerLink: nil,
        source: "https://commons.wikimedia.org/wiki/File:Geum_rivale_LC0328.jpg",
        text: "Habitus",
        license: "CC BY-SA 3.0"
    )
}
