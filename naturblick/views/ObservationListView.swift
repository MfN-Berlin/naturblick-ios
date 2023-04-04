//
// Copyright © 2023 Museum für Naturkunde Berlin.
// All Rights Reserved.


import SwiftUI

struct ObservationListView: View {
    let observations: [ObservationListItem]

    var body: some View {
        List(observations) { observation in
            if let url = observation.species.url {
                // When used, AsyncImage has to be the outermost element
                // or it will not properly load in List
                AsyncImage(url: URL(string: Configuration.strapiUrl + url)!) { image in
                    ObservationListItemView(observation: observation, avatar: image)
                } placeholder: {
                    ObservationListItemView(observation: observation, avatar: Image("placeholder"))
                }
                .listRowInsets(.nbInsets)
            } else {
                ObservationListItemView(observation: observation, avatar: Image("placeholder"))
                    .listRowInsets(.nbInsets)
            }
        }
        .navigationTitle("Feldbuch")
    }
}

struct ObservationListView_Previews: PreviewProvider {
    static var previews: some View {
        ObservationListView(observations: [ObservationListItem.sampleData])
    }
}
