//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI


struct ObservationListItemView: View {
    let observation: Observation
    let image: Image
    var body: some View {
        HStack(alignment: .top) {
            image
                .resizable()
                .scaledToFit()
                .clipShape(Circle())
                .frame(width: .avatarSize, height: .avatarSize)
                .padding(.trailing, .defaultPadding)
            VStack(alignment: .leading) {
                if let name = observation.species?.gername {
                    Text(name)
                        .subtitle1()
                } else {
                    Text(observation.species?.sciname ?? "No species")
                        .subtitle1()
                }
                Text(observation.observation.created.date.formatted())
                    .subtitle3()
                if let details = observation.observation.details {
                    Text(details)
                }
            }
            .padding(.top, .avatarTextOffset)
        }
    }
}


struct ObservationListItemView_Previews: PreviewProvider {
    static var previews: some View {
        ObservationListItemView(observation: Observation(observation: DBObservation.sampleData, species: Species.sampleData),
            image: Image("placeholder")
        )
    }
}
