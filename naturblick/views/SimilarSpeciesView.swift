//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct SimilarSpeciesView: View, HoldingViewController {
    @StateObject var similarSpeciesViewModel = SimilarSpeciesViewModel()
    let portraitId: Int64
    var holder: ViewControllerHolder
    let inSelectionFlow: Bool

    var body: some View {
        VStack(alignment: .leading) {
            if !similarSpeciesViewModel.mixups.isEmpty {
                Text("similar_species")
                    .headline4()
            }
            ForEach(similarSpeciesViewModel.mixups) { mix in
                if mix.species.hasPortrait {
                        VStack(alignment: .leading) {
                            SimilarSpeciesItemView(species: mix.species.listItem)
                            Text(mix.differences)
                                .body1()
                                .padding(.top, .halfPadding)
                        }
                        .onTapGesture {
                            navigationController?.pushViewController(PortraitViewController(species: mix.species.listItem, inSelectionFlow: inSelectionFlow), animated: true)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.defaultPadding)
                        .background {
                            RoundedRectangle(cornerRadius: .smallCornerRadius)
                                .foregroundColor(.secondaryColor)
                        }
                } else if let wikipedia = mix.species.wikipedia {
                    Link(destination: URL(string: wikipedia)!) {
                        VStack(alignment: .leading) {
                            SimilarSpeciesItemView(species: mix.species.listItem)
                            Text(mix.differences)
                                .body1()
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
                } else {
                    VStack(alignment: .leading) {
                        SimilarSpeciesItemView(species: mix.species.listItem)
                        Text(mix.differences)
                            .body1()
                            .padding(.top, .halfPadding)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.defaultPadding)
                    .background {
                        RoundedRectangle(cornerRadius: .smallCornerRadius)
                            .foregroundColor(.secondaryColor)
                    }
                }
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
        SimilarSpeciesView(portraitId: 5, holder: ViewControllerHolder(), inSelectionFlow: false)
    }
}
