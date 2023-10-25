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
            VStack(alignment: .leading, spacing: .zero) {
                if let name = species.name {
                    Text(species.sciname)
                        .subtitle3(color: .onFeatureSignalHigh)
                    Text(name)
                        .subtitle1(color: .onFeatureHighEmphasis)
                } else {
                    Text(species.sciname)
                        .subtitle1(color: .onFeatureSignalHigh)
                }
            }
            .padding(.top, .avatarTextOffset)
            Spacer()
        }
    }
}

struct SimilarSpeciesItemView_Previews: PreviewProvider {
    static var previews: some View {
        SimilarSpeciesItemView(species: SpeciesListItem.sampleData)
    }
}
