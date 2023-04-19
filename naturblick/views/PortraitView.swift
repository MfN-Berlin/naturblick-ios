//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct PortraitView: View {
    @StateObject var portraitViewModel = PortraitViewModel()
    let speciesId: Int64
    
    var body: some View {
        BaseView {
            ScrollView {
                VStack{
                    if let portrait = portraitViewModel.portrait {
                        HStack {
                            Text(portrait.species.gername ?? "Deutscher Artname")
                                .font(.nbHeadline3)
                            
                            if let url = portrait.audioUrl {
                                SoundButton(url: url)
                                    .frame(height: 35)
                            }
                        }
                        Text(portrait.species.sciname)
                        VStack {
                            Text("Beschreibung")
                                .font(.nbHeadline4)
                            if let meta = portrait.descriptionImage {
                                PortraitImageView(meta: meta)
                            }
                            Text(portrait.description)
                        }
                        
                        VStack {
                            Text("Verwechslungsarten")
                                .font(.nbHeadline4)
                            SimilarSpeciesView(portraitId: portrait.id)
                        }
                        
                        VStack {
                            Text("In der Stadt")
                                .font(.nbHeadline4)
                            if let meta = portrait.inTheCityImage {
                                PortraitImageView(meta: meta)
                            }
                            Text(portrait.inTheCity)
                        }
                        VStack {
                            Text("Wissenswertes")
                                .font(.nbHeadline4)
                            if let meta = portrait.goodToKnowImage {
                                PortraitImageView(meta: meta)
                            }
                            GoodToKnowView(portraitId: portrait.id)
                        }
                        VStack {
                            Text("Quellen")
                                .font(.nbHeadline4)
                            if let sources = portrait.sources {
                                Text(sources)
                            }
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
}

struct PortraitView_Previews: PreviewProvider {
    static var previews: some View {
        PortraitView(speciesId: Species.sampleData.id)
    }
}
