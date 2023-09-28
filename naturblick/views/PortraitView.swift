//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import BottomSheet

struct PortraitView: NavigatableView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    var viewName: String? {
        species.name
    }
    var alwaysDarkBackground: Bool = true
    
    @StateObject var portraitViewModel = PortraitViewModel()
    let species: SpeciesListItem
    
    @State var bottomSheetPosition: BottomSheetPosition = .hidden
    
    @State var license: PortraitImage?
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack {
                    if let portrait = portraitViewModel.portrait {
                        ZStack { // header
                            if let meta = portrait.descriptionImage {
                                PortraitImageView(geo: geo, image: meta, headerImage: true, bottomSheetPosition: $bottomSheetPosition, license: $license)
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
                                .font(.nbOverline)
                                .foregroundColor(.onPrimarySignalHigh)
                                .italic()
                                .multilineTextAlignment(.center)
                            Text(portrait.species.gername?.uppercased() ?? "ARTNAME")
                                .font(.nbHeadline4)
                                .foregroundColor(.onPrimaryHighEmphasis)
                                .multilineTextAlignment(.center)
                            if let synonym = portrait.species.gersynonym {
                                Text("also: \(synonym)")
                                    .font(.nbCaption)
                                    .foregroundColor(.onPrimarySignalLow)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(.bottom, .defaultPadding * 2)
                        .padding([.top, .horizontal], .defaultPadding)
                        
                        
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
                                RoundedRectangle(cornerRadius: .largeCornerRadius)
                                    .foregroundColor(.featureColor)
                            }
                            
                            VStack(alignment: .leading) {
                                if let meta = portrait.inTheCityImage {
                                    PortraitImageView(geo: geo, image: meta, headerImage: false, bottomSheetPosition: $bottomSheetPosition, license: $license)
                                        .padding(.top, .halfPadding)
                                }
                                Text("In der Stadt")
                                    .font(.nbHeadline4)
                                    .padding([.top, .bottom], .defaultPadding)
                                Text(portrait.inTheCity)
                                    .font(.nbBody1)
                                    .padding(.bottom, .defaultPadding)

                                
                                if let meta = portrait.goodToKnowImage {
                                    PortraitImageView(geo: geo, image: meta, headerImage: false, bottomSheetPosition: $bottomSheetPosition, license: $license)
                                        .padding(.bottom, .halfPadding)
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
                                        .padding(.bottom, .defaultPadding)
                                    Text(sources)
                                        .font(.nbBody1)
                                        .padding(.bottom, .defaultPadding)
                                }
                            }
                        }
                        .padding(.defaultPadding)
                        .background {
                            RoundedRectangle(cornerRadius: .largeCornerRadius)
                                .foregroundColor(.secondaryColor)
                                .nbShadow()
                        }
                    } else {
                        Text("Sorry No Portrait")
                    }
                }
            }
            .bottomSheet(bottomSheetPosition: $bottomSheetPosition, switchablePositions: [.dynamic, .hidden], title: "License") {
                if let license = license {
                    CCInfoPopupView(imageSource: license.source,
                                    imageOwner: license.owner,
                                    imageLicense: license.license)
                }
             }
                .isResizable(false)
                .showCloseButton(true)
                .customBackground(
                    RoundedRectangle(cornerRadius: .largeCornerRadius)
                        .fill(Color.secondaryColor)
                        .nbShadow()
                )
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
