//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

struct HomeView: View {

    let firstRowWidthFactor: CGFloat = 4.5
    let secondRowWidthFactor: CGFloat = 5
    @Environment(\.colorScheme) var colorScheme
    
    @State var navigateTo: NavigationDestination? = nil
    
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
                            ToolbarItem(placement: .navigationBarLeading) {
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
                                NavigationLink(
                                    tag: .characteristics, selection: $navigateTo,
                                    destination: {
                                        GroupsView(
                                            groups: Group.characterGroups,
                                            destination: { group in
                                                CharactersView(group: group)
                                            }
                                        )
                                    }
                                ) {
                                    HomeViewButton(text: "Select characteristics",
                                                   color: Color.onPrimaryButtonPrimary,
                                                   image: Image("characteristics24"),
                                                   size: topRowSize
                                    )
                                }
                                Spacer()
                                NavigationLink(
                                    tag: .plantId, selection: $navigateTo,
                                    destination: {
                                        ObservationListView(initialCreateAction: .createImageObservation)
                                    }) {
                                        HomeViewButton(text: "Photograph a plant",
                                                       color: Color.onPrimaryButtonPrimary,
                                                       image: Image("photo24"),
                                                       size: topRowSize
                                        )
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
                                NavigationLink(
                                    tag: .species, selection: $navigateTo,
                                    destination: {
                                        GroupsView(
                                            groups: Group.groups,
                                            destination: { group in
                                                SpeciesListView(filter: .group(group))
                                            })
                                    }
                                ) {
                                    HomeViewButton(text: "Learn about species",
                                                   color: Color.onPrimaryButtonSecondary,
                                                   image: Image("ic_specportraits"),
                                                   size: bottomRowSize
                                    )
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
            }.background {
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
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView()
        }
    }
}
