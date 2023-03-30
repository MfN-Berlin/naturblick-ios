//
// Copyright © 2023 Museum für Naturkunde Berlin.
// All Rights Reserved.


import SwiftUI

struct PortraitView: View {
    @StateObject var portraitViewModel = PortraitViewModel()
    let speciesId: Int64
    
    var body: some View {
        ScrollView {
            VStack{
                if let portrait = portraitViewModel.portrait {
                    Text("Beschreibung")
                        .font(.nbHeadline3)
                    if let meta = portrait.descriptionImage {
                        PortraitImageView(meta: meta)
                    }
                    Text(portrait.description)
                    
                    Text("Verwechslungsarten")
                        .font(.nbHeadline3)
                    SimilarSpeciesView(portraitId: portrait.id)
                    
                    Text("In der Stadt")
                        .font(.nbHeadline3)
                    if let meta = portrait.inTheCityImage {
                        PortraitImageView(meta: meta)
                    }
                    Text(portrait.inTheCity)
                    Text("Wissenswertes")
                        .font(.nbHeadline3)
                    if let meta = portrait.goodToKnowImage {
                        PortraitImageView(meta: meta)
                        GoodToKnowView(portraitId: portrait.id)
                    }
                } else {
                    Text("Sorry No Portrait")
                }
            }
        }
        .padding(.horizontal)
        .task {
            portraitViewModel.filter(speciesId: speciesId)
        }
    }
}

struct PortraitView_Previews: PreviewProvider {
    static var previews: some View {
        PortraitView(speciesId: Species.sampleData.id)
    }
}
