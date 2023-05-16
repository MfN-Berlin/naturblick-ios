//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI
import AVFoundation
import PhotosUI

struct TakePhotoView: View {

    @Binding var isPresented: Bool
    @StateObject private var photoViewModel: PhotoViewModel = PhotoViewModel()
    @State private var isImagePickerDisplay = false
    @State private var isPermissionInfoDisplay = false
    
    @StateObject private var cameraManager = CameraManager()
    @StateObject private var photoLibraryManager = PhotoLibraryManager()
    
    @Binding var data: CreateData
        
    private func identify() {
        guard let crop = photoViewModel.crop else { return }
        Task {
            do {
                let mediaId = UUID().uuidString
                try await BackendClient().upload(img: crop, mediaId: mediaId)
                let results = try await BackendClient().imageId(mediaId: mediaId)
                photoViewModel.setSpeciesResult(results: results)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    var body: some View {
        BaseView {
            VStack {
                if let img = photoViewModel.img {
                    Image(uiImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Rectangle())
                        .frame(width: 300, height: 300)
                    
                    if let species = photoViewModel.species {
                        ForEach(species) { species in
                            Button {
                                data.species = species
                                isPresented = false
                            } label: {
                                Text(species.sciname)
                                    .padding()
                            }.frame(width: UIScreen.main.bounds.width)
                                .padding(.horizontal, -32)
                                .background(Color.onSecondaryButtonPrimary)
                                .clipShape(Capsule())
                                .padding()
                        }
                    } else {
                        Button {
                            identify()
                        } label: {
                            Text("Identify")
                                .button()
                                .padding()
                        }
                        .frame(width: UIScreen.main.bounds.width)
                        .padding(.horizontal, -32)
                        .background(Color.onSecondaryButtonPrimary)
                        .clipShape(Capsule())
                        .padding()
                    }
                }
            }
            .sheet(isPresented: $isImagePickerDisplay) {
                ImagePickerView(photoViewModel: photoViewModel)
            }
            .sheet(isPresented: $isPermissionInfoDisplay) {
                PermissionInfoView(isPresented: $isPermissionInfoDisplay)
            }
        }
        .task {
            if cameraManager.askForPermission() {
                await cameraManager.requestAccess()
            }
            if photoLibraryManager.askForPermission() {
                await photoLibraryManager.requestAccess()
            }
        }
        .onReceive(cameraManager.$isDenied.combineLatest(photoLibraryManager.$isDenied)) {
            if ($0 == true || $1 == true) {
                isPermissionInfoDisplay = true
            }
        }
        .onReceive(cameraManager.$isAuthorized.combineLatest(photoLibraryManager.$isAuthorized)) {
            if ($0 == true && $1 == true) {
                isImagePickerDisplay = true
            }
        }
    }
}
