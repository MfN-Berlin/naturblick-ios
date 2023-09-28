//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct MapInfoBox: View {
    
    @Binding var present: Bool
    let observation: Observation
    let navToEdit: (Observation) -> Void
    
    var body: some View {
        VStack {
            if let gerName = observation.species?.gername {
                Text(gerName)
                    .font(.nbSubtitle1)
                    .foregroundColor(.onPrimaryHighEmphasis)
            }
            Text(observation.observation.created.date, formatter: .dateTime)
                .font(.nbSubtitle2)
                .foregroundColor(.onPrimaryHighEmphasis)
            HStack {
                Spacer()
                Button("Details") {
                    navToEdit(observation)
                }.accentColor(Color.onPrimaryButtonPrimary)
                    .buttonStyle(.borderedProminent)
                    .padding(.defaultPadding)
            }.padding()
            Thumbnail(speciesUrl: observation.species?.maleUrl, thumbnailId: observation.observation.thumbnailId) { image in
                image
                    .resizable()
                    .scaledToFit()
            }
        }
    }
}
