//
// Copyright © 2023 Museum für Naturkunde Berlin.
// All Rights Reserved.


import Foundation
import SQLite
class CharactersViewModel: ObservableObject {

    @Published private(set) var characters = [(Character, [CharacterValue])]()
    
    private static func query(group: Group) -> QueryType {
        return Character.D.table
            .join(CharacterValue.D.table,
                  on: Character.D.table[Character.D.id] == CharacterValue.D.table[CharacterValue.D.characterId])
            .filter(Character.D.group == group.id)
    }
    
    func filter(group: Group) {
        guard let path = Bundle.main.path(forResource: "strapi-db", ofType: "sqlite3") else {
            preconditionFailure("Failed to find database file")
        }
        
        do {
            let speciesDb = try Connection(path, readonly: true)
            
            let characters: [(Character, [CharacterValue])] = try Dictionary(
                grouping: speciesDb.prepare(CharactersViewModel.query(group: group)),
                by: { $0[Character.D.table[Character.D.id]]}
            )
                .map { id, rows in
                    let character = Character(
                        id: id,
                        gername: rows[0][Character.D.table[Character.D.gername]],
                        engname: rows[0][Character.D.table[Character.D.engname]],
                        group: group.id,
                        weight: rows[0][Character.D.table[Character.D.id]],
                        single: rows[0][Character.D.table[Character.D.single]],
                        gerdescription: rows[0][Character.D.table[Character.D.gerdescription]],
                        engdescription: rows[0][Character.D.table[Character.D.engdescription]]
                    )
                    let values = rows
                        .map { row in
                            CharacterValue(
                                id: row[CharacterValue.D.table[CharacterValue.D.id]],
                                characterId: id,
                                gername: row[CharacterValue.D.table[CharacterValue.D.gername]],
                                engname: row[CharacterValue.D.table[CharacterValue.D.engname]],
                                hasImage: row[CharacterValue.D.table[CharacterValue.D.hasImage]]
                            )
                        }
                        .sorted { c1, c2 in
                            c1.id < c2.id
                        }
                    return (character, values)
                }
                .sorted(by: { c1, c2 in
                    c1.0.id < c2.0.id
                })

            self.characters = characters
        } catch {
            preconditionFailure(error.localizedDescription)
        }
    }
}

