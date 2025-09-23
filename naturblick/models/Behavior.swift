//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation

enum Behavior: String, Identifiable, Codable, CaseIterable {
    var id: Behavior {
        self
    }
    case notSet = ""
    case plantLosingLeafs = "Blätter abwerfend"
    case plantBlooming = "blühend"
    case plantCarryingFruits = "Früchte tragend"
    case plantWithBuds = "knospend"
    case plantNewShoots = "neue Triebe"
    case plantWithered = "verblüht"
    case animalOnAFlower = "an einer Blüte"
    case animalNest = "Bau/Nest"
    case animalBiteMarks = "Fraßspuren"
    case animalShell = "Gehäuse/Schale"
    case animalOrPlantInside = "in Gebäude"
    case animalCadaver = "Kadaver (Totes Tier)"
    case animalCocoon = "Kokon"
    case animalFeces = "Kot"
    case animalEggs = "Laich/Eier"
    case animalCall = "Laut/Gesang/Ruf"
    case animalTrack = "Spur"
}

extension [Behavior] {
    static let forPlants: [Behavior] = [
        .notSet,
        .plantLosingLeafs,
        .plantBlooming,
        .plantCarryingFruits,
        .plantWithBuds,
        .plantNewShoots,
        .plantWithered,
        .animalOrPlantInside
    ]
    
    static let forAnimals: [Behavior] = [
        .notSet,
        .animalOnAFlower,
        .animalNest,
        .animalBiteMarks,
        .animalShell,
        .animalOrPlantInside,
        .animalCadaver,
        .animalCocoon,
        .animalFeces,
        .animalEggs,
        .animalCall,
        .animalTrack
    ]
    static func forGroup(group: Group?) -> [Behavior] {
        switch(group?.groupType) {
        case .fauna: return forPlants
        case .flora: return forAnimals
        default: return Behavior.allCases
        }
    }
}
