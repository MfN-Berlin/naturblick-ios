//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct GoodToKnowView: View {
    @StateObject var goodToKNowViewModel = GoodToKNowViewModel()
    let portraitId: Int64
    
    var body: some View {
        VStack {
            ForEach(goodToKNowViewModel.facts) { x in
                Text(x.fact)
            }
        }
        .task {
            goodToKNowViewModel.filter(portraitId: portraitId)
        }
    }
}

struct GoodToKnowView_Previews: PreviewProvider {
    static var previews: some View {
        GoodToKnowView(portraitId: 1)
    }
}
