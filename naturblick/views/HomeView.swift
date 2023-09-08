//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

class HomeViewController: NavigatableHostingController<HomeView> {
    let persistenceController: ObservationPersistenceController
    let createFlow: CreateFlowViewModel
    init() {
        persistenceController = ObservationPersistenceController()
        createFlow = CreateFlowViewModel(persistenceController: persistenceController)
        let view = HomeView(persistenceController: persistenceController, createFlow: createFlow)
        super.init(rootView: view)
        createFlow.setViewController(controller: self)
    }
}

struct HomeView: NavigatableView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    
    func configureNavigationItem(item: UINavigationItem) {
        let appearance = item.standardAppearance?.copy()
        appearance?.configureWithTransparentBackground()
        item.standardAppearance = appearance
        item.compactAppearance = nil
        item.scrollEdgeAppearance = nil
        item.compactScrollEdgeAppearance = nil
    }
    
    let firstRowWidthFactor: CGFloat = 4.5
    let secondRowWidthFactor: CGFloat = 5
    @Environment(\.colorScheme) var colorScheme
    	
    @State var navigateTo: NavigationDestination? = nil
    
    @State var isShowingPortrait = false
    @State var speciesId: Int64? = nil
    
    @State var isShowingResetPassword = false
    @State var token: String? = nil
    
    @State var isShowingLogin = false
    @AppStorage("activated") var activated: Bool = false
    @ObservedObject var persistenceController: ObservationPersistenceController
    @ObservedObject var createFlow: CreateFlowViewModel

    var body: some View {
        BaseView(oneColor: true) {
            GeometryReader { geo in
                
                let topRowSize = geo.size.width * 0.25
                let bottomRowSize = geo.size.width * 0.2
                
                ZStack {
                    VStack {
                        Image("Kingfisher")
                            .resizable()
                            .scaledToFit()
                            .clipped()
                            .ignoresSafeArea()
                            .padding(.bottom, -geo.safeAreaInsets.top)
                        Spacer()
                    }
                    VStack {
                        VStack {
                            Image("logo24")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geo.size.width / 4, alignment: .center)
                                .foregroundColor(.onPrimaryHighEmphasis)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .overlay(alignment: .bottomLeading) {
                            Image("mfn_logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geo.size.width / 5)
                                .foregroundColor(.gray)
                                .padding(.defaultPadding)
                        }
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                MenuView(navigateTo: $navigateTo)
                            }
                        }
                        RoundBottomView()
                            .frame(height: .roundBottomHeight)
                        
                        VStack {
                            Text("Identify animals and plants")
                                .foregroundColor(.onPrimaryHighEmphasis)
                                .font(.nbHeadline6)
                                .padding(.defaultPadding)
                            
                            HStack(alignment: .top) {
                                Spacer()
                                NavigationLink(
                                    tag: .birdId, selection: $navigateTo,
                                    destination: {
                                        ObservationListView(initialCreateAction: .createSoundObservation)
                                    }) {
                                        HomeViewButton(
                                            text: "Record a bird sound",
                                            color: Color.onPrimaryButtonPrimary,
                                            image: Image("microphone"),
                                            size: topRowSize)
                                    }
                                Spacer()
                                    HomeViewButton(text: "Select characteristics",
                                                   color: Color.onPrimaryButtonPrimary,
                                                   image: Image("characteristics24"),
                                                   size: topRowSize
                                    )
                                    .onTapGesture {
                                        let nextViewController = GroupsView(
                                            groups: Group.characterGroups,
                                            destination: { group in
                                                CharactersView(group: group)
                                            }
                                        ).setUpViewController()
                                        viewController?.navigationController?.pushViewController(nextViewController, animated: true)
                                    }
                                Spacer()
                               
                                        HomeViewButton(text: "Photograph a plant",
                                                       color: Color.onPrimaryButtonPrimary,
                                                       image: Image("photo24"),
                                                       size: topRowSize
                                        )
                                        .onTapGesture {
                                            createFlow.takePhoto()
                                        }
                                Spacer()
                            }
                            .padding(.bottom, .defaultPadding)
                            
                            HStack(alignment: .top) {
                                Spacer()
                                NavigationLink(tag: .fieldbook, selection: $navigateTo, destination: {
                                    ObservationListView(initialCreateAction: nil)
                                }) {
                                    HomeViewButton(
                                        text: "Fieldbook",
                                        color: Color.onPrimaryButtonSecondary,
                                        image: Image("feldbuch24"),
                                        size: bottomRowSize
                                    )
                                }
                                Spacer()
                                HomeViewButton(text: "Learn about species",
                                               color: Color.onPrimaryButtonSecondary,
                                               image: Image("ic_specportraits"),
                                               size: bottomRowSize
                                ).onTapGesture {
                                    let nextViewController = GroupsView(
                                        groups: Group.groups,
                                        destination: { group in
                                            SpeciesListView(filter: .group(group))
                                        }).setUpViewController()
                                    viewController?.navigationController?.pushViewController(nextViewController, animated: true)
                                }
                                Spacer()
                            }
                            .padding(.bottom, .defaultPadding * 2)
                        }
                        .frame(width: geo.size.width)
                        .background {
                            Rectangle()
                                .foregroundColor(.primaryColor)
                        }
                    }
                }
            }
            .background {
                SwiftUI.Group {
                    NavigationLink(
                        tag: .about, selection: $navigateTo,
                        destination: {
                            AboutView()
                        }
                    ) {
                    }
                    NavigationLink(
                        tag: .imprint, selection: $navigateTo,
                        destination: {
                            ImprintView()
                        }
                    ) {
                    }
                    NavigationLink(
                        tag: .account, selection: $navigateTo,
                        destination: {
                            AccountView()
                        }
                    ) {
                    }
                    NavigationLink(
                        tag: .settings, selection: $navigateTo,
                        destination: {
                            SettingsView()
                        }
                    ) {
                    }
                    NavigationLink(
                        tag: .help, selection: $navigateTo,
                        destination: {
                            HelpView()
                        }
                    ) {
                    }
                }
            }
        }
    }
}

