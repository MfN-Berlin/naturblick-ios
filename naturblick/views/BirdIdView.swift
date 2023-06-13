//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct BirdIdView: View {
    @Binding var data: CreateData.SoundData
    @StateObject private var model = BirdIdViewModel()
    @State private var isPresented: Bool = false
    @State private var error: HttpError? = nil
    
    var body: some View {
        SwiftUI.Group {
            if let sound = data.sound {
                SwiftUI.Group {
                    if let spectrogram = model.spectrogram {
                        SpectrogramView(spectrogram: spectrogram, start: $data.start, end: $data.end)
                            .toolbar {
                                ToolbarItem(placement: .confirmationAction) {
                                    Button("Identify") {
                                        Task {
                                            do {
                                                let result = try await model.identify(sound: sound, start: data.start, end: data.end)
                                                data.result = CreateData.SoundData.Result(species: result, selected: nil, thumbnailId: UUID())
                                            } catch is HttpError {
                                                self.error = error
                                                self.isPresented = true
                                            } catch {
                                                preconditionFailure(error.localizedDescription)
                                            }
                                        }
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
        BirdIdView(data: .constant(CreateData.SoundData()))
    }
}
