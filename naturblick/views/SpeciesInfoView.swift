//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import CachedAsyncImage

struct SpeciesInfoView<Flow>: NavigatableView where Flow: SelectionFlow {
    @Environment(\.openURL) var openURL
    var holder: ViewControllerHolder = ViewControllerHolder()
    
    var viewName: String? {
        species.speciesName
    }
    let selectionFlow: Bool
    let species: SpeciesListItem
    @ObservedObject var flow: Flow
    
    var urlRequest: URLRequest? {
        if let urlstr = species.url, let url = URL(string: Configuration.strapiUrl + urlstr) {
            return URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        } else {
            return nil
        }
    }
    
    func configureNavigationItem(item: UINavigationItem) {
        if navigationController?.viewControllers.first == viewController {
            item.leftBarButtonItem = UIBarButtonItem(primaryAction: UIAction(title: String(localized: "back")) {_ in
                viewController?.dismiss(animated: true)
            })
        }
        if !(flow is VoidSelectionFlow) {
            let actionString = selectionFlow ? String(localized: "create_with_species") : String(localized: "create_obs")
            item.rightBarButtonItem  = UIBarButtonItem(primaryAction: UIAction(title: actionString) {_ in
                viewController?.dismiss(animated: true)
                flow.selectSpecies(species: species)
            })
        }
    }
    
    func navigate(species: SpeciesListItem) {
        navigationController?.pushViewController(SpeciesInfoView(selectionFlow: selectionFlow, species: species, flow: flow).setUpViewController(), animated: true)
    }
    
    var body: some View {
        if species.hasPortrait {
            PortraitView(species: species, similarSpeciesDestination: navigate)
        } else {
            VStack(alignment: .center, spacing: .defaultPadding) {
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
                        SoundButton(url: URL(string: Configuration.strapiUrl + audioUrl)!, speciesId: species.speciesId)
                            .frame(height: .fabSize)
                            .padding(.defaultPadding)
                    }
                }
                VStack {
                    Text(species.sciname)
                        .overline(color: .onSecondarySignalHigh)
                        .multilineTextAlignment(.center)
                    Text(species.speciesName?.uppercased() ?? species.sciname.uppercased())
                        .headline4(color: .onSecondaryHighEmphasis)
                        .multilineTextAlignment(.center)
                    
                    if let synonym = species.synonym {
                        Text("also \(synonym)")
                            .caption(color: .onSecondaryLowEmphasis)
                            .multilineTextAlignment(.center)
                    }
                }
                if let wikipedia = species.wikipedia {
                    Button("link_to_wikipedia") {
                        openURL(URL(string: wikipedia)!)
                    }
                    .buttonStyle(AuxiliaryOnSecondaryButton())
                }
                Spacer()
            }.padding(.defaultPadding)
        }
        
    }
}

struct SpeciesInfoView_Previews: PreviewProvider {
    static var previews: some View {
        SpeciesInfoView(selectionFlow: false, species: .sampleData, flow: VoidSelectionFlow())
    }
}

