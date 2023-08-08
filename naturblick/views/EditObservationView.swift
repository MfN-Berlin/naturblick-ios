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
    @State private var userTrackingMode: MapUserTrackingMode = .none
    @StateObject private var locationManager = LocationManager()

    init(data: Binding<EditData>) {
        self._data = data
        self._region = State(initialValue: data.wrappedValue.region)
    }
    
    func identifyImage() {
        Task {
            if let mediaId = data.original.mediaId {
                let origImage = try await NBImage(id: mediaId)
                imageData = ImageData(image: origImage)
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
            Picker("Behavior", selection: $data.behavior) {
                ForEach([Behavior].forGroup(group: data.species?.group)) {
                    Text($0.rawValue).tag($0 as Behavior?)
                }
            }
            IndividualsView(individuals: $data.individuals)
        }
        .sheet(isPresented: $showImageId) {
            NavigationView {
                SwiftUI.Group {
                    if let identified = imageData.identified {
                        SelectSpeciesView(results: identified.result, thumbnail: identified.crop.image) { species in
                            data.species = species
                            data.thumbnail = identified.crop
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
                            data.thumbnail = identified.crop
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
                Map(coordinateRegion: $region, showsUserLocation: true, userTrackingMode: $userTrackingMode)
                    .picker()
                    .trackingToggle($userTrackingMode: $userTrackingMode, authorizationStatus: locationManager.permissionStatus)
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
                    .onAppear {
                        if locationManager.askForPermission() {
                            locationManager.requestLocation()
                        }
                    }
            }
        }
    }
}

struct EditObsevationView_Previews: PreviewProvider {
    static var previews: some View {
        EditObservationView(data: .constant(EditData(observation: Observation(observation: DBObservation.sampleData, species: nil), thumbnail: nil)))
    }
}
