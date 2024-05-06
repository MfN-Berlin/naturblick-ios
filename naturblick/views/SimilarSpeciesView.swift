//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct SimilarSpeciesView: View {
    @ObservedObject var similarSpeciesViewModel: SimilarSpeciesViewModel
    let similarSpeciesDestination: (SpeciesListItem) -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: .defaultPadding) {
            Text("similar_species")
                .headline4()
            ForEach(similarSpeciesViewModel.mixups) { mix in
                VStack(alignment: .leading, spacing: .defaultPadding) {
                    SimilarSpeciesItemView(species: mix.species.listItem)
                    Text(mix.differences)
                        .body1()
                        .padding(.top, .halfPadding)
                }
                .onTapGesture {
                    similarSpeciesDestination(mix.species.listItem)
                }
                .frame(maxWidth: .infinity)
                .padding(.defaultPadding)
                .background {
                    RoundedRectangle(cornerRadius: .smallCornerRadius)
                        .foregroundColor(.secondaryColor)
                }
            }
            .padding(.top, .halfPadding)
        }
    }
}

struct SimilarSpeciesView_Previews: PreviewProvider {
    static var previews: some View {
        SimilarSpeciesView(similarSpeciesViewModel: SimilarSpeciesViewModel()) { _ in
        }
    }
}
