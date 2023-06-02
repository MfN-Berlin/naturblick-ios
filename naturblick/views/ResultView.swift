//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import SQLite

struct ResultView: SwiftUI.View {
    
    @Environment(\.dismiss) var dismiss
    
    @SwiftUI.Binding var imageIdState: ImageIdState
    @SwiftUI.Binding var data: CreateData
    
    @State var species: [Species]? = nil
      
    func setSpeciesResult(results: [SpeciesResult]) {
      guard let path = Bundle.main.path(forResource: "strapi-db", ofType: "sqlite3") else {
          preconditionFailure("Failed to find database file")
      }
      
      let ids = results.map { $0.id }
      
      do {
          let speciesDb = try Connection(path, readonly: true)
          let query = Species.Definition.table
              .filter(ids.contains(Species.Definition.id))
          
          do {
              species = try speciesDb.prepareRowIterator(query).map { row in
                  Species(id: row[Species.Definition.id],
                          group: row[Species.Definition.group],
                          sciname: row[Species.Definition.sciname],
                          gername: row[Species.Definition.gername],
                          engname: row[Species.Definition.engname],
                          wikipedia: row[Species.Definition.wikipedia],
                          maleUrl: row[Species.Definition.maleUrl],
                          femaleUrl: row[Species.Definition.femaleUrl],
                          gersynonym: row[Species.Definition.gersynonym],
                          engsynonym: row[Species.Definition.engsynonym],
                          redListGermany: row[Species.Definition.redListGermany],
                          iucnCategory: row[Species.Definition.iucnCategory])
              }
          } catch {
              preconditionFailure(error.localizedDescription)
          }
      } catch {
          preconditionFailure(error.localizedDescription)
      }
    }
      
    
    var body: some SwiftUI.View {
        BaseView {
            VStack {
                if let species = species {
                    ForEach(species) { species in
                        Button {
                            data.species = species
                            dismiss()
                        } label: {
                            Text(species.sciname)
                                .padding()
                        }.frame(width: UIScreen.main.bounds.width)
                            .padding(.horizontal, -32)
                            .background(Color.onSecondaryButtonPrimary)
                            .clipShape(Capsule())
                            .padding()
                    }
                    Button {
                        dismiss()
                    } label: {
                        Text("ohne Art speichern")
                            .padding()
                    }.frame(width: UIScreen.main.bounds.width)
                        .padding(.horizontal, -32)
                        .background(Color.onSecondaryButtonPrimary)
                        .clipShape(Capsule())
                        .padding()
                }
            }
        }
        .task {
            if let img = data.crop {
                do {
                    data.mediaId = UUID()
                    if let mediaId = data.mediaId?.uuidString {
                        try await BackendClient().upload(img: img, mediaId: mediaId)
                        setSpeciesResult(results: try await BackendClient().imageId(mediaId: mediaId))
                    }
                } catch {
                    fatalError(error.localizedDescription)
                }
            }
        }
    }
}
