//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct FullscreenView: NavigatableView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    
    let imageId: UUID
    let localIdentifier: String?
    let backend: Backend
    @State var image: NBImage? = nil
    @StateObject var errorHandler = HttpErrorViewModel()
    var body: some View {
        SwiftUI.Group {
            if let loaded = image {
                Image(uiImage: loaded.image)
                    .resizable()
                    .scaledToFit()
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
                    .foregroundColor(.onSecondaryHighEmphasis)
                    .controlSize(.large)
                    .task {
                        do {
                            image = try await NBImage(id: imageId, backend: backend, localIdentifier: localIdentifier)
                        } catch {
                            errorHandler.handle(error)
                        }
                    }
            }
        }
        .alertHttpError(isPresented: $errorHandler.isPresented, error: errorHandler.error)
    }
}

