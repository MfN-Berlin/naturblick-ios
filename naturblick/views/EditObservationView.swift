//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

class EditObservationViewController: HostingController<EditObservationView> {
    let flow: EditFlowViewModel
    
    init(observation: Observation, persistenceController: ObservationPersistenceController) {
        self.flow = EditFlowViewModel(persistenceController: persistenceController, observation: observation)
        super.init(rootView: EditObservationView(flow: flow))
        flow.setViewController(controller: self)
    }
    
    
    @objc func save() {
        flow.saveObservation()
        dismiss(animated: true)
    }
    
    @objc func cancel() {
        dismiss(animated: true)
    }
}

struct EditObservationView: HostedView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    @ObservedObject var flow: EditFlowViewModel
    
    func configureNavigationItem(item: UINavigationItem) {
        item.leftBarButtonItem = UIBarButtonItem(title: String(localized: "cancel"), style: .plain, target: viewController, action: #selector(EditObservationViewController.cancel))
        item.rightBarButtonItem = UIBarButtonItem(title: String(localized: "save"), style: .done, target: viewController, action: #selector(EditObservationViewController.save))
    }
    
    func identifyImage() {
        Task {
            if let mediaId = flow.data.original.mediaId {
                let origImage = try await NBImage(id: mediaId, localIdentifier: flow.data.original.localMediaId)
                flow.cropPhoto(image: origImage)
            }
        }
    }
    
    func identifySound() {
        if let mediaId = flow.data.original.mediaId {
            flow.soundRecorded(sound: NBSound(id: mediaId))
        }
    }
    
    var body: some View {
        Form {
            HStack {
                flow.speciesAvatar
                    .avatar()
                VStack(alignment: .leading) {
                    Text("species")
                        .caption(color: .onSecondaryLowEmphasis)
                    Text(flow.data.species?.sciname ?? "unknown_species")
                        .subtitle1(color: .onSecondaryHighEmphasis)
                }
                Spacer()
                Button("change") {
                    switch(flow.data.obsType) {
                    case .image, .unidentifiedimage:
                        identifyImage()
                    case .audio, .unidentifiedaudio:
                        identifySound()
                    case .manual:
                        flow.searchSpecies()
                    }
                }
                .buttonStyle(ChangeSpeciesButton())
            }
            CoordinatesView(coordinates: flow.data.coords)
                .onTapGesture {
                    navigationController?.pushViewController(PickerView(flow: flow).setUpViewController(), animated: true)
                }
            IndividualsView(individuals: $flow.data.individuals)
            
            Picker("behavior", selection: $flow.data.behavior) {
                if flow.data.original.behavior == nil {
                    Text("none").tag(nil as Behavior?)
                }
                ForEach([Behavior].forGroup(group: flow.data.species?.group)) {
                    Text($0.rawValue).tag($0 as Behavior?)
                }
            }
            .pickerStyle(MenuPickerStyle())
            TextField("notes", text: $flow.data.details)
        }
    }
}

struct EditObservationView_Previews: PreviewProvider {
    static var previews: some View {
        EditObservationView(flow: EditFlowViewModel(persistenceController: ObservationPersistenceController(inMemory: true), observation: Observation(observation: DBObservation.sampleData, species: Species.sampleData)))
    }
}
