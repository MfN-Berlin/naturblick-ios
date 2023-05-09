//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI
import AVFoundation
import PhotosUI

struct TakePhotoView: View {

    @Environment(\.dismiss) var dismiss
    @StateObject private var photoViewModel: PhotoViewModel = PhotoViewModel()
    @State private var isImagePickerDisplay = false
    @State private var isPermissionInfoDisplay = false
    
    @StateObject private var cameraManager = CameraManager()
    @StateObject private var photoLibraryManager = PhotoLibraryManager()
    
    var body: some View {
        BaseView {
            VStack {
                Image(uiImage: photoViewModel.img)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
                    .frame(width: 300, height: 300)
                
                Button("Camera") {
                    isImagePickerDisplay.toggle()
                }.padding()
                    .foregroundColor(.black)
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
