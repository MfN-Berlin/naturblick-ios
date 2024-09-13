//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import class SQLite.Connection


struct ObservationListItemWithImageView: View {
    let observation: Observation
    let backend: Backend
    let editMode: EditMode
    
    var body: some View {
        HStack {
            Thumbnail(occurenceId: observation.id, backend: backend, speciesUrl: observation.species?.maleUrl, thumbnailId: observation.observation.thumbnailId, obsIdent: observation.observation.obsIdent) { image in
                ObservationListItemView(observation: observation, image: image)
            }
            if (editMode == .inactive) {
                ChevronView(color: .onPrimarySignalLow)
            }
       }
       .listRowBackground(Color.secondaryColor)
    }
}


struct ObservationListItemWithImageView_Previews: PreviewProvider {
    static var previews: some View {
        ObservationListItemWithImageView(
            observation: Observation(observation: DBObservation.sampleData, species: Species.sampleData),
            backend: Backend(persistence: ObservationPersistenceController(inMemory: true)),
            editMode: EditMode.inactive
        )
    }
}
