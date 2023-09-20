//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import SQLite

struct PortraitImage: Identifiable {
    let id: Int64
    let owner: String
    let ownerLink: String?
    let source: String
    let text: String
    let license: String
    let sizes: [PortraitImageSize]
}

extension PortraitImage {
    struct Definition {
        static let table = Table("portrait_image")
        static let id = Expression<Int64>("rowid")
        static let owner = Expression<String>("owner")
        static let ownerLink = Expression<String?>("owner_link")
        static let source = Expression<String>("source")
        static let text = Expression<String>("text")
        static let license = Expression<String>("license")
    }
    
    func bestImage(geo: GeometryProxy, displayScale: CGFloat) -> PortraitImageSize {
        sizes.filter { size in
            CGFloat(size.width) > geo.size.width * displayScale
        }.sorted(by: {$0.width < $1.width}).first ?? sizes.sorted(by: {$0.width < $1.width}).last!
    }
}

extension PortraitImage {
    static let sampleData = PortraitImage(
        id: 1,
        owner: "Jörg Hempel",
        ownerLink: nil,
        source: "https://commons.wikimedia.org/wiki/File:Geum_rivale_LC0328.jpg",
        text: "Habitus",
        license: "CC BY-SA 3.0",
        sizes: []
    )
}


