//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI
import CachedAsyncImage

struct SpeciesListItemView: View {
    let species: SpeciesListItem

    var urlRequest: URLRequest? {
        if let urlstr = species.url, let url = URL(string: Configuration.djangoUrl + urlstr) {
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
                    if let name = species.speciesName, let synonym = species.synonym {
                        HStack {
                            Text(name)
                                .subtitle1()
                            if let gender = species.gender {
                                Text(gender)
                                    .foregroundColor(.onSecondaryHighEmphasis)
                            }
                        }
                        Text(species.sciname)
                            .subtitle3(color: .onSecondarySignalLow)
                            .accessibilityLabel(Text("sciname \(species.sciname)"))
                        Text(synonym)
                            .synonym(color: .onSecondaryHighEmphasis)
                    } else if let name = species.speciesName {
                        HStack {
                            Text(name)
                                .subtitle1()
                            if let gender = species.gender {
                                Text(gender)
                                    .foregroundColor(.onSecondaryHighEmphasis)
                            }
                        }
                        Text(species.sciname)
                            .subtitle3(color: .onSecondarySignalLow)
                            .accessibilityLabel(Text("sciname \(species.sciname)"))
                    } else if let gersynonym = species.synonym {
                        Text(species.sciname)
                            .subtitle1(color: Color.onSecondarySignalLow)
                            .accessibilityLabel(Text("sciname \(species.sciname)"))
                        Text(gersynonym)
                            .subtitle3(color: .onSecondaryHighEmphasis)
                    } else {
                        Text(species.sciname)
                            .subtitle1(color: Color.onSecondarySignalLow)
                            .accessibilityLabel(Text("sciname \(species.sciname)"))
                    }
                }
                .padding(.top, .avatarTextOffset)
                Spacer()
            }
            ChevronView()
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}

struct SpeciesListItemView_Previews: PreviewProvider {
    static var previews: some View {
        SpeciesListItemView(species: SpeciesListItem.sampleData)
    }
}
