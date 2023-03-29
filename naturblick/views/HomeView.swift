//
// Copyright © 2023 Museum für Naturkunde Berlin.
// All Rights Reserved.

import SwiftUI

struct HomeView: View {

    var body: some View {
        DarkView {
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
                                .foregroundColor(.white)
                        }
                        .overlay(alignment: .bottom) {
                            Image("oval")
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
                            .foregroundColor(.nbWhite)
                            .font(.nbHeadline6)
                            .padding(.bottom)
                        HStack(spacing: 16) {
                            HomeViewButton(text: "Vogelstimmen\naufnehmen",
                                           color: Color.secondary200,
                                           image: Image("microphone")
                            )
                            HomeViewButton(text: "Merkmale\nauswählen",
                                           color: Color.secondary200,
                                           image: Image("characteristics24")
                            )
                            HomeViewButton(text: "Pflanze\nfotografieren",
                                           color: Color.secondary200,
                                           image: Image("photo24")
                            )
                        }
                        .padding(8)
                        HStack(spacing: 32) {
                            HomeViewButton(text: "Feldbuch",
                                           color: Color.primary700,
                                           image: Image("feldbuch24")
                            )
                            NavigationLink(destination: GroupsView()) {
                                HomeViewButton(text: "Arten\nkennenlernen",
                                               color: Color.primary700,
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
