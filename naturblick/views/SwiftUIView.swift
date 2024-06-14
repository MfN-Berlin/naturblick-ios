//
// Copyright © 2024 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct SwiftUIView: View {
    var body: some View {
        ZStack {
                    Color.purple
                        .ignoresSafeArea()
            VStack {
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                Image("male")
                Image("female").foregroundColor(.black)
                Image("characteristics24")
                Image("characteristics24").foregroundColor(.black)

            }
            }
            
        

    }
}

#Preview {
    SwiftUIView()
}
