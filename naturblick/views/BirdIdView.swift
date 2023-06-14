//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct BirdIdView: View {
    @State var sound: Sound? = nil
    @State var start: CGFloat = 0
    @State var end: CGFloat = 1
    @StateObject private var model = BirdIdViewModel()
    @State private var isPresented: Bool = false
    @State private var error: HttpError? = nil
    
    var body: some View {
        if let sound = self.sound {
            SwiftUI.Group {
                if let spectrogram = model.spectrogram {
                    SpectrogramView(spectrogram: spectrogram, start: $start, end: $end)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Identify") {
                                    Task {
                                        do {
                                            try await model.identify(sound: sound, start: start, end: end)
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
                                preconditionFailure(error.localizedDescription)
                            }
                        }
                }
            }
            .alertHttpError(isPresented: $isPresented, error: error)
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
