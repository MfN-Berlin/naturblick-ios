import Foundation

enum GroupType {
    case fauna
    case flora
}

struct Group: Identifiable, Hashable {
    let id: String
    let groupType: GroupType
    let gerName: String
    let image: String
    let engName: String
}

extension Group {
    static let groups: [Group] = [
        Group(id: "amphibian", groupType: GroupType.fauna, gerName: "Amphibien", image: "group_amphibian", engName: "Amphibians"),
        Group(
            id: "hymenoptera",
            groupType: GroupType.fauna,
            gerName: "Bienen, Wespen & Co",
            image: "group_hymenoptera",
            engName: "Bees, wasps & co"
        ),
        Group(id: "conifer", groupType: GroupType.flora, gerName: "Nadelbäume", image: "group_conifer", engName: "Evergreens"),
        Group(id: "herb", groupType: GroupType.flora, gerName: "Kräuter & Wildblumen", image: "group_herb", engName: "Herbs & Wild Flowers"),
        Group(id: "tree", groupType: GroupType.flora, gerName: "Laubbäume & Gingko", image: "group_tree", engName: "Deciduous trees & gingko"),
        Group(id: "reptile", groupType: GroupType.fauna, gerName: "Reptilien", image: "group_reptile", engName: "Reptiles"),
        Group(id: "butterfly", groupType: GroupType.fauna, gerName: "Schmetterlinge", image: "group_butterfly", engName: "Butterflies"),
        Group(id: "gastropoda", groupType: GroupType.fauna, gerName: "Schnecken", image: "group_snail", engName: "Slugs"),
        Group(id: "mammal", groupType: GroupType.fauna, gerName: "Säugetiere", image: "group_mammal", engName: "Mammals"),
        Group(id: "bird", groupType: GroupType.fauna, gerName: "Vögel", image: "group_bird", engName: "Birds")
    ]
    private static let characterGroupIds = [
        "amphibian",
        "hymenoptera",
        "herb",
        "tree",
        "reptile",
        "butterfly",
        "mammal",
        "bird"
    ]
    
    static let characterGroups = groups.filter( { characterGroupIds.contains($0.id) } )
    
}

extension String {
    var isPlant: Bool {
        self == "herb" || self == "tree" || self == "conifer"
    }
    
    var mapIcon: String {
        switch(self) {
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
/*
Pair("acarida", R.drawable.ic_spiders),
            Pair("actinopterygii", R.drawable.ic_fish),
            Pair("amphibian", R.drawable.ic_amphibian),
            Pair("amphipoda", R.drawable.ic_crustaceans),
            Pair("anaspidea", R.drawable.ic_gastropoda),
            Pair("arachnid", R.drawable.ic_spiders),
            Pair("araneae", R.drawable.ic_spiders),
            Pair("bird", R.drawable.ic_bird),
            Pair("blattodea", R.drawable.ic_insects),
            Pair("branchiobdellida", R.drawable.ic_ringworm),
            Pair("branchiopoda", R.drawable.ic_crustaceans),
            Pair("bug", R.drawable.ic_insects),
            Pair("butterfly", R.drawable.ic_insects),
            Pair("cephalaspidea", R.drawable.ic_gastropoda),
            Pair("chilopoda", R.drawable.ic_centipede),
            Pair("coleoptera", R.drawable.ic_insects),
            Pair("conifer", R.drawable.ic_tree),
            Pair("crustacea", R.drawable.ic_crustaceans),
            Pair("dermaptera", R.drawable.ic_insects),
            Pair("diplopoda", R.drawable.ic_centipede),
            Pair("diptera", R.drawable.ic_insects),
            Pair("dragonfly", R.drawable.ic_insects),
            Pair("ephemeroptera", R.drawable.ic_insects),
            Pair("gastropoda", R.drawable.ic_gastropoda),
            Pair("grasshopper", R.drawable.ic_insects),
            Pair("herb", R.drawable.ic_herb),
            Pair("heteroptera", R.drawable.ic_insects),
            Pair("hirudinea", R.drawable.ic_ringworm),
            Pair("hydrachnidia", R.drawable.ic_spiders),
            Pair("hymenoptera", R.drawable.ic_insects),
            Pair("lepidoptera", R.drawable.ic_insects),
            Pair("mammal", R.drawable.ic_mammal),
            Pair("mantodea", R.drawable.ic_insects),
            Pair("maxillopoda", R.drawable.ic_crustaceans),
            Pair("mecoptera", R.drawable.ic_insects),
            Pair("megaloptera", R.drawable.ic_insects),
            Pair("neuroptera", R.drawable.ic_insects),
            Pair("odonata", R.drawable.ic_insects),
            Pair("oligochaeta", R.drawable.ic_ringworm),
            Pair("planipennia", R.drawable.ic_insects),
            Pair("plecoptera", R.drawable.ic_insects),
            Pair("polychaeta", R.drawable.ic_ringworm),
            Pair("psocoptera", R.drawable.ic_insects),
            Pair("raphidioptera", R.drawable.ic_insects),
            Pair("reptile", R.drawable.ic_reptile),
            Pair("strigeida", R.drawable.ic_bird),
            Pair("terebellida", R.drawable.ic_ringworm),
            Pair("thysanoptera", R.drawable.ic_insects),
            Pair("tree", R.drawable.ic_tree),
            Pair("trichoptera", R.drawable.ic_insects),
            Pair("truebug", R.drawable.ic_insects),
            Pair("zygentoma", R.drawable.ic_insects)
*/
