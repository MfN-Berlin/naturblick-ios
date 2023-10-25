//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI


struct ObservationListItemView: View {
    let observation: Observation
    let image: Image
    var body: some View {
        HStack(alignment: .top, spacing: .zero) {
            image
                .avatar()
                .padding(.trailing, .defaultPadding)
            VStack(alignment: .leading, spacing: .zero) {
                if let name = observation.species?.speciesName {
                    Text(name)
                        .subtitle1()
                } else {
                    Text(observation.species?.sciname ?? String(localized: "no_species"))
                        .subtitle1()
                }
                Text(observation.observation.created.date.formatted())
                    .subtitle3()
            }
            .padding(.top, .avatarTextOffset)
            Spacer()
        }
        .contentShape(Rectangle())
    }
}


struct ObservationListItemView_Previews: PreviewProvider {
    static var previews: some View {
        ObservationListItemView(observation: Observation(observation: DBObservation.sampleData, species: Species.sampleData),
            image: Image("placeholder")
        )
    }
}
