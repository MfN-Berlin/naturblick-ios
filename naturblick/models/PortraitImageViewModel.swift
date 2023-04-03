//
// Copyright © 2023 Museum für Naturkunde Berlin.
// All Rights Reserved.


import Foundation
import SQLite

class PortraitImageViewModel: ObservableObject {

    @Published private(set) var image: PortraitImage? = nil

    private static func query(portraitImgId: Int64) -> QueryType {
        return PortraitImage.Definition.table
            .filter(PortraitImage.Definition.portraitImageId == portraitImgId)
            .order(PortraitImage.Definition.width.asc)
        }

    func filter(portraitImgId: Int64) {
            guard let path = Bundle.main.path(forResource: "strapi-db", ofType: "sqlite3") else {
                preconditionFailure("Failed to find database file")
            }

            do {
                let speciesDb = try Connection(path, readonly: true)

                let imageWithSizes = try speciesDb.prepareRowIterator(
                    PortraitImageViewModel.query(portraitImgId: portraitImgId)
                )
                .map { row in
                    PortraitImage(
                        width: row[PortraitImage.Definition.width],
                        height: row[PortraitImage.Definition.height],
                        url: row[PortraitImage.Definition.url]
                    )
                }
                image = imageWithSizes.last
            } catch {
                preconditionFailure(error.localizedDescription)
            }
        }
    }
