//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct PortraitView: View {
    @StateObject var portraitViewModel = PortraitViewModel()
    @StateObject var similarSpeciesViewModel = SimilarSpeciesViewModel()
    let species: SpeciesListItem
    let present: (UIViewController, (() -> Void)?) -> Void
    let similarSpeciesDestination: (SpeciesListItem) -> Void
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack {
                    if let portrait = portraitViewModel.portrait {
                        ZStack { // header
                            if let meta = portrait.descriptionImage {
                                PortraitHeaderView(width: geo.size.width, image: meta, landscape: portrait.landscape, focus: portrait.focus)
                            }
                            HStack(spacing: .defaultPadding) {
                                if let url = portrait.descriptionImage?.largest?.url {
                                    FullscreenButtonView(present: present, url: URL(string: Configuration.djangoUrl + url)!)
                                }
                                if let urlPart = portrait.audioUrl {
                                    SoundButton(url: URL(string: Configuration.djangoUrl + urlPart)!, speciesId: species.speciesId)
                                }
                            }
                            .frame(height: .fabSize)
                            .padding(.horizontal, .defaultPadding)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                        }
                        
                        VStack(spacing: .zero) { // names
                            Text(portrait.species.sciname)
                                .overline(color: .onPrimarySignalHigh)
                                .multilineTextAlignment(.center)
                                .accessibilityLabel(Text("sciname \(portrait.species.sciname)"))
                            Text(portrait.species.speciesName?.uppercased() ?? portrait.species.sciname.uppercased())
                                .headline4(color: .onPrimaryHighEmphasis)
                                .multilineTextAlignment(.center)
                            if let synonym = portrait.species.synonym {
                                Text("also \(synonym)")
                                    .caption(color: .onPrimarySignalLow)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(.bottom, .defaultPadding * 2)
                        .padding([.top, .horizontal], .defaultPadding)
                        
                        VStack(alignment: .leading, spacing: .defaultPadding) { // description
                            SwiftUI.Group {
                                Text("description")
                                    .headline4()
                                    .padding(.top, .defaultPadding)
                                Text(portrait.description)
                                    .body1()
                            }
                            .accessibilityElement(children: .combine)
                            VStack(alignment: .leading, spacing: .defaultPadding) { // similar species
                                SpeciesFeaturesView(portraitId: portrait.id, species: portrait.species)
                                if !similarSpeciesViewModel.mixups.isEmpty {
                                    SimilarSpeciesView(similarSpeciesViewModel: similarSpeciesViewModel, similarSpeciesDestination: similarSpeciesDestination)
                                }
                            }
                            .padding(.defaultPadding)
                            .background {
                                RoundedRectangle(cornerRadius: .largeCornerRadius)
                                    .foregroundColor(.featureColor)
                            }
                            
                            VStack(alignment: .leading, spacing: .defaultPadding) {
                                if let meta = portrait.inTheCityImage {
                                    PortraitImageView(width: geo.size.width, image: meta)
                                }
                                Text("in_the_city")
                                    .headline4()
                                Text(portrait.inTheCity)
                                    .body1()
                                
                                if let meta = portrait.goodToKnowImage {
                                    PortraitImageView(width: geo.size.width, image: meta)
                                }
                                Text("good_to_know")
                                    .headline4()
                                ForEach(portrait.goodToKnows, id: \.self) { goodToKnow in
                                    HStack {
                                        Rectangle()
                                            .fill(Color.onSecondarySignalLow)
                                            .frame(width: .goodToKnowLineWidth)
                                            .frame(maxHeight: .infinity)
                                        Text(goodToKnow)
                                            .body1()
                                            .padding(.leading, .defaultPadding)
                                    }
                                }
                                
                                if let sources = portrait.sources {
                                    Text("sources")
                                        .headline4()
                                    Text(sources.toDetectedAttributedString())
                                        .body1()
                                }
                            }
                        }
                        .padding(.defaultPadding)
                        .background{
                            Rectangle()
                                .foregroundColor(.secondaryColor)
                                .padding(.bottom, .largeCornerRadius)
                                .cornerRadius(.largeCornerRadius)
                                .padding(.bottom, -.largeCornerRadius)
                        }
                        .task {
                            similarSpeciesViewModel.filter(portraitId: portrait.id)
                        }
                    } else {
                        Text("no_portrait").padding()
                    }
                }
                .background(Color.primaryHomeColor)
            }
            .background(LinearGradient(
                stops: [
                    .init(color: .primaryHomeColor, location: 0.5),
                   .init(color: .secondaryColor, location: 0.5),
                ],
                startPoint: .top, endPoint: .bottom))
            
            .onAppear() {
                AnalyticsTracker.trackPortrait(species: species)
            }
            .task {
                portraitViewModel.filter(speciesId: species.speciesId)
            }
        }
    }
}

struct PortraitView_Previews: PreviewProvider {
    
    static var previews: some View {
        PortraitView(species: SpeciesListItem.sampleData, present: {u, v in}) { _ in
            
        }
    }
}
