//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct PortraitView: NavigatableView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    var viewName: String? {
        species.name
    }
    
    @StateObject var portraitViewModel = PortraitViewModel()
    let species: SpeciesListItem
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack {
                    if let portrait = portraitViewModel.portrait {
                        ZStack { // header
                            if let meta = portrait.descriptionImage {
                                PortraitImageView(geo: geo, image: meta, headerImage: true)
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
                                SimilarSpeciesView(portraitId: portrait.id, holder: holder)
                            }
                            .padding(.defaultPadding)
                            .background {
                                Rectangle()
                                    .foregroundColor(.featureColor)
                            }
                            
                            VStack(alignment: .leading) {
                                if let meta = portrait.inTheCityImage {
                                    PortraitImageView(geo: geo, image: meta, headerImage: false)
                                        .padding([.top, .bottom], .halfPadding)
                                }
                                Text("In der Stadt")
                                    .font(.nbHeadline4)
                                    .padding(.bottom, .defaultPadding)
                                Text(portrait.inTheCity)
                                    .font(.nbBody1)
                                
                                
                                if let meta = portrait.goodToKnowImage {
                                    PortraitImageView(geo: geo, image: meta, headerImage: false)
                                        .padding([.top, .bottom], .halfPadding)
                                }
                                Text("Wissenswertes")
                                    .font(.nbHeadline4)
                                    .padding(.bottom, .defaultPadding)
                                ForEach(portrait.goodToKnows, id: \.self) { goodToKnow in
                                    HStack {
                                        Rectangle()
                                            .fill(Color.onSecondarySignalLow)
                                            .frame(width: .goodToKnowLineWidth)
                                            .frame(maxHeight: .infinity)
                                        Text(goodToKnow)
                                            .padding(.leading, .defaultPadding)
                                    }
                                }
                                .padding(.bottom, .defaultPadding)
                                
                                if let sources = portrait.sources {
                                    Text("Quellen")
                                        .font(.nbHeadline4)
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
                portraitViewModel.filter(speciesId: species.speciesId)
            }
        }
    }
}

struct PortraitView_Previews: PreviewProvider {
    static var previews: some View {
        PortraitView(species: SpeciesListItem.sampleData)
    }
}
