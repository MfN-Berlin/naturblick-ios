//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct SimilarSpeciesView: View {
    @StateObject var similarSpeciesViewModel = SimilarSpeciesViewModel()
    let portraitId: Int64

    var body: some View {
        VStack {
            ForEach(similarSpeciesViewModel.mixups) { mix in
                VStack {
                    if let url = mix.species.maleUrl {
                        AsyncImage(url: URL(string: Configuration.strapiUrl + url)!) { image in
                            SpeciesListItemView(species: mix.species.toListItem, avatar: image)
                        } placeholder: {
                            SpeciesListItemView(species: mix.species.toListItem, avatar: Image("placeholder"))
                        }
                    }
                    Text(mix.differences)
                }
                Spacer()
            }
        }
        .task {
            similarSpeciesViewModel.filter(portraitId: portraitId)
        }
    }
}

struct SimilarSpeciesView_Previews: PreviewProvider {
    static var previews: some View {
        SimilarSpeciesView(portraitId: 5)
    }
}
