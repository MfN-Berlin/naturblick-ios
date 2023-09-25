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
            SimilarSpeciesItemView(species: species.listItem)
            ForEach(featureViewModel.features) { feature in
                Text(feature.description)
                    .font(.nbBody2)
                    .padding(.halfPadding)
                    .foregroundColor(.onFeatureHighEmphasis)
                    .background {
                        RoundedRectangle(cornerRadius: .smallCornerRadius)
                            .foregroundColor(.onPrimaryMediumEmphasis)
                    }
            }
        }
        .frame(maxWidth: .infinity)
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
