//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import SQLite
import Combine

class CharactersViewModel: ObservableObject {

    @Published private(set) var characters: [(Character, [CharacterValue])] = []
    @Published var selected: Set<Int64> = []
    @Published private(set) var count: Int64 = 0
    @Published private(set) var filter: SpeciesListFilter = .characters(0, [])
    
    func initializeCharacters(group: Group) {
        do {
            let speciesDb = Connection.speciesDB
            
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
            Fail.with(error)
        }
    }
}

extension CharactersViewModel {

    private static func calculateFilter(characters: [(Character, [CharacterValue])], selected: Set<Int64>) -> (Int, [(Int64, Float)]) {
        let selectedCharacters = characters.filter { character, values in
            values.contains(where: { selected.contains($0.id) })
        }

        let query: [(Int64, Float)] = selectedCharacters.flatMap { character, values in
            let selectedValues = values.filter { selected.contains($0.id) }.count
            return values.map { value in
                if (selected.contains(value.id)) {
                    return (value.id, 100.0 / Float(selectedValues))
                } else {
                    return (value.id, 0.0)
                }
            }
        }
        return (selectedCharacters.count, query)
    }

    private static func query(group: Group) -> QueryType {
        return Character.D.table
            .join(CharacterValue.D.table,
                  on: Character.D.table[Character.D.id] == CharacterValue.D.table[CharacterValue.D.characterId])
            .filter(Character.D.group == group.id)
    }
    
    func configure(group: Group) {
        $characters
            .combineLatest($selected, CharactersViewModel.calculateFilter)
            .map { filter in
                SpeciesListFilter.characters(filter.0, filter.1)
            }
            .assign(to: &$filter)

        $characters
            .combineLatest($selected) { characters, selected in
                let (number, query) = CharactersViewModel.calculateFilter(characters: characters, selected: selected)
                guard !query.isEmpty else {
                    return 0
                }
                guard let path = Bundle.main.path(forResource: "strapi-db", ofType: "sqlite3") else {
                    Fail.with(message: "Failed to find database file")
                }

                do {
                    let speciesDb = try Connection(path, readonly: true)
                    let (querySyntax, bindings) = Character.charactersQuery(number: number, query: query, searchQuery: nil)
                    let countSyntax = "SELECT COUNT(*) FROM (\(querySyntax))"
                    return try speciesDb.prepare(countSyntax).scalar(bindings) as! Int64
                } catch {
                    Fail.with(error)
                }
            }
            .assign(to: &$count)

        initializeCharacters(group: group)
    }
}
