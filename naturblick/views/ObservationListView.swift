//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import MapKit

struct ObservationListView: View {
    let initialCreateAction: CreateObservationAction?
    private let client = BackendClient()
    @StateObject var persistenceController = ObservationPersistenceController()
    @State private var isPresented: Bool = false
    @State private var error: HttpError? = nil
    @State private var region: MKCoordinateRegion = .defaultRegion
    @State private var showList: Bool = true
    @State var create: Bool = false
    @State var evaluateAction: Bool = true
    @State var createAction: CreateObservationAction = .createManualObservation

    var body: some View {
        SwiftUI.Group {
            if(showList) {
                List(persistenceController.observations, id: \.occurenceId) { observation in
                    NavigationLink(destination: ObservationView(observation: observation, controller: persistenceController)) {
                        ObservationListItemWithImageView(observation: observation)
                    }
                }
                .refreshable {
                    await sync()
                }
            } else {
                Map(
                    coordinateRegion: $region,
                    annotationItems: persistenceController.observations.filter { $0.coords != nil
                    }
                ) { observation in
                    MapAnnotation(coordinate: observation.coords!.location) {
                        NavigationLink(
                            destination: ObservationView(observation: observation, controller: persistenceController)
                        ) {
                            Image(systemName: "mappin")
                        }
                        .foregroundColor(.red)
                    }
                }
            }
        }
        .navigationTitle("Feldbuch")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(action: {
                    createAction = .createManualObservation
                    create = true
                }) {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("New Observation")
            }
            ToolbarItem(placement: .navigation	) {
                if(showList) {
                    Button(action: {
                        showList = false
                    }) {
                        Image(systemName: "map")
                    }
                    .accessibilityLabel("Show observations on map")
                } else {
                    Button(action: {
                        showList = true
                    }) {
                        Image(systemName: "list.dash")
                    }
                    .accessibilityLabel("Show in list")
                }
            }
        }
        .sheet(isPresented: $create) {
            NavigationView {
                CreateFlowView(action: createAction, persistenceController: persistenceController)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Dismiss") {
                                create = false
                            }
                        }
                    }
            }
        }
        .alertHttpError(isPresented: $isPresented, error: error)
        .onAppear {
            if evaluateAction {
                if let initial = initialCreateAction {
                    createAction = initial
                }
                create = initialCreateAction != nil
                evaluateAction = false
            }
        }
    }

    private func sync() async {
        do {
            let response = try await client.sync(controller: persistenceController)
            try persistenceController.importObservations(from: response.data)
        } catch is HttpError {
            self.error = error
            self.isPresented = true
        } catch {
            preconditionFailure("\(error)")
        }
    }
}

struct ObservationListView_Previews: PreviewProvider {
    static var previews: some View {
        ObservationListView(initialCreateAction: nil)
    }
}
