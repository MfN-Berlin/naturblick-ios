//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import MapKit
import os

class ObservationViewController: HostingController<ObservationView> {
    let model: ObservationViewModel
    let occurenceId: UUID
    let backend: Backend
    init(occurenceId: UUID, backend: Backend) {
        self.occurenceId = occurenceId
        self.backend = backend
        self.model = ObservationViewModel(viewObservation: occurenceId, persistenceController: backend.persistence)
        super.init(rootView: ObservationView(occurenceId: occurenceId, backend: backend, model: model))
    }
    
    @objc func deleteObservation(_ sender: Any?) {
        let alert = UIAlertController(title: String(localized: "delete_question"), message: String(localized: "delete_question_message"), preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: String(localized: "delete"), style: .destructive, handler: { _ in
            do {
                try self.backend.persistence.delete(occurenceId: self.occurenceId)
                self.navigationController?.popViewController(animated: true)
            } catch {
                fatalError(error.localizedDescription)
            }
        }))
        alert.addAction(UIAlertAction(title: String(localized: "cancel"), style: .cancel, handler: { _ in
        }))
        alert.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
        self.present(alert, animated: true, completion: nil)
    }
}

struct ObservationView: HostedView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    let backend: Backend
    var hideNavigationBarShadow: Bool = true
    @State var speciesAvatar: Image = Image("placeholder")
    @State var sound: NBSound? = nil
    @ObservedObject var persistenceController: ObservationPersistenceController
    @ObservedObject var model: ObservationViewModel
    let occurenceId: UUID
    
    init(occurenceId: UUID, backend: Backend, model: ObservationViewModel) {
        self.occurenceId = occurenceId
        self.backend = backend
        self.persistenceController = backend.persistence
        self.model = model
    }
    
    func configureNavigationItem(item: UINavigationItem) {
        let deleteButton = UIBarButtonItem(image: UIImage(named: "trash_24"), style: .plain, target: viewController, action: #selector(ObservationViewController.deleteObservation))
        deleteButton.accessibilityLabel = String(localized: "acc_delete")
        deleteButton.tintColor = UIColor(Color.onPrimaryHighEmphasis)
        let editButton = UIBarButtonItem(title: String(localized: "edit"), primaryAction: UIAction {_ in
            if let observation = persistenceController.observations.first(where: {$0.observation.occurenceId == occurenceId}) {
                let view = EditObservationViewController(observation: observation, backend: backend)
                let navigation = PopAwareNavigationController(rootViewController: view)
                viewController?.present(navigation, animated: true)
            }
        })
        item.rightBarButtonItems = [editButton, deleteButton]
    }
    
    var view: some View {
        VStack(alignment: .leading, spacing: .defaultPadding) {
            HStack {
                speciesAvatar
                    .avatar()
                    .padding(.trailing, .defaultPadding)
                    .accessibilityHidden(true)
                
                VStack(alignment: .leading, spacing: .zero) {
                    Text("species")
                        .caption(color: .onSecondarySignalLow)
                    if let species = model.observation?.species {
                        Text(species.speciesName ?? species.sciname)
                            .subtitle1(color: .onSecondaryHighEmphasis)
                    } else {
                        Text("unknown_species")
                            .subtitle1(color: .onSecondaryHighEmphasis)
                    }
                }
                Spacer()
                if model.observation?.species != nil {
                    ChevronView()
                        .accessibilityElement()
                        .accessibilityRepresentation {
                            Button("acc_further_speciesinfo") {
                                speciesInfoNavigate()
                            }
                        }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                speciesInfoNavigate()
            }
            Divider()
            HStack {
                Image(decorative: "location24")
                    .observationProperty()
                VStack(alignment: .leading, spacing: .zero) {
                    Text("location")
                        .caption(color: .onSecondarySignalLow)
                    CoordinatesView(coordinates: model.observation?.observation.coords)
                }
                Spacer()
                if model.observation?.observation.coords != nil {
                    ChevronView()
                        .accessibilityElement()
                        .accessibilityRepresentation {
                            Button("acc_map") {
                                mapNavigate()
                            }
                        }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                mapNavigate()
            }
            Divider()
            ViewProperty(icon: "number24", label: String(localized: "number"), content: String(model.observation?.observation.individuals ?? 1))
            ViewProperty(icon: "location24", label: String(localized: "behavior"), content: model.observation?.observation.behavior?.rawValue)
            ViewProperty(icon: "details", label: String(localized: "notes"), content: model.observation?.observation.details)
        }
        .task(id: model.observation?.species?.id) {
            if let speciesUrl = model.observation?.species?.listItem.url, let image = try? await backend.downloadCached(speciesUrl: speciesUrl) {
                speciesAvatar = Image(uiImage: image)
            }
            if let observation = model.observation?.observation, observation.obsType == .audio || observation.obsType == .unidentifiedaudio {
                let soundFromTo = SoundFromTo.createSoundFromTo(observation: observation)
                if let mediaId = observation.mediaId {
                    sound = try? await NBSound(id: mediaId, backend: backend, obsIdent: observation.obsIdent, soundFromTo: soundFromTo)
                } else if let obsIdent = observation.obsIdent {
                    sound = NBSound.loadOld(occurenceId: observation.occurenceId, obsIdent: obsIdent, persistenceController: persistenceController, soundFromTo: soundFromTo)
                } else {
                    Logger.compat.warning("Audio Observation \(observation.occurenceId, privacy: .public) has neither mediaId nor obsIdent")
                }
            }
        }
    }
    
    private func speciesInfoNavigate() {
        if let species = model.observation?.species?.listItem {
            navigationController?.pushViewController(SpeciesInfoView(backend: backend, countView: false,  selectionFlow: false, species: species, flow: VoidSelectionFlow()).setUpViewController(), animated: true)
        }
    }
    
    private func mapNavigate() {
        if model.observation?.observation.coords != nil {
            navigationController?.pushViewController(ObservationListViewController(backend: backend, showObservation: model.observation), animated: true)
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                VStack(alignment: .center, spacing: .zero) {
                    if let observation = model.observation {
                        ObservationInfoView(backend: backend, width: geo.size.width, fallbackThumbnail: speciesAvatar, observation: observation, sound: sound) { view in
                            navigationController?.present(view, animated: true)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
         
                view
                .padding(.defaultPadding)
                .padding(.bottom, geo.safeAreaInsets.bottom)
                .background(
                    RoundedRectangle(cornerRadius: .largeCornerRadius)
                        .fill(Color.secondaryColor)
                        .nbShadow()
                )
                .background(Color(uiColor: .onPrimaryButtonSecondary))
                .frame(maxHeight: .infinity, alignment: .bottom)
            }
            .ignoresSafeArea(edges: .bottom)
            .frame(maxHeight: .infinity)
            .background(Color(uiColor: .onPrimaryButtonSecondary))
        }
        
    }
}

struct EditObsevationView_Previews: PreviewProvider {
    static var previews: some View {
        let backend = Backend(persistence: ObservationPersistenceController(inMemory: true))
        ObservationView(occurenceId: DBObservation.sampleData.occurenceId, backend: backend, model: ObservationViewModel(viewObservation: DBObservation.sampleData.occurenceId, persistenceController: backend.persistence))
    }
}
