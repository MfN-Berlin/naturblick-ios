//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import MapKit
import BottomSheet

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
    @State private var sheetPosition: BottomSheetPosition = .dynamic
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
    
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .center) {
                ObservationInfoView(width: geo.size.width, data: flow.data) { view in
                    navigationController?.pushViewController(view, animated: true)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .bottomSheet(bottomSheetPosition: $sheetPosition, switchablePositions: [.dynamicBottom, .dynamic]) {
            if isEditing {
                VStack(alignment: .leading) {
                    Thumbnail(speciesUrl: flow.data.species?.url, thumbnailId: nil) { thumbnail in
                        HStack {
                            thumbnail
                                .avatar()
                                .padding(.trailing, .defaultPadding)
                            Text(flow.data.species?.sciname ?? "Unknown species")
                        }
                        .onTapGesture {
                            switch(flow.data.obsType) {
                            case .image, .unidentifiedimage:
                                identifyImage()
                            case .audio, .unidentifiedaudio:
                                identifySound()
                            case .manual:
                                do {}
                            }
                        }
                    }
                    Divider()
                    HStack {
                        Image("placeholder")
                            .observationProperty()
                        CoordinatesView(coordinates: flow.data.coords)
                            .onTapGesture {
                                navigationController?.pushViewController(PickerView(flow: flow).setUpViewController(), animated: true)
                            }
                    }
                    Divider()
                    HStack {
                        Image("details")
                            .observationProperty()
                        TextField("Notes", text: $flow.data.details)
                    }
                    Divider()
                    HStack {
                        Image("placeholder")
                            .observationProperty()
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
                    Divider()
                    HStack {
                        Image("placeholder")
                            .observationProperty()
                        IndividualsView(individuals: $flow.data.individuals)
                    }
                }
                .padding(.defaultPadding)
                .padding(.bottom, .defaultPadding * 2)
            } else {
                VStack(alignment: .leading) {
                    Thumbnail(speciesUrl: flow.data.species?.url, thumbnailId: nil) { thumbnail in
                        HStack {
                            thumbnail
                                .avatar()
                                .padding(.trailing, .defaultPadding)
                            Text(flow.data.species?.sciname ?? "Unknown species")
                        }
                        .onTapGesture {
                            if let species = flow.data.species {
                                navigationController?.pushViewController(PortraitViewController(species: species, inSelectionFlow: true), animated: true)
                            }
                        }
                    }
                    Divider()
                    HStack {
                        Image("placeholder")
                            .observationProperty()
                        CoordinatesView(coordinates: flow.data.coords)
                    }
                    Divider()
                    HStack {
                        Image("details")
                            .observationProperty()
                        if flow.data.details.isEmpty {
                            Text(" ")
                        } else {
                            Text(flow.data.details)
                        }
                    }
                    Divider()
                    HStack {
                        Image("placeholder")
                            .observationProperty()
                        if let behavior = flow.data.behavior?.rawValue {
                            Text(behavior)
                        } else {
                            Text(" ")
                        }
                    }
                    Divider()
                    HStack {
                        Image("placeholder")
                            .observationProperty()
                        Text(String(flow.data.individuals))
                    }
                }
                .padding(.defaultPadding)
                .padding(.bottom, .defaultPadding * 2)
            }
        }
        .customBackground(
            RoundedRectangle(cornerRadius: .largeCornerRadius)
                .fill(Color.secondaryColor)
                .nbShadow()
        )
        .background(Color(uiColor: .onPrimaryButtonSecondary))
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
