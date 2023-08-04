//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI


struct SelectSpeciesView: View {
    let results: [SpeciesResult]
    let thumbnail: UIImage
    let action: (SpeciesListItem) -> ()
    
    init(results: [SpeciesResult], thumbnail: UIImage, action: @escaping (SpeciesListItem) -> ()) {
        self.results = results
        self.thumbnail = thumbnail
        self.action = action
    }
    @State var showInfo: SpeciesInfo? = nil
    @StateObject var model: SelectSpeciesViewModel = SelectSpeciesViewModel()
    var body: some View {
        VStack {
            Image(uiImage: thumbnail)
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
                                    showInfo = SpeciesInfo(species: item, avatar: image)
                                }
                        } placeholder: {
                            SpeciesResultView(result: result, species: item, avatar: Image("placeholder"))
                                .onTapGesture {
                                    showInfo = SpeciesInfo(species: item, avatar: Image("placeholder"))
                                }
                        }
                    } else {
                        SpeciesResultView(result: result, species: item, avatar: Image("placeholder"))
                            .onTapGesture {
                                showInfo = SpeciesInfo(species: item, avatar: Image("placeholder"))
                            }
                    }
                }
            }
            .onAppear {
                model.resolveSpecies(results: results)
            }
            .popover(item: $showInfo) { info in
                NavigationView {
                    SpeciesInfoView(info: info)
                        .navigationTitle(info.species.name != nil ? info.species.name! : info.species.sciname)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Select") {
                                    action(info.species)
                                    showInfo = nil
                                }
                            }
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Close") {
                                    showInfo = nil
                                }
                            }
                        }
                }
            }
        }
    }
}

struct SelectSpeciesView_Previews: PreviewProvider {
    static var previews: some View {
        SelectSpeciesView(results: [], thumbnail: UIImage(named: "placeholder")!, action: {_ in })
    }
}
