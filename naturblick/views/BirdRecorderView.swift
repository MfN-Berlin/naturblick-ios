//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct BirdRecorderView: NavigatableView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    
    @StateObject private var model = BirdRecorderViewModel()
    @ObservedObject var flow: CreateFlowViewModel
    var body: some View {
        if model.isAuthorized {
            Text("\(model.currentTime)")
                .onTapGesture {
                    flow.soundRecorded(sound: model.stop()!)
                }
                .onAppear {
                    model.record()
                }
                .onDisappear {
                    model.cancel()
                }
        } else if model.isDenied {
            Text("Without permission to record it is not possible to record birds")
        } else {
            Text("Naturblick requires recording")
        }
    }
}

struct BirdRecorderView_Previews: PreviewProvider {
    static var previews: some View {
        BirdRecorderView(flow: CreateFlowViewModel(persistenceController: ObservationPersistenceController(inMemory: true)))
    }
}
