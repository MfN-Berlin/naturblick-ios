//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct BirdIdView: View {
    @State var sound: Sound? = nil
    var body: some View {
        if let sound = self.sound {
            SpectrogramView(sound: sound)
        } else {
            BirdRecorderView(sound: $sound)
        }
    }
}

struct BirdIdView_Previews: PreviewProvider {
    static var previews: some View {
        BirdIdView()
    }
}
