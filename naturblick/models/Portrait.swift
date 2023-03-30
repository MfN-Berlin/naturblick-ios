//
// Copyright © 2023 Museum für Naturkunde Berlin.
// All Rights Reserved.

import Foundation
import SQLite

struct Portrait {
    let id: Int64
    let species: Int64
    let description: String
    let descriptionImage: PortraitImageMeta?
    let language: Int
    let inTheCity: String
    let inTheCityImage: PortraitImageMeta?
    let goodToKnowImage:PortraitImageMeta?
    let sources: String?
    let audioUrl: String?
    let landscape: Bool
    let focus: Double
}

extension Portrait {
    struct Definition {
        static let table = Table("portrait")
        static let id = Expression<Int64>("rowid")
        static let species = Expression<Int64>("species_id")
        static let description = Expression<String>("description")
        static let descriptionImage = Expression<Int64?>("description_image_id")
        static let language = Expression<Int>("language")
        static let inTheCity = Expression<String>("in_the_city")
        static let intTheCityImage = Expression<Int64?>("in_the_city_image_id")
        static let goodToKnowImage = Expression<Int64?>("good_to_know_image_id")
        static let sources = Expression<String?>("sources")
        static let audioUrl = Expression<String?>("audio_url")

        // Focus punkt for header image ("description_image")
        static let landscape = Expression<Bool>("landscape")
        static let focus = Expression<Double>("focus")
    }
}

