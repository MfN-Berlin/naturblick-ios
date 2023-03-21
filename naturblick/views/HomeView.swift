//
// Copyright © 2023 Museum für Naturkunde Berlin.
// All Rights Reserved.

import SwiftUI

struct HomeView : View {
    
    var body: some View {
        DarkView {
            VStack {
                RatioContainer {
                    GeometryReader { geo in
                        Image("Kingfisher")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .ignoresSafeArea()
                            .scaledToFill()
                            .frame(height: geo.size.height - geo.size.height * 0.55)
                    }
                    
                    VStack {
                        Text("Bestimme Tieren und Pflanzen").foregroundColor(.nb_white)
                        HStack {
                            HomeViewButton(text: "Vogelstimmen aufnehmen") {
                                Image(systemName: "questionmark")
                            }
                            HomeViewButton(text: "Merkmale auswählen") {
                                Image(systemName: "questionmark")
                            }
                            HomeViewButton(text: "Pflanze fotografieren") {
                                Image(systemName: "questionmark")
                            }
                        }.padding(32)
                        HStack {
                            HomeViewButton(text: "Feldbuch") {
                                Image(systemName: "questionmark")
                            }
                            NavigationLink(destination: GroupsView()) {
                                HomeViewButton(text: "Arten kennenlernen") {
                                    Image(systemName: "questionmark")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct HomeView_Previews : PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView()
        }
    }
}
