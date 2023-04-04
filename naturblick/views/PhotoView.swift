//
// Copyright © 2023 Museum für Naturkunde Berlin.
// All Rights Reserved.


import SwiftUI
import AVKit

struct PhotoView: View {
    
    private let session = AVCaptureSession()
    	
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct PhotoView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoView()
    }
}

// Saving https://developer.apple.com/documentation/photokit/delivering_an_enhanced_privacy_experience_in_your_photos_app

// Check the app's authorization status (either read/write or add-only access).
// let readWriteStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)



// CHECK authorization before capture session

//var isAuthorized: Bool {
//    get async {
//        let status = AVCaptureDevice.authorizationStatus(for: .video)
//
//        // Determine if the user previously authorized camera access.
//        var isAuthorized = status == .authorized
//
//        // If the system hasn't determined the user's authorization status,
//        // explicitly prompt them for approval.
//        if status == .notDetermined {
//            isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
//        }
//
//        return isAuthorized
//    }
//}
//
//func setUpCaptureSession() async {
//    guard await isAuthorized else { return }
//    // Set up the capture session.
//}
