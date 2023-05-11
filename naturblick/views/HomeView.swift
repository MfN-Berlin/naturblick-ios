//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

struct HomeView: View {

    let firstRowWidthFactor: CGFloat = 4.5
    let secondRowWidthFactor: CGFloat = 5
    @Environment(\.colorScheme) var colorScheme

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
                        RoundBottomView()
                            .frame(height: .roundBottomHeight)
                        
                        VStack {
                            Text("Bestimme Tieren und Pflanzen")
                                .foregroundColor(.onPrimaryHighEmphasis)
                                .font(.nbHeadline6)
                                .padding(.defaultPadding)
                            
                            HStack(alignment: .top) {
                                Spacer()
                                HomeViewButton(text: "Vogelstimmen aufnehmen",
                                               color: Color.onPrimaryButtonPrimary,
                                               image: Image("microphone"),
                                               size: topRowSize
                                )
                                Spacer()
                                NavigationLink(
                                    destination: GroupsView(
                                        groups: Group.characterGroups,
                                        destination: { group in
                                            CharactersView(group: group)
                                        }
                                    )
                                ) {
                                    HomeViewButton(text: "Merkmale auswählen",
                                                   color: Color.onPrimaryButtonPrimary,
                                                   image: Image("characteristics24"),
                                                   size: topRowSize
                                    )
                                }
                                Spacer()
                                NavigationLink(
                                    destination: ObservationListView(obsAction: .createImageObservation)) {
                                        HomeViewButton(text: "Pflanze fotografieren",
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
                                NavigationLink(
                                    destination: ObservationListView(obsAction: .createManualObservation)
                                ) {
                                    HomeViewButton(
                                        text: "Feldbuch",
                                        color: Color.onPrimaryButtonSecondary,
                                        image: Image("feldbuch24"),
                                        size: bottomRowSize
                                    )
                                }
                                Spacer()
                                NavigationLink(
                                    destination: GroupsView(
                                        groups: Group.groups,
                                        destination: { group in
                                            SpeciesListView(filter: .group(group))
                                        }
                                    )
                                ) {
                                    HomeViewButton(text: "Arten kennenlernen",
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
