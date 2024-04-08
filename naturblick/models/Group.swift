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
            return "map_platform_spiders"
        case "actinopterygii":
            return "map_platform_fish"
        case "amphibian":
            return "map_platform_amphibian"
        case "amphipoda":
            return "map_platform_crustacea"
        case "anaspidea":
            return "map_platform_gastropoda"
        case "arachnid":
            return "map_platform_spiders"
        case "araneae":
            return "map_platform_spiders"
        case "bird":
            return "map_platform_bird"
        case "blattodea":
            return "map_platform_insects"
        case "branchiobdellida":
            return "map_platform_ringworm"
        case "branchiopoda":
            return "map_platform_crustaceans"
        case "bug":
            return "map_platform_insects"
        case "butterfly":
            return "map_platform_butterfly"
        case "cephalaspidea":
            return "map_platform_gastropoda"
        case "chilopoda":
            return "map_platform_centipede"
        case "coleoptera":
            return "map_platform_insects"
        case "conifer":
            return "map_platform_conifer"
        case "crustacea":
            return "map_platform_crustacea"
        case "dermaptera":
            return "map_platform_insects"
        case "diplopoda":
            return "map_platform_centipede"
        case "diptera":
            return "map_platform_insects"
        case "dragonfly":
            return "map_platform_insects"
        case "ephemeroptera":
            return "map_platform_insects"
        case "gastropoda":
            return "map_platform_gastropoda"
        case "grasshopper":
            return "map_platform_insects"
        case "herb":
            return "map_platform_plant"
        case "heteroptera":
            return "map_platform_insects"
        case "hirudinea":
            return "map_platform_ringworm"
        case "hydrachnidia":
            return "map_platform_spider"
        case "hymenoptera":
            return "map_platform_bee"
        case "lepidoptera":
            return "map_platform_insects"
        case "mammal":
            return "map_platform_mammal"
        case "mantodea":
            return "map_platform_insects"
        case "maxillopoda":
            return "map_platform_crustacea"
        case "mecoptera":
            return "map_platform_insects"
        case "megaloptera":
            return "map_platform_insects"
        case "neuroptera":
            return "map_platform_insects"
        case "odonata":
            return "map_platform_insects"
        case "oligochaeta":
            return "map_platform_ringworm"
        case "planipennia":
            return "map_platform_insects"
        case "plecoptera":
            return "map_platform_insects"
        case "polychaeta":
            return "map_platform_ringworm"
        case "psocoptera":
            return "map_platform_insects"
        case "raphidioptera":
            return "map_platform_insects"
        case "reptile":
            return "map_platform_reptile"
        case "strigeida":
            return "map_platform_birds"
        case "terebellida":
            return "map_platform_ringworm"
        case "thysanoptera":
            return "map_platform_insects"
        case "tree":
            return "map_platform_tree"
        case "trichoptera":
            return "map_platform_insects"
        case "truebug":
            return "map_platform_insects"
        case "zygentoma":
            return "map_platform_insects"
        default:
            return "map_nbobs"
        }
    }
}
