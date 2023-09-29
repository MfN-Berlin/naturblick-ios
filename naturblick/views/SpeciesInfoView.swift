//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import CachedAsyncImage

struct SpeciesInfoView<Flow>: NavigatableView where Flow: IdFlow {
    var holder: ViewControllerHolder = ViewControllerHolder()
    
    var viewName: String? {
        "Profile"
    }
    
    func configureNavigationItem(item: UINavigationItem) {
        item.rightBarButtonItem = UIBarButtonItem(primaryAction: UIAction(title: "Choose") {_ in
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
        VStack {
            CachedAsyncImage(urlRequest: urlRequest) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .padding(.trailing, .defaultPadding)
            } placeholder: {
                Image("placeholder")
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .padding(.trailing, .defaultPadding)
            }
            if let name = species.name {
                Text(species.sciname)
                Text(name)
            } else {
                Text(species.sciname)
            }
            if species.hasPortrait {
                Button("Visit artportrait") {
                    let view = PortraitView(species: species)
                    withNavigation { navigation in
                        navigation.pushViewController(view.setUpViewController(), animated: true)
                    }
                }
            } else if let wikipedia = species.wikipedia {
                Link("Visit wikipedia", destination: URL(string: wikipedia)!)
            }
            
            if let audioUrl = species.audioUrl {
                SoundButton(url: URL(string: Configuration.strapiUrl + audioUrl)!)
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

