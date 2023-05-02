//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

struct TakePhotoView: View {

    @StateObject private var photoViewModel: PhotoViewModel = PhotoViewModel()
    @State private var isImagePickerDisplay = false
    
    var body: some View {
        BaseView {
            VStack {
                Image(uiImage: photoViewModel.img)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
                    .frame(width: 300, height: 300)
                
                Button("Camera") {
                    self.isImagePickerDisplay.toggle()
                }.padding()
                    .foregroundColor(.black)
            }
            .sheet(isPresented: self.$isImagePickerDisplay) {
                ImagePickerView(photoViewModel: self.photoViewModel)
            }
            .onAppear {
                isImagePickerDisplay = true
            }
        }
    }
    
}
