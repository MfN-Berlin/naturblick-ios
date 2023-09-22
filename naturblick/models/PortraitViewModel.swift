//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import Foundation
import SQLite

class PortraitViewModel: ObservableObject {
    
    @Published private(set) var portrait: Portrait?
    
    static let descImg = PortraitImage.Definition.table.alias("desc_img")
    static let cityImg = PortraitImage.Definition.table.alias("city_img")
    static let goodImg = PortraitImage.Definition.table.alias("good_img")
    
    static let descImgSizes = PortraitImageSize.Definition.table.alias("desc_img_size")
    static let cityImgSizes = PortraitImageSize.Definition.table.alias("city_img_size")
    static let goodImgSizes = PortraitImageSize.Definition.table.alias("good_img_size")
    
    private static func query(speciesId: Int64) -> QueryType {
        return Portrait.Definition.table
            .join(
                .leftOuter,
                Species.Definition.table,
                on: Species.Definition.table[Species.Definition.id] == Portrait.Definition.speciesId
            )
            .join(
                .leftOuter,
                descImg,
                on: descImg[PortraitImage.Definition.id] == Portrait.Definition.descriptionImage
            )
            .join(
                .leftOuter,
                descImgSizes,
                on: descImgSizes[PortraitImageSize.Definition.portraitImageId] == Portrait.Definition.descriptionImage
            )
            .join(
                .leftOuter,
                cityImg,
                on: cityImg[PortraitImage.Definition.id] == Portrait.Definition.intTheCityImage
            )
            .join(
                .leftOuter,
                cityImgSizes,
                on: cityImgSizes[PortraitImageSize.Definition.portraitImageId] == Portrait.Definition.intTheCityImage
            )
            .join(
                .leftOuter,
                goodImg,
                on: goodImg[PortraitImage.Definition.id] == Portrait.Definition.goodToKnowImage
            )
            .join(
                .leftOuter,
                goodImgSizes,
                on: goodImgSizes[PortraitImageSize.Definition.portraitImageId] == Portrait.Definition.goodToKnowImage
            )
            .join(
                .leftOuter,
                Portrait.Definition.gtkTable,
                on: Portrait.Definition.table[Portrait.Definition.id] == Portrait.Definition.gtkTable[Portrait.Definition.gtkPortraitId]
            )
            .filter(Portrait.Definition.speciesId == speciesId)
            .filter(Portrait.Definition.language == 1) // Only in german to start with
        }
         
    private func portraitImage(imgTable: Table, sizesTable: Table, rows: [Row]) -> PortraitImage? {
        Dictionary(grouping: rows, by: { $0[sizesTable[PortraitImageSize.Definition.portraitImageIdOpt]] })
            .compactMap { imageIdOpt, imageRows in
                guard let imageId = imageIdOpt else {
                    return nil
                }
                let sizes: [PortraitImageSize] = Dictionary(grouping: imageRows, by: { $0[sizesTable[PortraitImageSize.Definition.width]]})
                    .map { width, sizeRows in
                        let row = sizeRows[0]
                        return PortraitImageSize(
                            width: width,
                            height: row[sizesTable[PortraitImageSize.Definition.height]],
                            url: row[sizesTable[PortraitImageSize.Definition.url]]
                        )
                    }
            let row = imageRows[0]
            return PortraitImage(
                id: imageId,
                owner: row[imgTable[PortraitImage.Definition.owner]],
                ownerLink: row[imgTable[PortraitImage.Definition.ownerLink]],
                source: row[imgTable[PortraitImage.Definition.source]],
                text: row[imgTable[PortraitImage.Definition.text]],
                license: row[imgTable[PortraitImage.Definition.license]],
                sizes: sizes
            )
            }.first
    }
    
    private func goodToKnows(rows: [Row]) -> [String] {
        Dictionary(grouping: rows, by: { $0[Portrait.Definition.gtkTable[Portrait.Definition.gtkFact]] })
            .compactMap { factOpt, rows in
                factOpt
            }
    }
    
    func filter(speciesId: Int64) {
        do {
            
            let speciesDb = Connection.speciesDB
            let souresTranslations = try Dictionary(speciesDB: speciesDb, language: 1)
            let result = try speciesDb.prepare(
                PortraitViewModel.query(speciesId: speciesId)
            )
            
            portrait = Dictionary(grouping: result, by: { $0[Portrait.Definition.table[Portrait.Definition.id]] })
                .map { portraitId, rows in
                    let row = rows[0]
                    return Portrait(
                        id: row[Portrait.Definition.table[Portrait.Definition.id]],
                        species: Species(
                            id: row[Portrait.Definition.speciesId],
                            group: row[Species.Definition.table[Species.Definition.group]],
                            sciname: row[Species.Definition.table[Species.Definition.sciname]],
                            gername: row[Species.Definition.table[Species.Definition.gername]],
                            engname: row[Species.Definition.table[Species.Definition.engname]],
                            wikipedia: row[Species.Definition.table[Species.Definition.wikipedia]],
                            maleUrl: row[Species.Definition.table[Species.Definition.maleUrl]],
                            femaleUrl: row[Species.Definition.table[Species.Definition.femaleUrl]],
                            gersynonym: row[Species.Definition.table[Species.Definition.gersynonym]],
                            engsynonym: row[Species.Definition.table[Species.Definition.engsynonym]],
                            redListGermany: row[Species.Definition.table[Species.Definition.redListGermany]],
                            iucnCategory: row[Species.Definition.table[Species.Definition.iucnCategory]],
                            hasPortrait: true
                        ),
                        description: row[Portrait.Definition.description],
                        descriptionImage: portraitImage(imgTable: PortraitViewModel.descImg, sizesTable: PortraitViewModel.descImgSizes, rows: rows),
                        language: row[Portrait.Definition.language],
                        inTheCity: row[Portrait.Definition.inTheCity],
                        inTheCityImage: portraitImage(imgTable: PortraitViewModel.cityImg, sizesTable: PortraitViewModel.cityImgSizes, rows: rows),
                        goodToKnowImage: portraitImage(imgTable: PortraitViewModel.goodImg, sizesTable: PortraitViewModel.goodImgSizes, rows: rows),
                        sources: souresTranslations.replaceAll(text:row[Portrait.Definition.sources]),
                        audioUrl: row[Portrait.Definition.audioUrl],
                        landscape: row[Portrait.Definition.landscape],
                        focus: row[Portrait.Definition.focus],
                        goodToKnows: goodToKnows(rows: rows)
                    )
                }.first
        } catch {
            preconditionFailure(error.localizedDescription)
        }
    }
}

