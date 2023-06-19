//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct PlantIdView: View {
    let client = BackendClient()
    @StateObject private var cameraManager = CameraManager()
    @StateObject private var photoLibraryManager = PhotoLibraryManager()
    @Binding var data: CreateData.ImageData
    @State var authorized: Bool = false
    var body: some View {
        if authorized {
            if let crop = data.crop {
                Text("Loading results")
                    .task {
                        do {
                            try await client.upload(img: crop.image, mediaId: crop.id.uuidString)
                            data.result = try await client.imageId(mediaId: crop.id.uuidString)
                        } catch {
                            preconditionFailure("\(error)")
                        }
                    }
            } else if let image = data.image {
                ImageCropper(image: image, crop: $data.crop)
            } else {
                ImagePickerView(data: $data)
            }
        } else {
            Text("Naturblick requires permissions")
                .task {
                    if cameraManager.askForPermission() {
                        await cameraManager.requestAccess()
                    }
                    if photoLibraryManager.askForPermission() {
                        await photoLibraryManager.requestAccess()
                    }
                }
                .onReceive(cameraManager.$isAuthorized.combineLatest(photoLibraryManager.$isAuthorized)) { camera, photo in
                    authorized = camera && photo
                }
        }
    }
}

struct PlantIdView_Previews: PreviewProvider {
    static var previews: some View {
        PlantIdView(data: .constant(CreateData.ImageData()))
    }
}
