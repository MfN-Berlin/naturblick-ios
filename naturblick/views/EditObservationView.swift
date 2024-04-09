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
            flow.existingSound(mediaId: mediaId)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: .defaultPadding) {
            HStack {
                flow.speciesAvatar
                    .avatar()
                    .padding(.trailing, .defaultPadding)
                VStack(alignment: .leading, spacing: .zero) {
                    Text("species")
                        .caption(color: .onSecondaryLowEmphasis)
                    if let species = flow.data.species {
                        Text(species.speciesName ?? species.sciname)
                            .subtitle1(color: .onSecondaryHighEmphasis)
                    } else {
                        Text("unknown_species")
                            .subtitle1(color: .onSecondaryHighEmphasis)
                    }
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
            Divider()
            HStack {
                Image("location24")
                    .observationProperty()
                VStack(alignment: .leading, spacing: .zero) {
                    Text("location")
                        .caption(color: .onSecondarySignalLow)
                    CoordinatesView(coordinates: flow.data.coords)
                }
                Spacer()
                Button("change") {
                    navigationController?.pushViewController(PickerView(flow: flow).setUpViewController(), animated: true)
                }
                .buttonStyle(ChangeSpeciesButton())
            }
            Divider()
            HStack {
                Image("number24")
                    .observationProperty()
                VStack(alignment: .leading, spacing: .zero) {
                    Text("number")
                        .caption(color: .onSecondarySignalLow)
                    IndividualsView(individuals: $flow.data.individuals)
                }
            }
            Divider()
            HStack {
                Image("location24")
                    .observationProperty()
                VStack(alignment: .leading, spacing: .zero) {
                    Text("behavior")
                        .caption(color: .onSecondarySignalLow)
                    Picker("behavior", selection: $flow.data.behavior) {
                        if flow.data.original.behavior == nil {
                            Text("none").tag(nil as Behavior?)
                        }
                        ForEach([Behavior].forGroup(group: flow.data.species?.group)) {
                            Text($0.rawValue).tag($0 as Behavior?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
            }
            Divider()
            HStack {
                Image("details")
                    .observationProperty()
                VStack(alignment: .leading, spacing: .zero) {
                    Text("notes")
                        .caption(color: .onSecondarySignalLow)
                    TextField("edit_notes", text: $flow.data.details)
                }
            }
            Spacer()
        }
        .padding(.defaultPadding)
    }
}

struct EditObservationView_Previews: PreviewProvider {
    static var previews: some View {
        EditObservationView(flow: EditFlowViewModel(persistenceController: ObservationPersistenceController(inMemory: true), observation: Observation(observation: DBObservation.sampleData, species: Species.sampleData)))
    }
}
