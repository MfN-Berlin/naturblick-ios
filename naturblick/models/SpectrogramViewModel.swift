//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import SwiftUI

@MainActor
class SpectrogramViewModel: ObservableObject {
    private let client = BackendClient()

    @Published private(set) var spectrogram: UIImage? = nil

    func downloadSpectrogram(sound: Sound) async {
        try! await client.upload(sound: sound.url, mediaId: sound.id)
        let spectrogram = try! await client.spectrogram(mediaId: sound.id)
        self.spectrogram = spectrogram
    }
}
