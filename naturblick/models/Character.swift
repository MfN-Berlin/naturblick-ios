//
// Copyright © 2023 Museum für Naturkunde Berlin.
// All Rights Reserved.


import Foundation
import SQLite

struct Character: Identifiable {
    let id: Int64
    let gername: String
    let engname: String
    let group: String
    let weight: Int64
    let single: Int64
    let gerdescription: String?
    let engdescription: String?
}

extension Character {
    enum D {
        static let table = Table("character")
        static let id = Expression<Int64>("rowid")
        static let gername = Expression<String>("gername")
        static let engname = Expression<String>("engname")
        static let group = Expression<String>("group")
        static let weight = Expression<Int64>("weight")
        static let single = Expression<Int64>("single")
        static let gerdescription = Expression<String?>("gerdescription")
        static let engdescription = Expression<String?>("engdescription")
    }
}

extension Character {
    static let sampleData = Character(
        id: 1,
        gername: "Farbe",
        engname: "Color",
        group: Group.groups[0].id,
        weight: 1,
        single: 1,
        gerdescription: "Verschiedene Farben",
        engdescription: "Different colors"
    )
}
