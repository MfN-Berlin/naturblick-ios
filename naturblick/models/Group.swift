import Foundation
import SQLite

enum GroupType {
    case fauna
    case flora
}
extension GroupType {
    init?(nature: String?) {
        switch(nature) {
        case "fauna": self = .fauna
        case "flora": self = .flora
        default: return nil
        }
    }
}

struct Group: Identifiable, Equatable {
    let id: String
    let groupType: GroupType?
    var mapIcon: String {
        "map_\(id)"
    }
}

struct NamedGroup: Identifiable, Hashable {
    let id: String
    let groupType: GroupType?
    let gername: String
    let engname: String
    var name: String {
        return isGerman() ? gername : engname
    }
    var image: String {
        "group_\(id)"
    }
}

extension Group {
    struct Definition {
        static let table = Table("groups")
        
        static let name = Expression<String>("name")
        static let nature = Expression<String?>("nature")
        static let gername = Expression<String?>("gername")
        static let engname = Expression<String?>("engname")
        static let hasPortraits = Expression<Bool>("has_portraits")
        static let isFieldbookfilter = Expression<Bool>("is_fieldbookfilter")
        static let hasCharacters = Expression<Bool>("has_characters")
    }
    
    static func fromRow(row: Row) -> Group {
        return Group(
            id: row[Definition.table[Group.Definition.name]],
            groupType: GroupType(nature: row[Definition.table[Group.Definition.nature]])
        )
    }
    
    static let exampleData = Group(id: "amphibian", groupType: GroupType.fauna)
    
}

extension NamedGroup {
    static func fromRow(row: Row) -> NamedGroup {
        return NamedGroup(
            id: row[Group.Definition.name],
            groupType: GroupType(nature: row[Group.Definition.nature]),
            gername: row[Group.Definition.gername]!,
            engname: row[Group.Definition.engname]!
        )
    }
    
    static let exampleData = NamedGroup(id: "amphibian", groupType: GroupType.fauna, gername: "Amphibien", engname: "Amphibians")

    static func fieldBookFilter() -> [NamedGroup] {
        try! Connection.speciesDB.prepareRowIterator(Group.Definition.table.select(*).filter(Group.Definition.isFieldbookfilter)).map { row in
            NamedGroup.fromRow(row: row)
        }
    }

    static func withPortraits() -> [NamedGroup] {
        try! Connection.speciesDB.prepareRowIterator(Group.Definition.table.select(*).filter(Group.Definition.hasPortraits)).map { row in
            NamedGroup.fromRow(row: row)
        }
    }

    static func withCharacters() -> [NamedGroup] {
        try! Connection.speciesDB.prepareRowIterator(Group.Definition.table.select(*).filter(Group.Definition.hasCharacters)).map { row in
            NamedGroup.fromRow(row: row)
        }
    }
}
