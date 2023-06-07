//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct SpectrogramView: View {
    let sound: Sound
    @StateObject private var model = SpectrogramViewModel()
    var body: some View {
        if let spectrogram = model.spectrogram {
            Image(uiImage: spectrogram)
        } else {
            Text("Downloading spectrogram")
                .task {
                    await model.downloadSpectrogram(sound: sound)
                }
        }
    }
}

struct SpectrogramView_Previews: PreviewProvider {
    static var previews: some View {
        SpectrogramView(sound: Sound())
    }
}
