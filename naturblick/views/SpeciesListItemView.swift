//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI
import CachedAsyncImage

struct SpeciesListItemView: View {
    let species: SpeciesListItem

    var urlRequest: URLRequest? {
        if let urlstr = species.url, let url = URL(string: Configuration.strapiUrl + urlstr) {
            return URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        } else {
            return nil
        }
    }
    
    var body: some View {
        HStack(spacing: .zero) {
            HStack(alignment: .top, spacing: .zero) {
                CachedAsyncImage(urlRequest: urlRequest) { image in
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
                VStack(alignment: .leading, spacing: .zero) {
                    if let name = species.name, let gersynonym = species.synonym {
                        Text(name)
                            .subtitle1()
                        Text(species.sciname)
                            .subtitle3(color: .onSecondaryButtonPrimary)
                        Text(gersynonym)
                            .subtitle3(color: .onSecondaryHighEmphasis)
                    } else if let name = species.name {
                        Text(name)
                            .subtitle1()
                        Text(species.sciname)
                            .subtitle3(color: .onSecondaryButtonPrimary)
                    } else if let gersynonym = species.synonym {
                        Text(species.sciname)
                            .subtitle1()
                        Text(gersynonym)
                            .subtitle3(color: .onSecondaryHighEmphasis)
                    } else {
                        Text(species.sciname)
                            .subtitle1()
                    }
                }
                .padding(.top, .avatarTextOffset)
                Spacer()
            }
            ChevronView(color: .onPrimarySignalLow)
        }
        .contentShape(Rectangle())
    }
}

struct SpeciesListItemView_Previews: PreviewProvider {
    static var previews: some View {
        SpeciesListItemView(species: SpeciesListItem.sampleData)
    }
}
