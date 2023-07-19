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
    
    @StateObject var model: SelectSpeciesViewModel = SelectSpeciesViewModel()
    var body: some View {
        VStack {
            Image(uiImage: thumbnail)
                .resizable()
                .scaledToFill()
            List(model.speciesResults, id: \.0.id) { (result, item) in
                Button {
                    action(item)
                } label: {
                    Text(item.sciname)
                        .padding()
                }
            }
            .onAppear {
                model.resolveSpecies(results: results)
            }
        }
    }
}

struct SelectSpeciesView_Previews: PreviewProvider {
    static var previews: some View {
        SelectSpeciesView(results: [], thumbnail: UIImage(named: "placeholder")!, action: {_ in })
    }
}
