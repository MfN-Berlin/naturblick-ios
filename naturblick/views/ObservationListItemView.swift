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
                if let species = observation.species {
                    if let name = species.speciesName {
                        Text(name)
                            .subtitle1()
                    }
                    Text(species.sciname)
                        .subtitle3(color: .onSecondarySignalLow)
                        .accessibilityLabel(Text("sciname \(species.sciname)"))
                } else {
                    Text(observation.species?.sciname ?? String(localized: "unknown_species"))
                        .subtitle1()
                        .foregroundColor(Color.onSecondarySignalLow)
                }
                Text(observation.observation.created.date.formatted())
                    .synonym(color: .onSecondaryHighEmphasis)
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
