//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import Foundation
import SQLite

class PortraitViewModel: ObservableObject {
    
    @Published private(set) var portrait: Portrait?
    
    static let descImg = PortraitImageMeta.Definition.table.alias("descImg")
    static let cityImg = PortraitImageMeta.Definition.table.alias("cityImg")
    static let goodImg = PortraitImageMeta.Definition.table.alias("goodImg")
    
    private static func query(speciesId: Int64) -> QueryType {
        return Portrait.Definition.table
            .join(
                .leftOuter,
                descImg,
                on: descImg[PortraitImageMeta.Definition.id] == Portrait.Definition.descriptionImage
            )
            .join(
                .leftOuter,
                cityImg,
                on: cityImg[PortraitImageMeta.Definition.id] == Portrait.Definition.intTheCityImage
            )
            .join(
                .leftOuter,
                goodImg,
                on: goodImg[PortraitImageMeta.Definition.id] == Portrait.Definition.goodToKnowImage
            )
            .filter(Portrait.Definition.species == speciesId)
            .filter(Portrait.Definition.language == 1) // Only in german to start with
        }
        
        func filter(speciesId: Int64) {
            guard let path = Bundle.main.path(forResource: "strapi-db", ofType: "sqlite3") else {
                preconditionFailure("Failed to find database file")
            }
            
            do {
                
                let speciesDb = try Connection(path, readonly: true)
                portrait = try speciesDb.pluck(
                    PortraitViewModel.query(speciesId: speciesId)
                )
                .map { row in
                    Portrait(
                        id: row[Portrait.Definition.table[Portrait.Definition.id]],
                        species: row[Portrait.Definition.species],
                        description: row[Portrait.Definition.description],
                        descriptionImage: row[Portrait.Definition.descriptionImage] != nil
                            ? PortraitImageMeta(
                                id: row[Portrait.Definition.descriptionImage]!,
                                owner: row[PortraitViewModel.descImg[PortraitImageMeta.Definition.owner]],
                                ownerLink: row[PortraitViewModel.descImg[PortraitImageMeta.Definition.ownerLink]],
                                source: row[PortraitViewModel.descImg[PortraitImageMeta.Definition.source]],
                                text: row[PortraitViewModel.descImg[PortraitImageMeta.Definition.text]],
                                license: row[PortraitViewModel.descImg[PortraitImageMeta.Definition.license]]
                            )
                            : nil,
                        language: row[Portrait.Definition.language],
                        inTheCity: row[Portrait.Definition.inTheCity],
                        inTheCityImage: row[Portrait.Definition.intTheCityImage] != nil
                            ? PortraitImageMeta(
                                id: row[Portrait.Definition.intTheCityImage]!,
                                owner: row[PortraitViewModel.cityImg[PortraitImageMeta.Definition.owner]],
                                ownerLink: row[PortraitViewModel.cityImg[PortraitImageMeta.Definition.ownerLink]],
                                source: row[PortraitViewModel.cityImg[PortraitImageMeta.Definition.source]],
                                text: row[PortraitViewModel.cityImg[PortraitImageMeta.Definition.text]],
                                license: row[PortraitViewModel.cityImg[PortraitImageMeta.Definition.license]]
                            )
                            : nil,
                        goodToKnowImage: row[Portrait.Definition.goodToKnowImage] != nil
                            ? PortraitImageMeta(
                                id: row[Portrait.Definition.goodToKnowImage]!,
                                owner: row[PortraitViewModel.goodImg[PortraitImageMeta.Definition.owner]],
                                ownerLink: row[PortraitViewModel.goodImg[PortraitImageMeta.Definition.ownerLink]],
                                source: row[PortraitViewModel.goodImg[PortraitImageMeta.Definition.source]],
                                text: row[PortraitViewModel.goodImg[PortraitImageMeta.Definition.text]],
                                license: row[PortraitViewModel.goodImg[PortraitImageMeta.Definition.license]]
                            )
                            : nil,
                        sources: row[Portrait.Definition.sources],
                        audioUrl: row[Portrait.Definition.audioUrl],
                        landscape: row[Portrait.Definition.landscape],
                        focus: row[Portrait.Definition.focus]
                    )
                }
            } catch {
                preconditionFailure(error.localizedDescription)
            }
        }
    }
    
