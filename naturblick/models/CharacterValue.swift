//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import SQLite

struct CharacterValue: Identifiable {
    let id: Int64
    let characterId: Int64
    let gername: String
    let engname: String
    let hasImage: Bool
    
    var name: String {
        isGerman() ? gername : engname
    }
}

extension CharacterValue {
    enum D {
        static let table = Table("character_value")
        static let id = Expression<Int64>("rowid")
        static let characterId = Expression<Int64>("character_id")
        static let gername = Expression<String>("gername")
        static let engname = Expression<String>("engname")
        static let hasImage = Expression<Bool>("has_image")
    }
}

extension CharacterValue {
    static let sampleData = [
        CharacterValue(
            id: 1,
            characterId: Character.sampleData.id,
            gername: "Weiß",
            engname: "White",
            hasImage: true
        ),
        CharacterValue(
            id: 2,
            characterId: Character.sampleData.id,
            gername: "Gelb",
            engname: "Yellow",
            hasImage: true
        ),
        CharacterValue(
            id: 3,
            characterId: Character.sampleData.id,
            gername: "Bräunlich",
            engname: "Borwnish",
            hasImage: true
        ),
        CharacterValue(
            id: 4,
            characterId: Character.sampleData.id,
            gername: "Schwarz oder Grau",
            engname: "Black or grey",
            hasImage: true
        )
    ]
}
