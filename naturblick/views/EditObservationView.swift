//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import MapKit

class EditObservationViewController: HostingController<EditObservationView> {
    let flow: EditFlowViewModel
    
    init(observation: Observation, persistenceController: ObservationPersistenceController) {
        self.flow = EditFlowViewModel(persistenceController: persistenceController, observation: observation)
        super.init(rootView: EditObservationView(flow: flow))
        flow.setViewController(controller: self)
    }

    @objc func setEdit() {
        flow.editing = true
    }

}

struct EditObservationView: HostedView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    var hideNavigationBarShadow: Bool = true
    @ObservedObject var flow: EditFlowViewModel
    @State private var isEditing = false
    init(flow: EditFlowViewModel) {
        self.flow = flow
    }
    
    func pop() -> Bool {
        if flow.data.hasChanged {
            let discard = UIAlertAction(title: "Discard changes", style: .destructive) { (action) in
                self.navigationController?.forcePopViewController(animated: true)
            }
            let save = UIAlertAction(title: "Save", style: .default) { (action) in
                flow.saveObservation()
            }
            let cancel = UIAlertAction(title: "Continue editing", style: .cancel) { (action) in}
            let alert = UIAlertController(title: "Unsaved changes", message: "There are changes that have not been saved.", preferredStyle: .actionSheet)
            alert.addAction(discard)
            alert.addAction(save)
            alert.addAction(cancel)
            viewController?.present(alert, animated: true)
            return false
        } else {
            return true
        }
    }
    
    func configureNavigationItem(item: UINavigationItem) {
        item.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .done, target: viewController, action: #selector(EditObservationViewController.setEdit))
    }
    
    func identifyImage() {
        Task {
            if let mediaId = flow.data.original.mediaId {
                let origImage = try await NBImage(id: mediaId)
                flow.cropPhoto(image: origImage)
            }
        }
    }
    
    func identifySound() {
        if let mediaId = flow.data.original.mediaId {
            flow.soundRecorded(sound: NBSound(id: mediaId))
        }
    }
    
    var edit: some View {
        VStack(alignment: .leading, spacing: .defaultPadding) {
            HStack {
                flow.speciesAvatar
                    .avatar()
                VStack(alignment: .leading) {
                    Text("Species")
                        .caption(color: .onSecondaryLowEmphasis)
                    Text(flow.data.species?.sciname ?? "Unknown species")
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
            Divider()
            OnSecondaryFieldView(icon: "location24") {
                CoordinatesView(coordinates: flow.data.coords)
                    .onTapGesture {
                        navigationController?.pushViewController(PickerView(flow: flow).setUpViewController(), animated: true)
                    }
            }
            OnSecondaryFieldView(icon: "number24") {
                IndividualsView(individuals: $flow.data.individuals)
            }
            OnSecondaryFieldView(icon: "location24") {
                Picker("Behavior", selection: $flow.data.behavior) {
                    if flow.data.original.behavior == nil {
                        Text("None").tag(nil as Behavior?)
                    }
                    ForEach([Behavior].forGroup(group: flow.data.species?.group)) {
                        Text($0.rawValue).tag($0 as Behavior?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .tint(.onSecondaryHighEmphasis)
                .accentColor(.onSecondaryHighEmphasis)
            }
            OnSecondaryFieldView(icon: "details") {
                TextField("Notes", text: $flow.data.details)
            }
        }
    }
    
    var view: some View {
        VStack(alignment: .leading, spacing: .defaultPadding) {
            HStack {
                flow.speciesAvatar
                    .avatar()
                    .padding(.trailing, .defaultPadding)
                
                VStack(alignment: .leading) {
                    Text("Species")
                        .caption(color: .onSecondarySignalLow)
                    Text(flow.data.species?.sciname ?? "Unknown species")
                        .subtitle1(color: .onSecondaryMediumEmphasis)
                }
                Spacer()
                ChevronView(color: .onSecondarySignalLow)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if let species = flow.data.species {
                    navigationController?.pushViewController(PortraitViewController(species: species, inSelectionFlow: true), animated: true)
                }
            }
            Divider()
            HStack {
                Image("location24")
                    .observationProperty()
                VStack(alignment: .leading, spacing: .zero) {
                    Text("Location")
                        .caption(color: .onSecondarySignalLow)
                    CoordinatesView(coordinates: flow.data.coords)
                }
                Spacer()
                ChevronView(color: .onSecondarySignalLow)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                // TODO
                print("Show on map")
            }
            Divider()
            ViewProperty(icon: "number24", label: "Number", content: String(flow.data.individuals))
            ViewProperty(icon: "location24", label: "Observation", content: flow.data.behavior?.rawValue)
            ViewProperty(icon: "details", label: "Details", content: flow.data.details)
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                VStack(alignment: .center) {
                    ObservationInfoView(width: geo.size.width, fallbackThumbnail: flow.speciesAvatar, data: flow.data) { view in
                        navigationController?.pushViewController(view, animated: true)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                SwiftUI.Group {
                    if isEditing {
                        edit
                    } else {
                        view
                    }
                }
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
        .onReceive(flow.$editing) { editing in
            if editing {
                withAnimation {
                    isEditing = editing
                    viewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(primaryAction: UIAction(title: "Save") {_ in
                        flow.saveObservation()
                    })
                }
            }
        }
    }
}

struct EditObsevationView_Previews: PreviewProvider {
    static var previews: some View {
        EditObservationView(flow: EditFlowViewModel(persistenceController: ObservationPersistenceController(inMemory: true), observation: Observation(observation: DBObservation.sampleData, species: nil)))
    }
}
