//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import class SQLite.Connection


struct ObservationListItemWithImageView: View {
    let observation: Observation
    let persistenceController: ObservationPersistenceController
    var body: some View {
        HStack {
            Thumbnail(occurenceId: observation.id, persistenceController: persistenceController, speciesUrl: observation.species?.maleUrl, thumbnailId: observation.observation.thumbnailId, obsIdent: observation.observation.obsIdent) { image in
                ObservationListItemView(observation: observation, image: image)
            }
            ChevronView(color: .onPrimarySignalLow)
       }
       .listRowBackground(Color.secondaryColor)
    }
}


struct ObservationListItemWithImageView_Previews: PreviewProvider {
    static var previews: some View {
        ObservationListItemWithImageView(
            observation: Observation(observation: DBObservation.sampleData, species: Species.sampleData),
            persistenceController: ObservationPersistenceController(inMemory: true)
        )
    }
}
