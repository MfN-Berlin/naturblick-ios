//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import class SQLite.Connection


struct ObservationListItemWithImageView: View {
    @StateObject var model = ObservationListItemWithImageViewModel()
    let observation: Observation

    var body: some View {
        AsyncImage(url: model.url) { image in
            ObservationListItemView(observation: observation, species: model.species, image: image)
        } placeholder: {
            ObservationListItemView(observation: observation, species: model.species, image: Image("placeholder"))
        }
        .task {
            await model.load(observation: observation)
        }
    }
}


struct ObservationListItemWithImageView_Previews: PreviewProvider {
    static var previews: some View {
        ObservationListItemWithImageView(
            observation: Observation.sampleData
        )
    }
}
