//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import CoreData

struct ObservationListView: View {
    private let client = BackendClient()
    private let persistenceController: ObservationPersistenceController = .shared
    @State private var create = false
    @State private var createOperation = CreateOperation()
    @State private var isPresented: Bool = false
    @State private var error: HttpError? = nil
    @FetchRequest(sortDescriptors: [SortDescriptor(\.created, order: .reverse)])
    private var observations: FetchedResults<ObservationEntity>

    var body: some View {
        List(observations, id: \.occurenceId) { observationEntity in
            let observation = Observation(from: observationEntity)
            ObservationListItemWithImageView(observation: observation)
        }
        .refreshable {
            await sync()
        }
        .navigationTitle("Feldbuch")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(action: {
                    create = true
                }) {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("New Observation")
            }
        }
        .sheet(isPresented: $create) {
            NavigationView {
                CreateObservationView(createOperation: $createOperation)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Dismiss") {
                                create = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Add") {
                                do {
                                    try persistenceController.insert(operation: createOperation)
                                    createOperation = CreateOperation()
                                } catch {
                                    fatalError(error.localizedDescription)
                                }
                                create = false
                            }
                        }
                    }
            }
        }
        .alertHttpError(isPresented: $isPresented, error: error)
    }

    private func sync() async {
        do {
            let response = try await client.sync()
            try await persistenceController.importObservations(from: response.data)
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
        ObservationListView()
    }
}
