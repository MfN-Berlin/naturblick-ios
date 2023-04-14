//
// Copyright © 2023 Museum für Naturkunde Berlin.
// All Rights Reserved.

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
        iucnCategory: "LC"
    )
}
