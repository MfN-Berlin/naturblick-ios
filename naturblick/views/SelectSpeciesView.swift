//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI


struct SelectSpeciesView: NavigatableView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    
    @ObservedObject var createFlow: CreateFlowViewModel
    let thumbnail: NBImage
    let action: (SpeciesListItem) -> ()
    
    init(createFlow: CreateFlowViewModel, thumbnail: NBImage, action: @escaping (SpeciesListItem) -> ()) {
        self.createFlow = createFlow
        self.thumbnail = thumbnail
        self.action = action
    }
    @State var showInfo: SpeciesInfo? = nil
    @StateObject var model: SelectSpeciesViewModel = SelectSpeciesViewModel()
    
    func openSpeciesInfo(species: SpeciesListItem, image: Image) {
        let info = SpeciesInfoView(info: SpeciesInfo(species: species, avatar: image)) { 
            withNavigation { navigation in
                createFlow.createObservation(navigation: navigation, species: species)
            }
        }
        withNavigation { navigation in
            navigation.present(info.setUpViewController(), animated: true)
        }
    }
    
    var body: some View {
        if let rs = createFlow.data.image.result {
            VStack {
                Image(uiImage: thumbnail.image)
                    .resizable()
                    .scaledToFit()
                VStack(alignment: .leading) {
                    ForEach(model.speciesResults, id: \.0.id) { (result, item) in
                        if let url = item.url {
                            // When used, AsyncImage has to be the outermost element
                            // or it will not properly load in List
                            AsyncImage(url: URL(string: Configuration.strapiUrl + url)!) { image in
                                SpeciesResultView(result: result, species: item, avatar: image)
                                    .onTapGesture {
                                        openSpeciesInfo(species: item, image: image)
                                    }
                            } placeholder: {
                                SpeciesResultView(result: result, species: item, avatar: Image("placeholder"))
                                    .onTapGesture {
                                        openSpeciesInfo(species: item, image: Image("placeholder"))
                                    }
                            }
                        } else {
                            SpeciesResultView(result: result, species: item, avatar: Image("placeholder"))
                                .onTapGesture {
                                    openSpeciesInfo(species: item, image: Image("placeholder"))
                                }
                        }
                    }
                }
                .onAppear {
                    model.resolveSpecies(results: rs)
                }
            }
        } else {
            Text("Loading ...")
        }
    }
}
