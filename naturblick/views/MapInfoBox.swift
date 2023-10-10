//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct MapInfoBox: NavigatableView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    var viewName: String? {
        "Map Info"
    }
    
    let observation: Observation
    let persistenceController: ObservationPersistenceController
    let toDetails: () -> Void
    
    var body: some View {
        VStack {
            Thumbnail(speciesUrl: observation.species?.maleUrl, thumbnailId: observation.observation.thumbnailId) { image in
                image
                    .resizable()
                    .scaledToFit()
            }
            if let gerName = observation.species?.gername {
                Text(gerName)
                    .font(.nbSubtitle1)
            }
            Text(observation.observation.created.date, formatter: .dateTime)
                .font(.nbOverline)
            Button("Details") {
                viewController?.dismiss(animated: true)
                toDetails()
            }.accentColor(Color.onPrimaryButtonPrimary)
                .buttonStyle(.borderedProminent)
                .padding(.defaultPadding)
            Spacer()
        }.foregroundColor(.onPrimaryHighEmphasis)
    }
}
