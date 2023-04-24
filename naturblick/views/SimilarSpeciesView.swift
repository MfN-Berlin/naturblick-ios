//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct SimilarSpeciesView: View {
    @StateObject var similarSpeciesViewModel = SimilarSpeciesViewModel()
    let portraitId: Int64

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(similarSpeciesViewModel.mixups) { mix in
                NavigationLink(destination: PortraitView(speciesId: mix.species.toListItem.speciesId)) {
                    VStack(alignment: .leading) {
                        if let url = mix.species.maleUrl {
                            AsyncImage(url: URL(string: Configuration.strapiUrl + url)!) { image in
                                SimilarSpeciesItemView(species: mix.species.toListItem, avatar: image)
                            } placeholder: {
                                SimilarSpeciesItemView(species: mix.species.toListItem, avatar: Image("placeholder"))
                            }
                        }
                        Text(mix.differences)
                            .font(.nbBody1)
                            .padding(.top, .halfPadding)
                            
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.defaultPadding)
                    .background {
                        RoundedRectangle(cornerRadius: .smallCornerRadius)
                            .foregroundColor(.secondaryColor)
                    }
                }
                .buttonStyle(PlainButtonStyle()) // to prevent defualt link-text-styling
            }
            .padding(.top, .halfPadding)
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
