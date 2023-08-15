//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import Foundation
import SQLite

struct Species: Identifiable {
    let id: Int64
    let group: String
    let sciname: String
    let gername: String?
    let engname: String?
    let wikipedia: String?
    let maleUrl: String?
    let femaleUrl: String?
    let gersynonym: String?
    let engsynonym: String?
    let redListGermany: String?
    let iucnCategory: String?
    let hasPortrait: Bool
}

extension Species {
    struct Definition {
        static let table = Table("species")
        static let id = Expression<Int64>("rowid")
        static let group = Expression<String>("group_id")
        static let sciname = Expression<String>("sciname")
        static let gername = Expression<String?>("gername")
        static let engname = Expression<String?>("engname")
        static let wikipedia = Expression<String?>("wikipedia")
        static let maleUrl = Expression<String?>("image_url")
        static let femaleUrl = Expression<String?>("female_image_url")
        static let gersynonym = Expression<String?>("gersynonym")
        static let engsynonym = Expression<String?>("engsynonym")
        static let redListGermany = Expression<String?>("red_list_germany")
        static let iucnCategory = Expression<String?>("iucn_category")
        static let isFemale = Expression<Bool?>("female")
        static let hasPortrait = Expression<Bool>("has_portrait")
        static let optionalPortraitId = Portrait.Definition.table[Expression<Int64?>("rowid")]
        static let optionalLanguage = Portrait.Definition.table[Expression<Int64?>("language")]
        static let baseQuery = table
            .select(table[*], optionalPortraitId, Portrait.Definition.audioUrl)
            .join(.leftOuter, Portrait.Definition.table, on: table[id] == Portrait.Definition.speciesId)
            .filter(optionalLanguage == 1 || optionalLanguage == nil)
    }
}

extension Species {
    static let sampleData = Species(
        id: 44,
        group: "bird",
        sciname: "Sturnus vulgaris",
        gername: "Star",
        engname: "Starling",
        wikipedia: "https://de.wikipedia.org/wiki/Star_(Art)",
        maleUrl: "/uploads/crop_053557dc868d4fac054473e2_f1d6e2d875.jpg",
        femaleUrl: nil,
        gersynonym: nil,
        engsynonym: nil,
        redListGermany: "gefahrdet",
        iucnCategory: "LC",
        hasPortrait: true
    )
}
