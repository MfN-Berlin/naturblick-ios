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

class SpeciesInfoViewController: NavigatableHostingController<SpeciesInfoView> {
    let createFlow: CreateFlowViewModel
    let species: SpeciesListItem
    init(info: SpeciesInfo, createFlow: CreateFlowViewModel) {
        self.species = info.species
        self.createFlow = createFlow
        let view = SpeciesInfoView(info: info)
        super.init(rootView: view)
    }
    
    @objc func createObservation() {
        createFlow.createObservation(species: species)
        dismiss(animated: true)
    }
    
    @objc func cancel() {
        dismiss(animated: true)
    }
}

struct SpeciesInfoView: NavigatableView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    
    func configureNavigationItem(item: UINavigationItem) {
        item.rightBarButtonItem = UIBarButtonItem(title: "Choose", style: .done, target: viewController, action: #selector(SpeciesInfoViewController.createObservation))
        item.leftBarButtonItem = UIBarButtonItem(title: "Dismiss", style: .done, target: viewController, action: #selector(SpeciesInfoViewController.cancel))
    }
    
    let info: SpeciesInfo
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
                NavigationLink(destination: PortraitView(speciesId: info.species.speciesId)) {
                    Text("Visit artportrait")
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
        SpeciesInfoView(info: SpeciesInfo(species: .sampleData, avatar: Image("placeholder")))
    }
}

