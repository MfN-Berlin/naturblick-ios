//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct SpectrogramView: NavigatableView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    let client = BackendClient()
    let sound: NBSound
    @State private var startOffset: CGFloat = 0
    @State private var endOffset: CGFloat = 0
    @State private var start: CGFloat = 0
    @State private var end: CGFloat = 1
    @ObservedObject var flow: CreateFlowViewModel
    
    func configureNavigationItem(item: UINavigationItem) {
        item.rightBarButtonItem = UIBarButtonItem(primaryAction: UIAction(title: "Identify") {_ in
            crop()
        })
    }
    
    func crop() {
        guard let spectrogram = flow.data.sound.spectrogram else {
            return
        }
        Task {
                let crop = UIGraphicsImageRenderer(size: .thumbnail, format: .noScale).image { _ in
                    let cropRect = CGRect(
                        x: spectrogram.size.width * start,
                        y: 0,
                        width: spectrogram.size.width * end,
                        height: spectrogram.size.height
                    )
                    if let cgImage = spectrogram.cgImage {
                        if let crop = cgImage.cropping(to: cropRect) {
                            let uiImageCrop = UIImage(cgImage: crop, scale: spectrogram.scale, orientation: spectrogram.imageOrientation)
                            uiImageCrop.draw(in: CGRect(origin: .zero, size: .thumbnail))
                        }
                    }
                }
                let thumbnail = NBImage(image: crop)
                try thumbnail.write()
              
            flow.spectrogramCropDone(crop: thumbnail, start: start, end: end)
        }
    }
    
    func updateStartOffset(translation: CGSize, width: CGFloat, minWidth: CGFloat) {
        let startOffset = translation.width
        if start * width + startOffset > 0, (end * width + endOffset) - (start * width + startOffset) > minWidth {
            self.startOffset = startOffset
        }
    }
    
    func updateEndOffset(translation: CGSize, width: CGFloat, minWidth: CGFloat) {
        let endOffset = translation.width
        if end * width + endOffset < width, (end * width + endOffset) - (start * width + startOffset) > minWidth {
            self.endOffset = endOffset
        }
    }
    
    func updateStartAndEndOffset(translation: CGSize, width: CGFloat) {
        let offset = translation.width
        if start * width + offset > 0, end * width + offset < width {
            self.startOffset = offset
            self.endOffset = offset
        }
    }
    
    func startHandle(width: CGFloat, height: CGFloat, minWidth: CGFloat) -> some View {
        Path { path in
            path.addRect(CGRect(x: width * start + 8 + startOffset, y: height / 2 - height / 5, width: 4, height: (height / 5) * 2))
        }
        .fill(Color.whiteOpacity60)
        .overlay {
            Color.clear.contentShape(
                Path { path in
                    path.addRect(CGRect(x: width * start + startOffset, y: 0, width: 20, height: height))
                })
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        updateStartOffset(
                            translation: gesture.translation,
                            width: width,
                            minWidth: minWidth
                        )
                    }
                    .onEnded { gesture in
                        updateStartOffset(
                            translation: gesture.translation,
                            width: width,
                            minWidth: minWidth
                        )
                        start = start + (startOffset / width)
                        startOffset = 0
                    }
            )
        }
    }
    
    func endHandle(width: CGFloat, height: CGFloat, minWidth: CGFloat) -> some View {
        Path { path in
            path.addRect(CGRect(x: width * end - 8 + endOffset, y: height / 2 - height / 5, width: -4, height: (height / 5) * 2))
        }
        .fill(Color.whiteOpacity60)
        .overlay {
            Color.clear.contentShape(
                Path { path in
                    path.addRect(CGRect(x: width * end + endOffset, y: 0, width: -20, height: height))
                })
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        updateEndOffset(
                            translation: gesture.translation,
                            width: width,
                            minWidth: minWidth
                        )
                    }
                    .onEnded { gesture in
                        updateEndOffset(
                            translation: gesture.translation,
                            width: width,
                            minWidth: minWidth
                        )
                        end = end + (endOffset / width)
                        endOffset = 0
                    }
            )
        }
    }
    
    func selectedRectangle(width: CGFloat, height: CGFloat) -> some View {
        let rect = Path { path in
            path
                .addRect(CGRect(
                    x: width * start + startOffset,
                    y: 0,
                    width: (width * end + endOffset) - (width * start + startOffset),
                    height: height)
                )
        }
        return rect
            .fill(Color.whiteOpacity10)
            .overlay {
                rect.stroke(Color.whiteOpacity60, lineWidth: 4)
            }
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        updateStartAndEndOffset(
                            translation: gesture.translation,
                            width: width
                        )
                    }
                    .onEnded { gesture in
                        updateStartAndEndOffset(
                            translation: gesture.translation,
                            width: width
                        )
                        start = start + (startOffset / width)
                        end = end + (endOffset / width)
                        startOffset = 0
                        endOffset = 0
                    }
            )
    }
    
    var body: some View {
        if let spectrogram = flow.data.sound.spectrogram {
            Image(uiImage: spectrogram)
                .resizable()
                .overlay {
                    GeometryReader { geo in
                        let minWidth = (400 / spectrogram.size.width) * geo.size.width
                        let minWidthOrWidth = minWidth < geo.size.width ? minWidth : geo.size.width
                        selectedRectangle(width: geo.size.width, height: geo.size.height)
                            .overlay {
                                startHandle(width: geo.size.width, height: geo.size.height, minWidth: minWidthOrWidth)
                                endHandle(width: geo.size.width, height: geo.size.height, minWidth: minWidthOrWidth)
                            }
                    }
                }
                .onAppear {
                    let initialStart = 1 - 400 / spectrogram.size.width
                    start = initialStart > 0 ? initialStart : 0
                }
        } else {
            Text("Downloading spectrogram")
                .onAppear {
                    Task {
                        do {
                            try await client.upload(sound: sound.url, mediaId: sound.id)
                            let spectrogram = try await client.spectrogram(mediaId: sound.id)
                            flow.spectrogramDownloaded(spectrogram: spectrogram)
                        } catch {
                            //errorHandler.handle(error)
                        }
                    }
                }
        }
    }
}

struct SpectrogramView_Previews: PreviewProvider {
    static var previews: some View {
        SpectrogramView(sound: NBSound(), flow: CreateFlowViewModel(persistenceController: ObservationPersistenceController(inMemory: true)))
    }
}
