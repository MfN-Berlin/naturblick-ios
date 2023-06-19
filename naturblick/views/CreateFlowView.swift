//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct CreateFlowView: View {
    let action: CreateObservationAction
    @Environment(\.dismiss) var dismiss
    @ObservedObject var persistenceController: ObservationPersistenceController
    @State var data: CreateData = CreateData()
    
    var createObservationView: some View {
        CreateObservationView(data: $data)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        do {
                            try persistenceController.insert(data: data)
                            dismiss()
                        } catch {
                            fatalError("\(error)")
                        }
                    }
                }
            }
    }
    
    var body: some View {
        if action == .createSoundObservation, data.identified == nil {
            BirdIdView(data: $data.sound)
        } else if action == .createImageObservation, data.identified == nil {
            PlantIdView(data: $data.image)
        } else if let identified = data.identified, data.species == nil {
            SelectSpeciesView(results: identified.result, data: $data)
        } else {
            createObservationView
        }
    }
}

struct CreateFlowView_Previews: PreviewProvider {
    static var previews: some View {
        CreateFlowView(action: .createManualObservation, persistenceController: ObservationPersistenceController(inMemory: true))
    }
}
