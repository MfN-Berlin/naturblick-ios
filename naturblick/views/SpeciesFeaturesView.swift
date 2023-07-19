//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct SpeciesFeaturesView: View {
    @StateObject var featureViewModel = UnambiguousFeatureViewModel()
    let portraitId: Int64
    let species: Species
    
    var body: some View {
        
        VStack(alignment: .leading) {
            if let url = species.maleUrl {
                AsyncImage(url: URL(string: Configuration.strapiUrl + url)!) { image in
                    SimilarSpeciesItemView(species: species.listItem, avatar: image)
                } placeholder: {
                    SimilarSpeciesItemView(species: species.listItem, avatar: Image("placeholder"))
                }
            }
            
            ForEach(featureViewModel.features) { feature in
                Text(feature.description)
                    .font(.nbBody2)
                    .padding(.halfPadding)
                    .background {
                        RoundedRectangle(cornerRadius: .smallCornerRadius)
                            .foregroundColor(.onFeatureSignalLow)
                    }
            }
        }
        .padding(.bottom, .halfPadding)
        .task {
            featureViewModel.filter(portraitId: portraitId)
        }
    }
}
    

struct SpeciesFeaturesView_Previews: PreviewProvider {
    static var previews: some View {
        SpeciesFeaturesView(portraitId: 5, species: Species.sampleData)
    }
}
