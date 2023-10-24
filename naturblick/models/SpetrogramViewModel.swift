//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import UIKit

class SpectrogramViewModel: HttpErrorViewModel {
    let client = BackendClient()
    let mediaId: UUID
    @Published var sound: NBSound? = nil
    @Published var spectrogram: UIImage? = nil

    init(mediaId: UUID) {
        self.mediaId = mediaId
        super.init()
        downloadSpectrogram()
    }
    
    @MainActor func spectrogramDownloaded(spectrogram: UIImage) {
        self.spectrogram = spectrogram
    }
    
    func downloadSpectrogram() {
        Task {
            do {
                let sound = try await NBSound(id: mediaId)
                try await client.upload(sound: sound.url, mediaId: sound.id)
                let spectrogram = try await client.spectrogram(mediaId: sound.id)
                spectrogramDownloaded(spectrogram: spectrogram)
            } catch {
                let _ = handle(error)
            }
        }
    }
}
