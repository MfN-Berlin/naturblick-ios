//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import MapKit

struct EditObservationView: View {
    @Binding var data: EditData
    @State private var showMap: Bool = false
    @State private var showImageId: Bool = false
    @State private var imageData: ImageData = ImageData()
    @State private var showSoundId: Bool = false
    @State private var soundData: SoundData = SoundData()
    @State private var region: MKCoordinateRegion
    
    init(data: Binding<EditData>) {
        self._data = data
        self._region = State(initialValue: data.wrappedValue.region)
    }
    
    func identifyImage() {
        Task {
            let client = BackendClient()
            if let mediaId = data.original.mediaId {
                let image = try await client.downloadCached(mediaId: mediaId)
                imageData = ImageData(image: image)
                showImageId = true
            }
        }
    }
    
    func identifySound() {
        Task {
          if let mediaId = data.original.mediaId {
              let sound = NBSound(id: mediaId)
              soundData = SoundData(sound: sound)
              showSoundId = true
          }
        }
    }
    
    var body: some View {
        Form {
            CoordinatesView(coordinates: data.coords)
                .onTapGesture {
                    showMap = true
                }
            Text("Change species")
                .onTapGesture {
                    switch(data.obsType) {
                    case .image, .unidentifiedimage:
                        identifyImage()
                    case .audio, .unidentifiedaudio:
                        identifySound()
                    case .manual:
                        do {}
                    }
                }
            NBEditText(label: "Notes", icon: Image("details"), text: $data.details)
            IndividualsView(individuals: $data.individuals)
        }
        .sheet(isPresented: $showImageId) {
            NavigationView {
                SwiftUI.Group {
                    if let identified = imageData.identified {
                        SelectSpeciesView(results: identified.result, thumbnail: identified.crop.image) { species in
                            data.species = species
                            data.thumbnailId = identified.crop.id
                            showImageId = false
                        }
                    } else if !data.speciesChanged {
                        PlantIdView(data: $imageData)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Dismiss") {
                            showImageId = false
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showSoundId) {
            NavigationView {
                SwiftUI.Group {
                    if let identified = soundData.identified {
                        SelectSpeciesView(results: identified.result, thumbnail: identified.crop.image) { species in
                            data.species = species
                            data.thumbnailId = identified.crop.id
                            showSoundId = false
                        }
                    } else if !data.speciesChanged {
                        BirdIdView(data: $soundData)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Dismiss") {
                            showSoundId = false
                        }
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showMap) {
            NavigationView {
                Map(coordinateRegion: $region)
                    .picker()
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Dismiss") {
                                region = data.region
                                showMap = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                data.coords = Coordinates(region: region)
                                showMap = false
                            }
                        }
                    }
            }
        }
    }
}

struct EditObsevationView_Previews: PreviewProvider {
    static var previews: some View {
        EditObservationView(data: .constant(EditData(observation: DBObservation.sampleData, species: nil)))
    }
}
