//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI


struct ObservationListItemView: View {
    let observation: Observation
    let species: Species?
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
                if let name = species?.gername {
                    Text(name)
                        .font(.nbSubtitle1)
                        .foregroundColor(.onSecondaryHighEmphasis)
                } else {
                    Text(species?.sciname ?? "No species")
                        .font(.nbSubtitle1)
                        .foregroundColor(.onSecondarySignalLow)
                }
                Text(observation.created.date.formatted())
                    .font(.nbSubtitle3)
                    .foregroundColor(.onSecondarySignalLow)
            }
            .padding(.top, .avatarTextOffset)
        }
    }
}


struct ObservationListItemView_Previews: PreviewProvider {
    static var previews: some View {
        ObservationListItemView(
            observation: Observation.sampleData,
            species: Species.sampleData,
            image: Image("placeholder")
        )
    }
}
