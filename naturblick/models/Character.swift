//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import SQLite

struct Character: Identifiable {
    let id: Int64
    let gername: String
    let engname: String
    let group: String
    let weight: Int64
    let single: Bool
    let gerdescription: String?
    let engdescription: String?
    
    var name: String {
        isGerman() ? gername : engname
    }
    
    var description: String? {
        isGerman() ? gerdescription : engdescription
    }
}

extension Character {
    enum D {
        static let table = Table("character")
        static let id = Expression<Int64>("rowid")
        static let gername = Expression<String>("gername")
        static let engname = Expression<String>("engname")
        static let group = Expression<String>("group")
        static let weight = Expression<Int64>("weight")
        static let single = Expression<Bool>("single")
        static let gerdescription = Expression<String?>("gerdescription")
        static let engdescription = Expression<String?>("engdescription")
    }

    static func charactersQuery(number: Int, query: [(Int64, Float)], searchQuery: String?) -> (String, [Binding?]) {
        let selectedCharacters = query.map({_ in  "SELECT ? AS id, ? AS weight" }).joined(separator: " UNION ALL ")
        let querySyntax = """
SELECT *, sum(inner_distance) / CAST(? AS REAL) AS distance FROM (SELECT
character_species.species_id AS species_id,
female,
character.rowid AS character_id,
species.*,
(sum(abs(selected.weight - character_species.weight)) / 2.0) * character.weight AS inner_distance
FROM character_value_species AS character_species
JOIN character_value ON character_value.rowid = character_species.character_value_id
JOIN character ON character.rowid = character_value.character_id
JOIN (\(selectedCharacters)) AS selected ON selected.id = character_value.rowid
JOIN species ON character_species.species_id = species.rowid
WHERE
    ? IS NULL
OR (
    (? = 1 AND (species.gername LIKE ? OR species.gersynonym LIKE ?))
    OR (? = 2 AND (species.engname LIKE ? OR species.engsynonym LIKE ?))
    OR species.sciname LIKE ?
)
GROUP BY species_id, female, character_id)
GROUP BY species_id, female
HAVING ROUND(distance) < 75
ORDER BY distance
"""
        let numberOfCharacters: Binding = number
        let characterValueWeights: [Binding] = query.flatMap { id, weight in
            let binding: [Binding] = [id, Double(weight)]
            return binding
        }
        let args: [Binding?] = [
            numberOfCharacters
        ] + characterValueWeights + [
            searchQuery,
            getLanguageId(),
            searchQuery,
            searchQuery,
            getLanguageId(),
            searchQuery,
            searchQuery,
            searchQuery
        ]

        return (querySyntax, args)
    }
}

extension Character {
    static let sampleData = Character(
        id: 1,
        gername: "Farbe",
        engname: "Color",
        group: Group.groups[0].id,
        weight: 1,
        single: true,
        gerdescription: "Verschiedene Farben",
        engdescription: "Different colors"
    )
}
