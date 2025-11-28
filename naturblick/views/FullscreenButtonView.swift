//
// Copyright © 2025 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI
import QuickLook


class FullscreenButtonViewModel: HttpErrorViewModel, QLPreviewControllerDataSource {
    @Published var loadingImage: Bool = false
    var url: URL? = nil

    @MainActor
    func downloadImageItem(remoteUrl: URL) async throws {
        let temporaryUrl = URL.temporaryFileURL(ending: "jpeg")
        let data = try await URLSession.shared.http(request: URLRequest(url: remoteUrl))
        try data.write(to: temporaryUrl, options: [.atomic])
        self.url = temporaryUrl
    }

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        if url == nil {
            return 0
        } else {
            return 1
        }
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> any QLPreviewItem {
        //self.loadingImage = false
        return url! as NSURL
    }
}

struct FullscreenButtonView: View {
    let present: (UIViewController, (() -> Void)?) -> Void
    let url: URL
    @StateObject var model = FullscreenButtonViewModel()

    var body: some View {
        SwiftUI.Group {
            if(model.loadingImage) {
                FABView(systemName: "clock.circle", color: .onSecondaryButtonSecondary, size: .mini)
            } else {
                FABView("zoom", color: .onSecondaryButtonSecondary, size: .mini)
                    .onTapGesture {
                        Task { @MainActor in
                            do {
                                model.loadingImage = true
                                try await model.downloadImageItem(remoteUrl: url)
                                let controller = QLPreviewController()
                                controller.dataSource = model
                                present(controller) {
                                    model.loadingImage = false
                                }
                            } catch {
                                model.loadingImage = false
                                model.handle(error)
                            }
                        }
                    }
            }
        }.alertHttpError(isPresented: $model.isPresented, error: model.error)
    }
}
