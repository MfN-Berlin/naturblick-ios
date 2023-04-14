//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import SQLite

class ObservationListViewModel: ObservableObject {
    @Published private(set) var observations: [ObservationListItem] = []
    @Published private(set) var error: HttpError? = nil
    @Published var errorIsPresented: Bool = false

    private let client = BackendClient()

    func refresh() {
        guard let path = Bundle.main.path(forResource: "strapi-db", ofType: "sqlite3") else {
            preconditionFailure("Failed to find database file")
        }
        assignError(publisher: client.sync(), errorIsPresented: &$errorIsPresented, error: &$error)
            .map { response in
                let observations = response.data
                let speciesArray: [Int64] = observations.compactMap { observation in
                    guard let species = observation.newSpeciesId else {
                        return nil
                    }
                    return Int64(species)
                }

                do {
                    let db = try Connection(path, readonly: true)
                    let speciesListItems = try db.prepareRowIterator(
                        Species.Definition.table.filter(speciesArray.contains(Species.Definition.id))
                    )
                        .map { row in
                            SpeciesListItem(
                                speciesId: row[Species.Definition.id],
                                sciname: row[Species.Definition.sciname],
                                gername: row[Species.Definition.gername],
                                maleUrl: row[Species.Definition.maleUrl],
                                femaleUrl: row[Species.Definition.femaleUrl],
                                gersynonym: row[Species.Definition.gersynonym],
                                isFemale: nil
                            )
                        }
                        .reduce(into: [Int: SpeciesListItem]()) { acc, e in
                            acc[Int(e.speciesId)] = e
                        }
                    return observations.map { observation in
                        guard let speciesId = observation.newSpeciesId else {
                            return ObservationListItem(id: observation.occurenceId, species: nil, time: observation.created.date)
                        }
                        return ObservationListItem(id: observation.occurenceId, species: speciesListItems[speciesId], time: observation.created.date)
                    }
                } catch {
                    preconditionFailure(error.localizedDescription)
                }
            }
            .receive(on: RunLoop.main)
            .assign(to: &$observations)
    }
}
