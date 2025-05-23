//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

class EditObservationViewController: HostingController<EditObservationView>, UIAdaptivePresentationControllerDelegate {
    let flow: EditFlowViewModel
    
    init(observation: Observation, backend: Backend) {
        self.flow = EditFlowViewModel(backend: backend, observation: observation)
        super.init(rootView: EditObservationView(flow: flow))
        flow.setViewController(controller: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.presentationController?.delegate = self
    }
    
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return !flow.data.hasChanged
    }
    
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        cancelOrDiscardAlert()
    }

    func cancelOrDiscardAlert() {
        let alert = UIAlertController(title: String(localized: "save_changes"), message: String(localized: "save_changes_message"), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: String(localized: "exit_without_saving"), style: .destructive, handler: { _ in
            self.dismiss(animated: true)
        }))
        alert.addAction(UIAlertAction(title: String(localized: "save"), style: .default, handler: { _ in
            self.save()
        }))
        alert.addAction(UIAlertAction(title: String(localized: "cancel"), style: .cancel, handler: { _ in
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func save() {
        flow.saveObservation()
        dismiss(animated: true)
    }
    
    @objc func cancel() {
        if flow.data.hasChanged {
            cancelOrDiscardAlert()
        } else {
            dismiss(animated: true)
        }
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
                let origImage = try await NBImage(id: mediaId, backend: flow.backend, localIdentifier: flow.data.original.localMediaId)
                flow.cropPhoto(image: origImage)
            }
        }
    }
    
    func identifySound() {
        if let mediaId = flow.data.original.mediaId {
            flow.existingSound(mediaId: mediaId, prevSoundFromTo: SoundFromTo.createSoundFromTo(observation: flow.data.original) )
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: .defaultPadding) {
            HStack {
                flow.speciesAvatar
                    .avatar()
                    .padding(.trailing, .defaultPadding)
                    .accessibilityHidden(true)
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
                Image(decorative: "location24")
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
                Image(decorative: "number24")
                    .observationProperty()
                VStack(alignment: .leading, spacing: .zero) {
                    Text("number")
                        .caption(color: .onSecondarySignalLow)
                    IndividualsView(individuals: $flow.data.individuals)
                }
            }
            Divider()
            HStack {
                Image(decorative: "location24")
                    .observationProperty()
                VStack(alignment: .leading, spacing: .zero) {
                    Text("behavior")
                        .caption(color: .onSecondarySignalLow)
                    Picker("behavior", selection: $flow.data.behavior) {
                        ForEach([Behavior].forGroup(group: flow.data.species?.group)) {
                            if case .notSet = $0 {
                                Text("none").tag($0)
                            } else {
                                Text($0.rawValue).tag($0)
                            }
                        }
                    }
                    .accentColor(Color.onSecondaryHighEmphasis)
                    .pickerStyle(MenuPickerStyle())
                }
            }
            Divider()
            HStack {
                Image(decorative: "details")
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
        EditObservationView(flow: EditFlowViewModel(backend: Backend(persistence:  ObservationPersistenceController(inMemory: true)), observation: Observation(observation: DBObservation.sampleData, species: Species.sampleData)))
    }
}
