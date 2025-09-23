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
}

struct NamedGroup: Identifiable, Hashable {
    let id: String
    let groupType: GroupType?
    let gername: String
    let engname: String
    var name: String {
        return isGerman() ? gername : engname
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
    
    var mapIcon: String {
        switch(self.id) {
        case "acarida":
            return "map_spiders"
        case "actinopterygii":
            return "map_fish"
        case "amphibian":
            return "map_amphibian"
        case "amphipoda":
            return "map_crustaceans"
        case "anaspidea":
            return "map_gastropoda"
        case "arachnid":
            return "map_spiders"
        case "araneae":
            return "map_spiders"
        case "bird":
            return "map_bird"
        case "blattodea":
            return "map_insects"
        case "branchiobdellida":
            return "map_ringworm"
        case "branchiopoda":
            return "map_crustaceans"
        case "bug":
            return "map_insects"
        case "butterfly":
            return "map_insects"
        case "cephalaspidea":
            return "map_gastropoda"
        case "chilopoda":
            return "map_centipede"
        case "coleoptera":
            return "map_insects"
        case "conifer":
            return "map_tree"
        case "crustacea":
            return "map_crustaceans"
        case "dermaptera":
            return "map_insects"
        case "diplopoda":
            return "map_centipede"
        case "diptera":
            return "map_insects"
        case "dragonfly":
            return "map_insects"
        case "ephemeroptera":
            return "map_insects"
        case "gastropoda":
            return "map_gastropoda"
        case "grasshopper":
            return "map_insects"
        case "herb":
            return "map_herb"
        case "heteroptera":
            return "map_insects"
        case "hirudinea":
            return "map_ringworm"
        case "hydrachnidia":
            return "map_spiders"
        case "hymenoptera":
            return "map_insects"
        case "lepidoptera":
            return "map_insects"
        case "mammal":
            return "map_mammal"
        case "mantodea":
            return "map_insects"
        case "maxillopoda":
            return "map_crustaceans"
        case "mecoptera":
            return "map_insects"
        case "megaloptera":
            return "map_insects"
        case "neuroptera":
            return "map_insects"
        case "odonata":
            return "map_insects"
        case "oligochaeta":
            return "map_ringworm"
        case "planipennia":
            return "map_insects"
        case "plecoptera":
            return "map_insects"
        case "polychaeta":
            return "map_ringworm"
        case "psocoptera":
            return "map_insects"
        case "raphidioptera":
            return "map_insects"
        case "reptile":
            return "map_reptile"
        case "strigeida":
            return "map_bird"
        case "terebellida":
            return "map_ringworm"
        case "thysanoptera":
            return "map_insects"
        case "tree":
            return "map_tree"
        case "trichoptera":
            return "map_insects"
        case "truebug":
            return "map_insects"
        case "zygentoma":
            return "map_insects"
        default:
            return "map_nbobs"
        }
    }
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
