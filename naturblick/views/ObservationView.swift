//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct ObservationView: View {
    let observation: Observation
    @EnvironmentObject var controller: ObservationPersistenceController
    @State private var edit = false
    @State var editData: EditData

    init(observation: Observation
    ) {
        self.observation = observation
        self._editData = State(initialValue: EditData(observation: observation, thumbnail: nil))
    }

    private func updateThumbnail() async {
        if let thumbnailId = observation.observation.thumbnailId {
            if editData.thumbnail == nil {
                let thumbnail = try? await NBImage(id: thumbnailId)
                if let thumbnail = thumbnail {
                    editData.thumbnail = thumbnail
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            if let thumbnail = editData.thumbnail {
                HStack {
                    Image(uiImage: thumbnail.image)
                    .avatar()
                    if (observation.observation.obsType == .audio) {
                        if let mediaId = observation.observation.mediaId {
                            SoundButton(url: NBSound(id: mediaId).url).frame(width: 100)
                        }
                    }
                }
            } else if observation.observation.thumbnailId != nil {
                Image("placeholder")
                    .avatar()
            } else if let url = observation.species?.maleUrl {
                AsyncImage(url: URL(string: Configuration.strapiUrl + url)) { image in
                    image
                        .avatar()
                } placeholder: {
                    Image("placeholder")
                        .avatar()
                }
            }
            Text(observation.observation.created.date, formatter: .dateTime)
            if let details = observation.observation.details {
                Text(details)
            }
        }
        .toolbar {
            Button("Edit") {
                edit = true
            }
        }
        .sheet(isPresented: $edit) {
            NavigationView {
                EditObservationView(data: $editData)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Dismiss") {
                                editData = EditData(observation: observation, thumbnail: nil)
                                edit = false
                                Task {
                                    await updateThumbnail()
                                }
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                do {
                                    try controller.insert(data: editData)
                                } catch {
                                    fatalError(error.localizedDescription)
                                }
                                edit = false
                            }
                        }
                    }
            }
        }
        .task {
            await updateThumbnail()
        }
        .navigationTitle("Observation")
    }
}

struct ObservationView_Previews: PreviewProvider {
    static var previews: some View {
        ObservationView(observation: Observation(observation: DBObservation.sampleData, species: nil)).environmentObject(ObservationPersistenceController(inMemory: true))
    }
}
