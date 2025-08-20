//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct ChevronView: View {
    var body: some View {
        Image("chevron_right_24")
            .resizable()
            .foregroundColor(.onSecondarySignalLow)
            .frame(width: .chevron, height: .chevron)
    }
}

struct ChevronView_Previews: PreviewProvider {
    static var previews: some View {
        ChevronView()
    }
}
