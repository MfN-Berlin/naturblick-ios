//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import CachedAsyncImage

struct SimilarSpeciesItemView: View {
    let species: SpeciesListItem
    var body: some View {
        HStack(alignment: .top) {
            if let url = species.maleUrl {
                CachedAsyncImage(url: URL(string: Configuration.strapiUrl + url)!) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .frame(width: .avatarSize, height: .avatarSize)
                        .padding(.trailing, .defaultPadding)
                } placeholder: {
                    Image("placeholder")
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .frame(width: .avatarSize, height: .avatarSize)
                        .padding(.trailing, .defaultPadding)
                }
            }
            VStack(alignment: .leading) {
                if let gername = species.name {
                    Text(species.sciname)
                        .font(.nbSubtitle3)
                        .foregroundColor(.onSecondarySignalHigh)
                    Text(gername)
                        .font(.nbSubtitle1)
                        .foregroundColor(.onSecondaryHighEmphasis)
                } else if let name = species.name {
                    Text(species.sciname)
                        .font(.nbSubtitle3)
                        .foregroundColor(.onSecondarySignalLow)
                        .padding(.bottom, .defaultPadding)
                    Text(name)
                        .font(.nbSubtitle1)
                        .foregroundColor(.onSecondaryHighEmphasis)
                } else if let gersynonym = species.gersynonym {
                    Text(species.sciname)
                        .font(.nbSubtitle1)
                        .foregroundColor(.onSecondaryHighEmphasis)
                    Text(gersynonym)
                        .font(.nbSubtitle3)
                        .padding(.bottom, .defaultPadding)
                        .foregroundColor(.onSecondarySignalLow)
                } else {
                    Text(species.sciname)
                        .font(.nbSubtitle1)
                        .foregroundColor(.onSecondaryHighEmphasis)
                }
            }
            .padding(.top, .avatarTextOffset)
        }
    }
}

struct SimilarSpeciesItemView_Previews: PreviewProvider {
    static var previews: some View {
        SimilarSpeciesItemView(species: SpeciesListItem.sampleData)
    }
}
