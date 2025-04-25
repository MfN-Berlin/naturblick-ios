//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import CachedAsyncImage

struct SpeciesResultView: View {
    let result: SpeciesResult
    let species: SpeciesListItem
    
    var color: Color {
        if result.score > 50 {
            return .onSecondarySignalMedium
        } else {
            return .onSecondarySignalLow
        }
    }
    
    var urlRequest: URLRequest? {
        if let urlstr = species.url, let url = URL(string: Configuration.djangoUrl + urlstr) {
            return URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        } else {
            return nil
        }
    }
    
    var body: some View {
        HStack {
            CachedAsyncImage(urlRequest: urlRequest) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(width: .avatarSize, height: .avatarSize)
                    .padding(.trailing, .defaultPadding)
                    .accessibilityHidden(true)
            } placeholder: {
                Image(decorative: "placeholder")
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(width: .avatarSize, height: .avatarSize)
                    .padding(.trailing, .defaultPadding)
            }
            VStack(alignment: .leading, spacing: .zero) {
                if let name = species.speciesName {
                    HStack {
                        Text(name)
                            .subtitle1()
                        if let gender = species.gender {
                            Text(gender)
                                .foregroundColor(.onSecondaryHighEmphasis)
                        }
                    }
                } else {
                    Text(species.sciname)
                        .subtitle1()
                        .accessibilityLabel(Text("sciname \(species.sciname)"))
                }
                Text(String(format: "Score: %.0f%%", result.score.rounded()))
                    .subtitle3(color: color)
            }
            Spacer()
            ChevronView(color: .onPrimarySignalLow)
        }
        .contentShape(Rectangle())
    }
}

struct SpeciesResultView_Previews: PreviewProvider {
    static var previews: some View {
        SpeciesResultView(result: .init(id: 1, score: 42), species: .sampleData)
    }
}
