//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

class PortraitViewController: HostingController<PortraitView> {
    let createFlow: CreateFlowViewModel
    init(species: SpeciesListItem, inSelectionFlow: Bool) {
        createFlow = CreateFlowViewModel(persistenceController: ObservationPersistenceController())
        let view = PortraitView(flow: createFlow, species: species, inSelectionFlow: inSelectionFlow)
        super.init(rootView: view)
        createFlow.setViewController(controller: self)
    }
}

struct PortraitView: HostedView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    var viewName: String? {
        species.name
    }
    var alwaysDarkBackground: Bool = true
    
    @StateObject var portraitViewModel = PortraitViewModel()
    @ObservedObject var flow: CreateFlowViewModel
    let species: SpeciesListItem
    let inSelectionFlow: Bool
    
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
                                .overline(color: .onPrimarySignalHigh)
                                .multilineTextAlignment(.center)
                            Text(portrait.species.gername?.uppercased() ?? String(localized: "speciesname").uppercased())
                                .headline4(color: .onPrimaryHighEmphasis)
                                .multilineTextAlignment(.center)
                            if let synonym = portrait.species.gersynonym {
                                Text("also: \(synonym)")
                                    .caption(color: .onPrimarySignalLow)
                                    .multilineTextAlignment(.center)
                            }
                            if !inSelectionFlow {
                                Button("i_observed", icon: "artportraits24") {
                                    flow.selectManual(species: species)
                                }
                                .buttonStyle(AuxiliaryOnPrimaryButton())
                            }
                        }
                        .padding(.bottom, .defaultPadding * 2)
                        .padding([.top, .horizontal], .defaultPadding)
                        
                        VStack(alignment: .leading) { // description
                            Text("description")
                                .headline4()
                                .padding(.bottom, .defaultPadding)
                            Text(portrait.description)
                                .body1()
                            VStack(alignment: .leading) { // similar species
                                SpeciesFeaturesView(portraitId: portrait.id, species: portrait.species)
                                SimilarSpeciesView(portraitId: portrait.id, holder: holder, inSelectionFlow: inSelectionFlow)
                            }
                            .padding(.defaultPadding)
                            .background {
                                RoundedRectangle(cornerRadius: .largeCornerRadius)                                    .foregroundColor(.featureColor)
                            }
                            
                            VStack(alignment: .leading) {
                                if let meta = portrait.inTheCityImage {
                                    PortraitImageView(geo: geo, image: meta, headerImage: false)
                                        .padding(.top, .halfPadding)
                                }
                                Text("in_the_city")
                                    .headline4()
                                    .padding([.top, .bottom], .defaultPadding)
                                Text(portrait.inTheCity)
                                    .body1()
                                    .padding(.bottom, .defaultPadding)

                                
                                if let meta = portrait.goodToKnowImage {
                                    PortraitImageView(geo: geo, image: meta, headerImage: false)
                                        .padding(.bottom, .halfPadding)
                                }
                                Text("good_to_know")
                                    .headline4()
                                    .padding(.bottom, .defaultPadding)
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
                                .padding(.bottom, .defaultPadding)
                                
                                if let sources = portrait.sources {
                                    Text("sources")
                                        .headline4()
                                        .padding(.bottom, .defaultPadding)
                                    Text(sources)
                                        .body1()
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
                        Text("no_portrait")
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
        PortraitView(flow: CreateFlowViewModel(persistenceController: ObservationPersistenceController(inMemory: true)), species: SpeciesListItem.sampleData, inSelectionFlow: false)
    }
}
