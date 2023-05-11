//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct ObservationView: View {
    let observation: Observation
    let controller: ObservationPersistenceController
    @StateObject var model = ObservationViewModel()
    @State private var edit = false
    @State var editData: EditData

    init(observation: Observation,
         controller: ObservationPersistenceController
    ) {
        self.observation = observation
        self.controller = controller
        self._editData = State(initialValue: EditData(observation: observation))
    }

    var body: some View {
        VStack {
            AsyncThumbnail(speciesUrl: model.species?.maleUrl, thumbnailId: observation.thumbnailId) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(width: .avatarSize, height: .avatarSize)
            } placeholder: {
                Image("placeholder")
            }
            Text(observation.created.date, formatter: .dateTime)
            if let details = observation.details {
                Text(details)
            }
        }
        .navigationTitle("Observation")
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
                                editData = EditData(observation: observation)
                                edit = false
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
            await model.load(observation: observation)
        }

    }
}

struct ObservationView_Previews: PreviewProvider {
    static var previews: some View {
        ObservationView(observation: Observation.sampleData, controller: ObservationPersistenceController(inMemory: true))
    }
}
