//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct SpeciesInfo: Identifiable {
    var id: String {
        species.id
    }
    let species: SpeciesListItem
    let avatar: Image
}


struct SpeciesInfoView<Flow>: NavigatableView where Flow: IdFlow {
    var holder: ViewControllerHolder = ViewControllerHolder()
    
    var viewName: String? {
        "Choose species"
    }
    
    func configureNavigationItem(item: UINavigationItem) {
        item.rightBarButtonItem = UIBarButtonItem(primaryAction: UIAction(title: "Choose") {_ in
            flow.selectSpecies(species: info.species)
        })
    }
    
    let info: SpeciesInfo
    @ObservedObject var flow: Flow
    var body: some View {
        VStack {
            info.avatar
                .resizable()
                .scaledToFit()
                .clipShape(Circle())
                .padding(.trailing, .defaultPadding)
            
            if let name = info.species.name {
                Text(info.species.sciname)
                Text(name)
            } else {
                Text(info.species.sciname)
            }
            if info.species.hasPortrait {
                Button("Visit artportrait") {
                    let view = PortraitView(speciesId: info.species.speciesId)
                    withNavigation { navigation in
                        navigation.pushViewController(view.setUpViewController(), animated: true)
                    }
                }
            } else if let wikipedia = info.species.wikipedia {
                Link("Visit wikipedia", destination: URL(string: wikipedia)!)
            }
            
            if let audioUrl = info.species.audioUrl {
                SoundButton(url: URL(string: Configuration.strapiUrl + audioUrl)!)
            }
        }.padding(.defaultPadding)
    }
}

struct SpeciesInfoView_Previews: PreviewProvider {
    static var previews: some View {
        SpeciesInfoView(info: SpeciesInfo(species: .sampleData, avatar: Image("placeholder")), flow: IdFlowSample())
    }
}

