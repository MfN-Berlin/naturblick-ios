//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct MapInfoBox: View {
    
    @Binding var present: Bool
    let observation: Observation
    let navToEdit: (Observation) -> Void
    
    var body: some View {
        ZStack {
            Thumbnail(speciesUrl: observation.species?.maleUrl, thumbnailId: observation.observation.thumbnailId) { image in
                ZStack {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: .mapInfoSize, height: .mapInfoSize)
                    Rectangle()
                        .foregroundColor(.clear)
                        .background(LinearGradient(gradient: Gradient(colors: [.clear, .white]), startPoint: .top, endPoint: .bottom))
                }.cornerRadius(.smallCornerRadius)
            }
            VStack {
                Spacer()
                if let gerName = observation.species?.gername {
                    Text(gerName)
                        .font(.nbCaption)
                        .foregroundColor(.black)
                }
                Text(observation.observation.created.date, formatter: .dateTime)
                    .font(.nbOverline)
                    .foregroundColor(.black)
                Button("Details") {
                    navToEdit(observation)
                }.accentColor(Color.onPrimaryButtonPrimary)
                    .buttonStyle(.borderedProminent)
                    .padding(.defaultPadding)
            }
        }
    }
}
