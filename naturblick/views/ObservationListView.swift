//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import CoreData

struct ObservationListView: View {
    private let client = BackendClient()
    @State var obsAction: ObservationAction
    @StateObject var persistenceController = ObservationPersistenceController()
    @State private var create = false
    @State private var createData = CreateData()
    @State private var isPresented: Bool = false
    @State private var error: HttpError? = nil
    
    private func resetCreate() {
        createData = CreateData()
        self.create = false
    }

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
                    createData = CreateData()
                    obsAction = .createManualObservation
                    create = true
                }) {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("New Observation")
            }
        }
        .sheet(isPresented: $create) {
            NavigationView {
                CreateObservationView(obsAction: obsAction, data: $createData)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Dismiss") {
                                resetCreate()
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Add") {
                                do {
                                    try persistenceController.insert(data: createData)
                                    resetCreate()
                                } catch {
                                    fatalError(error.localizedDescription)
                                }
                            }
                        }
                    }
            }
        }
        .onAppear {
            if (obsAction == .createImageObservation) {
                create = true
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
