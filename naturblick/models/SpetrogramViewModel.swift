//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import UIKit

class SpectrogramViewModel: HttpErrorViewModel {
    let client = BackendClient()
    let sound: NBSound
    @Published var spectrogram: UIImage? = nil

    init(sound: NBSound) {
        self.sound = sound
        super.init()
        downloadSpectrogram()
    }
    
    @MainActor func spectrogramDownloaded(spectrogram: UIImage) {
        self.spectrogram = spectrogram
    }
    
    func downloadSpectrogram() {
        Task {
            do {
                try await client.upload(sound: sound.url, mediaId: sound.id)
                let spectrogram = try await client.spectrogram(mediaId: sound.id)
                spectrogramDownloaded(spectrogram: spectrogram)
            } catch {
                let _ = handle(error)
            }
        }
    }
}
