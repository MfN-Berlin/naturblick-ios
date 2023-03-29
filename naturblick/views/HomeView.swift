//
// Copyright © 2023 Museum für Naturkunde Berlin.
// All Rights Reserved.

import SwiftUI
import OSLog

struct HomeView: View {

    let firstRowWidthFactor: CGFloat = 4.5
    let secondRowWidthFactor: CGFloat = 5
    
    var body: some View {
        DarkView {
            GeometryReader { geo in
                VStack {
                    Image("Kingfisher")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width,
                               height: geo.size.height * 0.6,
                               alignment: Alignment.top)
                        .clipped()
                        .overlay(alignment: .center) {
                            Image("logo24")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
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
                                .frame(width: 90, height: 90)
                                .foregroundColor(.gray)
                                .padding()
                                .padding(.bottom, 40)
                        }
                        .ignoresSafeArea()
                        .padding(.bottom, -geo.safeAreaInsets.top)
                    
                    VStack {
                        Text("Bestimme Tieren und Pflanzen")
                            .foregroundColor(.nbWhite)
                            .font(.headline)
                            .padding(.bottom)
                        HStack(alignment: .imageTitleAlignmentGuide, spacing: 16) {
                            HomeViewButton(text: "Vogelstimmen\naufnehmen",
                                           color: Color.secondary200,
                                           width: geo.size.width / self.firstRowWidthFactor,
                                           image: Image("microphone")
                            )
                            HomeViewButton(text: "Merkmale\nauswählen",
                                           color: Color.secondary200,
                                           width: geo.size.width / self.firstRowWidthFactor,
                                           image: Image("characteristics24")
                            )
                            HomeViewButton(text: "Pflanze\nfotografieren",
                                           color: Color.secondary200,
                                           width: geo.size.width / self.firstRowWidthFactor,
                                           image: Image("photo24")
                            )
                        }.padding(8)
                        HStack(alignment: .imageTitleAlignmentGuide, spacing: 32) {
                            HomeViewButton(text: "Feldbuch",
                                           color: Color.primary700,
                                           width: geo.size.width / self.secondRowWidthFactor,
                                           image: Image("feldbuch24")
                            )
                            NavigationLink(destination: GroupsView()) {
                                HomeViewButton(text: "Arten\nkennenlernen",
                                               color: Color.primary700,
                                               width: geo.size.width / self.secondRowWidthFactor,
                                               image: Image("ic_specportraits")
                                )
                            }
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
