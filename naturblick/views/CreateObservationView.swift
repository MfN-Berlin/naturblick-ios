//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

enum ObservationAction {
    case createImageObservation
    case createManualObservation
}

enum ImageIdState {
    case takePhoto
    case crop
    case chooseResult
}

struct CreateObservationView: View {
    
    @StateObject private var cameraManager = CameraManager()
    @StateObject private var photoLibraryManager = PhotoLibraryManager()
    @State private var isPermissionInfoDisplay = false
    
    let obsAction: ObservationAction
    @Binding var data: CreateData
    @StateObject private var locationManager = LocationManager.shared
    @State private var isShowAskForPermission = LocationManager.shared.askForPermission()
    @State private var showImageId = false
    @State private var imageIdState: ImageIdState = .takePhoto
    
    fileprivate func isCreateImageObsAction() -> Bool {
        return obsAction == .createImageObservation
    }
    
    var body: some View {
        SwiftUI.Group {
            Form {
                if let species = data.species {
                    Text(species.sciname)
                }
                if let latitude = data.coords?.latitude,
                   let longitude = data.coords?.longitude {
                    Text("\(longitude), \(latitude)")
                }
                NBEditText(label: "Notes", iconAsset: "details", text: $data.details)
            }
        }.onChange(of: locationManager.userLocation) { location in
            if let location = location {
                data.coords = Coordinates(location: location)
            }
        }
        .fullScreenCover(isPresented: $showImageId) {
            switch imageIdState {
            case .takePhoto:
                ImagePickerView(imageIdState: $imageIdState, data: $data)
            case .crop:
                ImageCropper(imageIdState: $imageIdState, image: $data.crop)
                .ignoresSafeArea()
            case .chooseResult:
                ResultView(imageIdState: $imageIdState, data: $data)
            }
        }
        .sheet(isPresented: $isShowAskForPermission) {
            LocationRequestView()
        }
        .task {
            if isCreateImageObsAction() {
                if cameraManager.askForPermission() {
                    await cameraManager.requestAccess()
                }
                if photoLibraryManager.askForPermission() {
                    await photoLibraryManager.requestAccess()
                }
            }
        }
        .onReceive(cameraManager.$isDenied.combineLatest(photoLibraryManager.$isDenied)) {
            if (isCreateImageObsAction() && ($0 == true || $1 == true)) {
                isPermissionInfoDisplay = true
            }
        }
        .onReceive(cameraManager.$isAuthorized.combineLatest(photoLibraryManager.$isAuthorized)) {
            if (isCreateImageObsAction() && $0 == true && $1 == true) {
                showImageId = true
            }
        }
    }
}

struct ObservationEditView_Previews: PreviewProvider {
    static var previews: some View {
        CreateObservationView(obsAction: .createManualObservation, data: .constant(CreateData()))
    }
}
