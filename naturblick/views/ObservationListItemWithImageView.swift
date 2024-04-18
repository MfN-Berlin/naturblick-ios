//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import class SQLite.Connection


struct ObservationListItemWithImageView: View {
    let observation: Observation
    
    var body: some View {
        HStack {
            Thumbnail(speciesUrl: observation.species?.maleUrl, thumbnailId: observation.observation.thumbnailId) { image in
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
            observation: Observation(observation: DBObservation.sampleData, species: Species.sampleData)
        )
    }
}
