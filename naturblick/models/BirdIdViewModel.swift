//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import SwiftUI

@MainActor
class BirdIdViewModel: ObservableObject {
    private let client = BackendClient()

    @Published private(set) var spectrogram: UIImage? = nil
    
    func downloadSpectrogram(sound: Sound) async throws {
        try await client.upload(sound: sound.url, mediaId: sound.id)
        let spectrogram = try await client.spectrogram(mediaId: sound.id)
        self.spectrogram = spectrogram
    }
    
    func identify(sound: Sound, start: CGFloat, end: CGFloat) async throws {
        guard let spectrogram = spectrogram else {
            preconditionFailure("Spectrogram is nil when calling identify")
        }
        let result = try await client.soundId(mediaId: sound.id.uuidString, start: Int(start * spectrogram.size.width * 10), end: Int(end * spectrogram.size.width * 10))
        print(result)
    }
}
