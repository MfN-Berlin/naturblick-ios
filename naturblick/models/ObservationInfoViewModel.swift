//
// Copyright © 2024 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import QuickLook

@MainActor
class ObservationInfoViewModel: HttpErrorViewModel, QLPreviewControllerDataSource {
    let mediaId: UUID?
    let localIdentifier: String?
    let backend: Backend
    @Published var url: URL? = nil
    @Published var loadingImage: Bool = false
    init(mediaId: UUID?, localIdentifier: String?, backend: Backend) {
        self.mediaId = mediaId
        self.localIdentifier = localIdentifier
        self.backend = backend
    }
    
    func downloadImageItem() async throws {
        defer {
            self.loadingImage = false
        }
        self.loadingImage = true
        self.url = try await NBImage(id: mediaId!, backend: backend, localIdentifier: localIdentifier).localFileUrl()
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        url == nil ? 0 : 1;
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> any QLPreviewItem {
        url! as NSURL
    }
    
    
}
