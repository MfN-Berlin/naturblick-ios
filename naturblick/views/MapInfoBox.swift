//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct MapInfoBox: View {
    let observation: Observation
    let backend: Backend
    let toDetails: (Observation) -> Void
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Thumbnail(occurenceId: observation.id, backend: backend, speciesUrl: observation.species?.maleUrl, thumbnailId: observation.observation.thumbnailId, obsIdent: observation.observation.obsIdent) { image in
                image
                    .resizable()
                    .scaledToFit()
            }
            Rectangle().fill(LinearGradient(gradient: Gradient(colors: [.blackFullyTransparent, .whiteHalfTransparent, .white]), startPoint: .top, endPoint: .bottom))
            VStack(spacing: .zero) {
                if let name = observation.species?.speciesName {
                    Text(name)
                        .subtitle1(color: .black)
                } else {
                    Text(observation.species?.sciname ?? String(localized: "unknown_species"))
                        .subtitle1(color: .black)
                }
                Text(observation.observation.created.date.formatted())
                    .subtitle3(color: .black)
                SwiftUI.Button {
                    toDetails(observation)
                } label: {
                    Text("details")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(ConfirmButton())
                .padding(.vertical, .halfPadding)
                .padding(.horizontal, .defaultPadding)
            }
            .foregroundColor(.onSecondaryHighEmphasis)
        }
    }
}
