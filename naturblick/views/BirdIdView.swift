//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct BirdIdView: View {
    @Binding var data: SoundData
    @StateObject private var model = BirdIdViewModel()
    @State private var isPresented: Bool = false
    @State private var error: HttpError? = nil
    
    func identifyAndCrop(sound: NBSound, spectrogram: UIImage) {
        Task {
            do {
                let crop = UIGraphicsImageRenderer(size: .thumbnail, format: .noScale).image { _ in
                    let cropRect = CGRect(
                        x: spectrogram.size.width * data.start,
                        y: 0,
                        width: spectrogram.size.width * data.end,
                        height: spectrogram.size.height
                    )
                    if let cgImage = spectrogram.cgImage {
                        if let crop = cgImage.cropping(to: cropRect) {
                            let uiImageCrop = UIImage(cgImage: crop, scale: spectrogram.scale, orientation: spectrogram.imageOrientation)
                            uiImageCrop.draw(in: CGRect(origin: .zero, size: .thumbnail))
                        }
                    }
                }
                let thumbnail = NBImage(image: crop)
                try thumbnail.write()
                data.crop = thumbnail
                let result = try await model.identify(sound: sound, start: data.start, end: data.end)
                data.result = result
            } catch is HttpError {
                self.error = error
                self.isPresented = true
            } catch {
                preconditionFailure(error.localizedDescription)
            }
        }
    }
    
    var body: some View {
        SwiftUI.Group {
            if let sound = data.sound {
                SwiftUI.Group {
                    if let spectrogram = model.spectrogram {
                        SpectrogramView(spectrogram: spectrogram, start: $data.start, end: $data.end)
                            .toolbar {
                                ToolbarItem(placement: .confirmationAction) {
                                    Button("Identify") {
                                        identifyAndCrop(sound: sound, spectrogram: spectrogram)
                                    }
                                }
                            }
                    } else {
                        Text("Downloading spectrogram")
                            .task {
                                do {
                                    try await model.downloadSpectrogram(sound: sound)
                                } catch is HttpError {
                                    self.error = error
                                    self.isPresented = true
                                } catch {
                                    preconditionFailure("\(error)")
                                }
                            }
                    }
                }
                .alertHttpError(isPresented: $isPresented, error: error)
            } else {
                BirdRecorderView(sound: $data.sound)
            }
        }
    }
}

struct BirdIdView_Previews: PreviewProvider {
    static var previews: some View {
        BirdIdView(data: .constant(SoundData()))
    }
}
