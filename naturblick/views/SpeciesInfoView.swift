//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import CachedAsyncImage

struct SpeciesInfoView<Flow>: NavigatableView where Flow: IdFlow {
    var holder: ViewControllerHolder = ViewControllerHolder()
    
    var viewName: String? {
        species.name
    }
    
    func configureNavigationItem(item: UINavigationItem) {
        item.rightBarButtonItem = UIBarButtonItem(primaryAction: UIAction(title: String(localized: "choose")) {_ in
            flow.selectSpecies(species: species)
        })
    }
    
    let species: SpeciesListItem
    @ObservedObject var flow: Flow
    
    var urlRequest: URLRequest? {
        if let urlstr = species.url, let url = URL(string: Configuration.strapiUrl + urlstr) {
            return URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        } else {
            return nil
        }
    }
    
    var body: some View {
        VStack(alignment: .center) {
            SwiftUI.Group {
                CachedAsyncImage(urlRequest: urlRequest) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: .largeCornerRadius))
                } placeholder: {
                    Image("placeholder")
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                }
            }
            .overlay(alignment: .bottomTrailing) {
                if let audioUrl = species.audioUrl {
                    SoundButton(url: URL(string: Configuration.strapiUrl + audioUrl)!)
                        .frame(height: .fabSize)
                        .padding(.defaultPadding)
                }
            }
            Text(species.sciname)
                .overline(color: .onSecondarySignalHigh)
                .multilineTextAlignment(.center)
            Text(species.speciesName?.uppercased() ?? String(localized: "speciesname").uppercased())
                .headline4(color: .onSecondaryHighEmphasis)
                .multilineTextAlignment(.center)
            if let synonym = species.synonym {
                Text("also \(synonym)")
                    .caption(color: .onSecondaryLowEmphasis)
                    .multilineTextAlignment(.center)
            }
            if species.hasPortrait {
                Button("to_artportrait") {
                    navigationController?.pushViewController(PortraitViewController(species: species, inSelectionFlow: true), animated: true)
                }
                .buttonStyle(AuxiliaryOnSecondaryButton())
            } else if let wikipedia = species.wikipedia {
                Link("link_to_wikipedia", destination: URL(string: wikipedia)!)
                    .buttonStyle(AuxiliaryOnSecondaryButton())
            }
        }
        .padding(.defaultPadding)
    }
}

struct SpeciesInfoView_Previews: PreviewProvider {
    static var previews: some View {
        SpeciesInfoView(species: .sampleData, flow: IdFlowSample())
    }
}

