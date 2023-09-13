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
    
    @objc func saveObservation() {
        flow.saveObservation()
    }
}

struct EditObservationView: HostedView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    
    @ObservedObject var flow: EditFlowViewModel
    @State private var showMap: Bool = false
    @State private var imageData: ImageData = ImageData()
    @State private var showSoundId: Bool = false
    @State private var soundData: SoundData = SoundData()

    @State private var isEditing = false

    init(flow: EditFlowViewModel) {
        self.flow = flow
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
        Task {
            if let mediaId = flow.data.original.mediaId {
              let sound = NBSound(id: mediaId)
              soundData = SoundData(sound: sound)
              showSoundId = true
          }
        }
    }
    
    var body: some View {
        VStack {
            if let thumbnail = flow.data.thumbnail {
                HStack {
                    Image(uiImage: thumbnail.image)
                        .avatar()
                }
            } else  {
                Image("placeholder")
                    .avatar()
            }
            Text(flow.data.original.created.date, formatter: .dateTime)
            ZStack {
                if isEditing {
                    Form {
                        CoordinatesView(coordinates: flow.data.coords)
                            .onTapGesture {
                                navigationController?.pushViewController(PickerViewController(flow: flow), animated: true)
                            }
                        if let name = flow.data.species?.gername {
                            Text(name)
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
                        } else {
                            Text("Unknown species")
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
                        NBEditText(label: "Notes", icon: Image("details"), text: $flow.data.details)
                        Picker("Behavior", selection: $flow.data.behavior) {
                            ForEach([Behavior].forGroup(group: flow.data.species?.group)) {
                                Text($0.rawValue).tag($0 as Behavior?)
                            }
                        }
                        IndividualsView(individuals: $flow.data.individuals)
                    }
                } else {
                    Form {
                        CoordinatesView(coordinates: flow.data.coords)
                        if let name = flow.data.species?.gername {
                            Text(name)
                        } else {
                            Text("Unknown species")
                        }
                        if !flow.data.details.isEmpty {
                            NBText(label: "Notes", icon: Image("details"), text: flow.data.details)
                        }
                        if let behavior = flow.data.behavior?.rawValue {
                            Text(behavior)
                        }
                        Text(String(flow.data.individuals))
                    }
                }
            }
        }
        .onReceive(flow.$editing) { editing in
            if editing {
                withAnimation(.easeInOut(duration: 1.0)) {
                    isEditing = editing
                    viewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: viewController, action: #selector(EditObservationViewController.saveObservation))
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
