//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct ObservationListItemView: View {
    let observation: ObservationListItem
    let avatar: Image

    var body: some View {
        HStack(alignment: .top) {
            avatar
                .resizable()
                .scaledToFit()
                .clipShape(Circle())
                .frame(width: .avatarSize, height: .avatarSize)
                .padding(.trailing, .defaultPadding)
            VStack(alignment: .leading) {
                if let name = observation.species?.name {
                    Text(name)
                        .font(.nbSubtitle1)
                } else {
                    Text(observation.species?.sciname ?? "No species")
                        .font(.nbSubtitle1)
                }
                Text(observation.time.formatted())
                    .font(.nbSubtitle3)
                    .foregroundColor(.nbSecondary)
            }
            .padding(.top, .avatarTextOffset)
        }
    }
}

struct ObservationListItemView_Previews: PreviewProvider {
    static var previews: some View {
        ObservationListItemView(
            observation: ObservationListItem.sampleData,
            avatar: Image("placeholder")
        )
    }
}
