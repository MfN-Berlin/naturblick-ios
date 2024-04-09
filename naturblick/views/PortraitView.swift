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
    
    init(species: SpeciesListItem, inSelectionFlow: Bool, createFlow: CreateFlowViewModel) {
        self.createFlow = createFlow
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
    @StateObject var similarSpeciesViewModel = SimilarSpeciesViewModel()
    @ObservedObject var flow: CreateFlowViewModel
    let species: SpeciesListItem
    let inSelectionFlow: Bool
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                SwiftUI.Group {
                    if let portrait = portraitViewModel.portrait {
                        ZStack { // header
                            if let meta = portrait.descriptionImage {
                                PortraitImageView(geo: geo, image: meta, headerImage: true)
                            }
                            VStack(spacing: .zero) {
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
                        
                        VStack(spacing: .zero) { // names
                            Text(portrait.species.sciname)
                                .overline(color: .onPrimarySignalHigh)
                                .multilineTextAlignment(.center)
                            Text(portrait.species.speciesName?.uppercased() ?? String(localized: "speciesname").uppercased())
                                .headline4(color: .onPrimaryHighEmphasis)
                                .multilineTextAlignment(.center)
                            if let synonym = portrait.species.synonym {
                                Text("also: \(synonym)")
                                    .caption(color: .onPrimarySignalLow)
                                    .multilineTextAlignment(.center)
                            }
                            if !inSelectionFlow {
                                Button("i_observed", icon: "artportraits24") {
                                    flow.selectManual(species: species)
                                }
                                .buttonStyle(AuxiliaryOnPrimaryButton())
                                .padding(.top, .defaultPadding)
                            }
                        }
                        .padding(.bottom, .defaultPadding * 2)
                        .padding([.top, .horizontal], .defaultPadding)
                        
                        VStack(alignment: .leading, spacing: .defaultPadding) { // description
                            Text("description")
                                .headline4()
                            Text(portrait.description)
                                .body1()
                            VStack(alignment: .leading, spacing: .defaultPadding) { // similar species
                                SpeciesFeaturesView(portraitId: portrait.id, species: portrait.species)
                                if !similarSpeciesViewModel.mixups.isEmpty {
                                    SimilarSpeciesView(similarSpeciesViewModel: similarSpeciesViewModel, holder: holder, inSelectionFlow: inSelectionFlow)
                                }
                            }
                            .padding(.defaultPadding)
                            .background {
                                RoundedRectangle(cornerRadius: .largeCornerRadius)
                                    .foregroundColor(.featureColor)
                            }
                            
                            VStack(alignment: .leading, spacing: .defaultPadding) {
                                if let meta = portrait.inTheCityImage {
                                    PortraitImageView(geo: geo, image: meta, headerImage: false)
                                }
                                Text("in_the_city")
                                    .headline4()
                                Text(portrait.inTheCity)
                                    .body1()
                                
                                if let meta = portrait.goodToKnowImage {
                                    PortraitImageView(geo: geo, image: meta, headerImage: false)
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
                        .background {
                            RoundedRectangle(cornerRadius: .largeCornerRadius)
                                .foregroundColor(.secondaryColor)
                                .nbShadow()
                        }
                        .task {
                            similarSpeciesViewModel.filter(portraitId: portrait.id)
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
