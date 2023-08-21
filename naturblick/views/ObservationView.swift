//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct ObservationView: View {
    let observation: Observation
    let controller: ObservationPersistenceController
    @State private var edit = false
    @State var editData: EditData
    @State private var presentConfirmationDialog = false


    init(observation: Observation,
         controller: ObservationPersistenceController
    ) {
        self.observation = observation
        self.controller = controller
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
            if let mediaId = observation.observation.mediaId {
                switch(observation.observation.obsType) {
                case .audio, .unidentifiedaudio:
                    SoundButton(url: NBSound(id: mediaId).url).frame(width: 40)
                case .image, .unidentifiedimage:
                    NavigationLink(destination: FullscreenView(imageId: mediaId)) {
                        FABView("zoom")
                    }
                case .manual:
                    do {}
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    edit = true
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Delete") {
                    do {
                        try controller.delete(occurenceId: observation.id)
                    } catch {
                        fatalError(error.localizedDescription)
                    }
                }
            }
        }
        .sheet(isPresented: $edit) {
            NavigationView {
                EditObservationView(data: $editData)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Dismiss") {
                                if (editData.hasChanged) {
                                    presentConfirmationDialog = true
                                } else {
                                    dismissEditView()
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
                    .confirmationDialog("save_changes_message", isPresented: $presentConfirmationDialog){
                        Button("Continue") {
                            presentConfirmationDialog = false
                            dismissEditView()
                        }
                    } message: {
                        Text("There are changes that have not been saved.")
                    }
            }
        }
        .task {
            await updateThumbnail()
        }
        .navigationTitle("Observation")
    }
    
    private func dismissEditView() {
        editData = EditData(observation: observation, thumbnail: nil)
        edit = false
        Task {
            await updateThumbnail()
        }
    }
}

struct ObservationView_Previews: PreviewProvider {
    static var previews: some View {
        ObservationView(observation: Observation(observation: DBObservation.sampleData, species: nil), controller: ObservationPersistenceController(inMemory: true))
    }
}
