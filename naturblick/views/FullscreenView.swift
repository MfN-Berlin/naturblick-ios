//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct FullscreenView: NavigatableView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    
    let imageId: UUID
    @State var image: NBImage? = nil
    var body: some View {
        if let loaded = image {
            Image(uiImage: loaded.image)
                .resizable()
                .scaledToFit()
        } else {
            Text("Loading")
                .task {
                    do {
                        image = try await NBImage(id: imageId)
                    } catch {
                        preconditionFailure("\(error)")
                    }
                }
        }
    }
}

