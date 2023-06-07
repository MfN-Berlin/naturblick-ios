//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

struct HomeView: View {

    let firstRowWidthFactor: CGFloat = 4.5
    let secondRowWidthFactor: CGFloat = 5
    @Environment(\.colorScheme) var colorScheme
    
    @State var navigateTo: AnyView?
    @State var isNavigationActive = false
    
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
                                MenuView(navigateTo: $navigateTo, isNavigationActive: $isNavigationActive)
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
                                HomeViewButton(text: "Record a bird sound",
                                               color: Color.onPrimaryButtonPrimary,
                                               image: Image("microphone"),
                                               size: topRowSize
                                )
                                Spacer()
                                NavigationLink(
                                    destination: MenuView.charactersDest
                                ) {
                                    HomeViewButton(text: "Select characteristics",
                                                   color: Color.onPrimaryButtonPrimary,
                                                   image: Image("characteristics24"),
                                                   size: topRowSize
                                    )
                                }
                                Spacer()
                                NavigationLink(
                                    destination: MenuView.imageIdDest) {
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
                                NavigationLink(
                                    destination: MenuView.fieldbookDestination
                                ) {
                                    HomeViewButton(
                                        text: "Fieldbook",
                                        color: Color.onPrimaryButtonSecondary,
                                        image: Image("feldbuch24"),
                                        size: bottomRowSize
                                    )
                                }
                                Spacer()
                                NavigationLink(
                                    destination: MenuView.portraitDest
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

            }
        }.background(
            NavigationLink(destination: self.navigateTo, isActive: $isNavigationActive) {
                EmptyView()
            })
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView()
        }
    }
}
