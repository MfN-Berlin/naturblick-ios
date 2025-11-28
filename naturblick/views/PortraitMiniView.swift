//
// Copyright © 2025 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI
import CachedAsyncImage

struct PortraitMiniView: View {
    @Environment(\.openURL) var openURL
    let species: SpeciesListItem
    let present: (UIViewController, (() -> Void)?) -> Void

    var urlRequest: URLRequest? {
        if let urlstr = species.url, let url = URL(string: Configuration.djangoUrl + urlstr) {
            return URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        } else {
            return nil
        }
    }

    var body: some View {
        VStack(alignment: .center, spacing: .defaultPadding) {
            SwiftUI.Group {
                CachedAsyncImage(urlRequest: urlRequest) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: .largeCornerRadius))
                        .accessibilityHidden(true)
                } placeholder: {
                    Image(decorative: "placeholder")
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                }
            }
            .overlay(alignment: .bottomTrailing) {
                if let url = species.maleUrlOrig {
                    FullscreenButtonView(present: present, url: URL(string: Configuration.djangoUrl + url)!)
                }
            }
            VStack {
                Text(species.sciname)
                    .overline(color: .onSecondarySignalHigh)
                    .multilineTextAlignment(.center)
                    .accessibilityLabel(Text("sciname \(species.sciname)"))
                Text(species.speciesName?.uppercased() ?? species.sciname.uppercased())
                    .headline4(color: .onSecondaryHighEmphasis)
                    .multilineTextAlignment(.center)
                if let synonym = species.synonym {
                    Text("also \(synonym)")
                        .caption(color: .onSecondaryLowEmphasis)
                        .multilineTextAlignment(.center)
                }
            }
            if let wikipediaUrl = URL.wikipedia(species: species) {
                Button("link_to_wikipedia") {
                    openURL(wikipediaUrl)
                }
                .buttonStyle(AuxiliaryOnSecondaryButton())
            }
            Spacer()
        }.padding(.defaultPadding)
    }
}
