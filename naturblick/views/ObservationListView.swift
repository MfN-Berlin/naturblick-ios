//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct ObservationListView: View {
    @StateObject var observationListViewModel = ObservationListViewModel()
    var body: some View {
        List(observationListViewModel.observations) { observation in
            if let url = observation.species?.url {
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
        .onAppear {
            observationListViewModel.refresh()
        }
        .navigationTitle("Feldbuch")
        .alertHttpError(
            isPresented: $observationListViewModel.errorIsPresented,
            error: observationListViewModel.error
        )
    }
}

struct ObservationListView_Previews: PreviewProvider {
    static var previews: some View {
        ObservationListView()
    }
}
