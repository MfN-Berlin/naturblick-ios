//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import CoreData

struct ObservationListView: View {
    private let client = BackendClient()
    private let persistenceController: ObservationPersistenceController = .shared
    @State private var isPresented: Bool = false
    @State private var error: HttpError? = nil
    @FetchRequest(sortDescriptors: [SortDescriptor(\.created, order: .reverse)])
    private var observations: FetchedResults<ObservationEntity>

    var body: some View {
        BaseView {
            List(observations, id: \.occurenceId) { observationEntity in
                let observation = Observation(from: observationEntity)
                ObservationListItemWithImageView(observation: observation)
            }
            .listStyle(.plain)
            .refreshable {
                await sync()
            }
            .navigationTitle("Feldbuch")
            .alertHttpError(isPresented: $isPresented, error: error)
        }
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
