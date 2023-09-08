//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct PortraitView: NavigatableView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    
    @StateObject var portraitViewModel = PortraitViewModel()
    let speciesId: Int64?
    
    var body: some View {
        BaseView(oneColor: true) {
        ScrollView {
                VStack {
                    if let portrait = portraitViewModel.portrait {
                        ZStack { // header
                            if let meta = portrait.descriptionImage {
                                PortraitImageView(meta: meta, showText: false)
                            }
                            VStack {
                                Spacer()
                                if let urlPart = portrait.audioUrl {
                                    SoundButton(url: URL(string: Configuration.strapiUrl + urlPart)!)
                                        .frame(height: .fabSize)
                                        .padding(.horizontal, .defaultPadding)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                                }
                                RoundBottomView()
                                    .frame(height: .roundBottomHeight)
                            }
                        }

                        VStack { // names
                            Text(portrait.species.sciname)
                                .font(.nbSubtitle3)
                                .foregroundColor(.onPrimarySignalHigh)
                                .italic()
                            Text(portrait.species.gername?.uppercased() ?? "ARTNAME")
                                .font(.nbHeadline2)
                                .foregroundColor(.onPrimaryHighEmphasis)
                        }

                        
                        VStack(alignment: .leading) { // description
                            Text("Beschreibung")
                                .font(.nbHeadline4)
                                .padding([.top, .bottom], .defaultPadding)
                            Text(portrait.description)
                                .font(.nbBody1)
                            
                            VStack(alignment: .leading) { // similar species
                                SpeciesFeaturesView(portraitId: portrait.id, species: portrait.species)
                                SimilarSpeciesView(portraitId: portrait.id)
                            }
                            .padding(.defaultPadding)
                            .background {
                                Rectangle()
                                    .foregroundColor(.featureColor)
                            }
                            
                            VStack(alignment: .leading) {
                                if let meta = portrait.inTheCityImage {
                                    PortraitImageView(meta: meta, showText: true)
                                        .padding([.top, .bottom], .halfPadding)
                                }
                                Text("In der Stadt")
                                    .font(.nbHeadline4)
                                    .padding(.bottom, .defaultPadding)
                                Text(portrait.inTheCity)
                                    .font(.nbBody1)
                                

                                if let meta = portrait.goodToKnowImage {
                                    PortraitImageView(meta: meta, showText: true)
                                        .padding([.top, .bottom], .halfPadding)
                                }
                                Text("Wissenswertes")
                                    .font(.nbHeadline4)
                                    .padding(.bottom, .defaultPadding)
                                GoodToKnowView(portraitId: portrait.id)
                                
                                Text("Quellen")
                                    .font(.nbHeadline4)
                                if let sources = portrait.sources {
                                    Text(sources)
                                        .font(.nbBody1)
                                }
                            }
                        }
                        .padding(.defaultPadding)
                        .background {
                            RoundedRectangle(cornerRadius: .largeCornerRadius)
                                .foregroundColor(.secondaryColor)
                        }

                    } else {
                        Text("Sorry No Portrait")
                    }
                }
            }
            .task {
                if let speciesId = speciesId {
                    portraitViewModel.filter(speciesId: speciesId)
                }
            }
        }
    }
}

struct PortraitView_Previews: PreviewProvider {
    static var previews: some View {
        PortraitView(speciesId: Species.sampleData.id)
    }
}
