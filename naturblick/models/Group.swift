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
}

extension Group {
    static let groups: [Group] = [
        Group(id: "amphibian", groupType: GroupType.fauna, gerName: "Amphibien", image: "group_amphibian"),
        Group(
            id: "hymenoptera",
            groupType: GroupType.fauna,
            gerName: "Bienen, Wespen & Co",
            image: "group_hymenoptera"
        ),
        Group(id: "conifer", groupType: GroupType.flora, gerName: "Nadelbäume", image: "group_conifer"),
        Group(id: "herb", groupType: GroupType.flora, gerName: "Kräuter & Wildblumen", image: "group_herb"),
        Group(id: "tree", groupType: GroupType.flora, gerName: "Laubbäume & Gingko", image: "group_tree"),
        Group(id: "reptile", groupType: GroupType.fauna, gerName: "Reptilien", image: "group_reptile"),
        Group(id: "butterfly", groupType: GroupType.fauna, gerName: "Schmetterlinge", image: "group_butterfly"),
        Group(id: "gastropoda", groupType: GroupType.fauna, gerName: "Schnecken", image: "group_snail"),
        Group(id: "mammal", groupType: GroupType.fauna, gerName: "Säugetiere", image: "group_mammal"),
        Group(id: "bird", groupType: GroupType.fauna, gerName: "Vögel", image: "group_bird")
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
}
