//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI


struct SelectSpeciesView: View {
    let results: [SpeciesResult]
    let thumbnail: UIImage
    @Binding var data: CreateData
    @StateObject var model: SelectSpeciesViewModel = SelectSpeciesViewModel()
    var body: some View {
        VStack {
            Image(uiImage: thumbnail)
            List(model.speciesResults, id: \.0.id) { (result, item) in
                Button {
                    data.species = item
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
        SelectSpeciesView(results: [], thumbnail: UIImage(named: "placeholder")!, data: .constant(CreateData()))
    }
}
