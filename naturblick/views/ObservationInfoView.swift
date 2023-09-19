//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct ObservationInfoView: View {
    let thumbnail: NBImage?
    let species: SpeciesListItem?
    let width: CGFloat
    let created: ZonedDateTime
    var body: some View {
        VStack() {
            if let thumbnail = thumbnail {
                    Image(uiImage: thumbnail.image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .frame(width: width * 0.4, height: width * 0.4)
                        .padding(.bottom, .defaultPadding)
            } else  {
                Image("placeholder")
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(width: width * 0.4, height: width * 0.4)
                    .padding(.bottom, .defaultPadding)
            }
            if let sciname = species?.sciname {
                Text(sciname)
                    .font(.nbOverline)
                    .foregroundColor(.onPrimarySignalHigh)
                    .multilineTextAlignment(TextAlignment.center)
            }
            Text(species?.name ?? "Unknown species")
                .font(.nbHeadline2)
                .foregroundColor(.onPrimaryHighEmphasis)
                .multilineTextAlignment(TextAlignment.center)
            Text(created.date, formatter: .dateTime)
                .font(.caption)
                .foregroundColor(.onPrimarySignalLow)
                .multilineTextAlignment(TextAlignment.center)
        }
        .padding(.defaultPadding)
        .background(Color(uiColor: .onPrimaryButtonSecondary))
    }
}

struct ObservationInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ObservationInfoView(thumbnail: NBImage(image: UIImage(named: "placeholder")!), species: SpeciesListItem.sampleData, width: 800, created: ZonedDateTime())
    }
}
