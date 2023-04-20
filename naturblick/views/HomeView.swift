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
                VStack {
                    Image("Kingfisher")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: geo.size.height * 0.6,
                               alignment: Alignment.top)
                        .clipped()
                        .overlay(alignment: .center) {
                            Image("logo24")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geo.size.width / 4)
                                .foregroundColor(.onPrimaryHighEmphasis)
                        }
                        .overlay(alignment: .bottom) {
                            Image(colorScheme == .dark ? "oval_dark" : "oval_light")
                                .aspectRatio(contentMode: .fit)
                        }
                        .overlay(alignment: .bottomLeading) {
                            Image("mfn_logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geo.size.width / 5)
                                .foregroundColor(.gray)
                                .offset(y: -50)
                                .padding()
                        }
                        .ignoresSafeArea()
                        .padding(.bottom, -geo.safeAreaInsets.top)
                    
                    Text("Bestimme Tieren und Pflanzen")
                        .foregroundColor(.onPrimaryHighEmphasis)
                        .font(.nbHeadline6)
                        .padding(.bottom)
                    HStack(spacing: 16) {
                        HomeViewButton(text: "Vogelstimmen\naufnehmen",
                                       color: Color.onPrimaryButtonPrimary,
                                       image: Image("microphone")
                        )
                        NavigationLink(
                            destination: GroupsView(
                                groups: Group.characterGroups,
                                destination: { group in
                                    CharactersView(group: group)
                                }
                            )
                        ) {
                            HomeViewButton(text: "Merkmale\nauswählen",
                                           color: Color.onPrimaryButtonPrimary,
                                           image: Image("characteristics24")
                            )
                        }
                        HomeViewButton(text: "Pflanze\nfotografieren",
                                       color: Color.onPrimaryButtonPrimary,
                                       image: Image("photo24")
                        )
                    }
                    .padding(8)
                    HStack(spacing: 32) {
                        NavigationLink(
                            destination: ObservationListView()
                        ) {
                            HomeViewButton(
                                text: "Feldbuch",
                                color: Color.onPrimaryButtonSecondary,
                                image: Image("feldbuch24")
                            )
                        }
                        NavigationLink(
                            destination: GroupsView(
                                groups: Group.groups,
                                destination: { group in
                                    SpeciesListView(filter: .group(group))
                                }
                            )
                        ) {
                            HomeViewButton(text: "Arten\nkennenlernen",
                                           color: Color.onPrimaryButtonSecondary,
                                           image: Image("ic_specportraits")
                            )
                        }
                    }
                    .frame(width: geo.size.width / 1.8)
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
