//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import CoreData

struct ObservationListView: View {
    private let client = BackendClient()
    @State var obsAction: ObservationAction
    @StateObject var persistenceController = ObservationPersistenceController()
    @State private var createManual = false
    @State private var createData = CreateData()
    @State private var createImage = false
    @State private var isPresented: Bool = false
    @State private var error: HttpError? = nil

    var body: some View {
        List(persistenceController.observations, id: \.occurenceId) { observation in
            NavigationLink(destination: ObservationView(observation: observation, controller: persistenceController)) {
                ObservationListItemWithImageView(observation: observation)
            }
        }
        .refreshable {
            await sync()
        }
        .navigationTitle("Feldbuch")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(action: {
                    createManual = true
                }) {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("New Observation")
            }
        }
        .sheet(isPresented: $createManual) {
            NavigationView {
                CreateObservationView(obsAction: .createManualObservation, data: $createData)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Dismiss") {
                                createData = CreateData()
                                createManual = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Add") {
                                do {
                                    try persistenceController.insert(data: createData)
                                    createData = CreateData()
                                } catch {
                                    fatalError(error.localizedDescription)
                                }
                                createManual = false
                            }
                        }
                    }
            }
        }
        .sheet(isPresented: $createImage) {
            NavigationView {
                CreateObservationView(obsAction: .createImageObservation, data: $createData)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Dismiss") {
                                createData = CreateData()
                                createImage = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Add") {
                                do {
                                    try persistenceController.insert(data: createData)
                                    createData = CreateData()
                                } catch {
                                    fatalError(error.localizedDescription)
                                }
                                createImage = false
                            }
                        }
                    }
            }
        }
        .onAppear {
            if (obsAction == .createImageObservation) {
                createImage = true
            }
        }
        .alertHttpError(isPresented: $isPresented, error: error)
    }

    private func sync() async {
        do {
            let response = try await client.sync(controller: persistenceController)
            try persistenceController.importObservations(from: response.data)
        } catch is HttpError {
            self.error = error
            self.isPresented = true
        } catch {
            preconditionFailure(error.localizedDescription)
        }
    }
}

struct ObservationListView_Previews: PreviewProvider {
    static var previews: some View {
        ObservationListView(obsAction: .createManualObservation)
    }
}
