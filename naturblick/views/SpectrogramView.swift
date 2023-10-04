//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct SpectrogramView<Flow>: NavigatableView where Flow: IdFlow {
    var holder: ViewControllerHolder = ViewControllerHolder()
    var alwaysDarkBackground: Bool = true
    @State private var startOffset: CGFloat = 0
    @State private var endOffset: CGFloat = 0
    @State private var start: CGFloat = 0
    @State private var end: CGFloat = 1
    @ObservedObject var flow: Flow
    @StateObject private var model: SpectrogramViewModel
    @StateObject private var streamController = SoundStreamController()
    
    init(sound: NBSound, flow: Flow) {
        self._model = StateObject(wrappedValue: SpectrogramViewModel(sound: sound))
        self.flow = flow
    }
    
    func crop() {
        guard let spectrogram = model.spectrogram else {
            return
        }
        Task {
            let startPx = spectrogram.size.width * start
            let endPx = spectrogram.size.width * end
            let crop = UIGraphicsImageRenderer(size: .thumbnail, format: .noScale).image { _ in
                let cropRect = CGRect(
                    x: startPx,
                    y: 0,
                    width: endPx,
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
            flow.spectrogramCropDone(crop: thumbnail, start: Int(startPx * .pixelToMsFactor), end: Int(endPx * .pixelToMsFactor))
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
    
    func timeText(spectrogram: UIImage) -> String {
        Double((((end - start) * spectrogram.size.width) * .pixelToMsFactor) / 1000).toTimeString
    }
    
    var body: some View {
        StaticBottomSheetView {
            VStack {
                if let spectrogram = model.spectrogram {
                    Text("Choose section")
                        .headline6()
                        .padding([.horizontal, .top], .defaultPadding)
                    Text("Please select a section that best represents the bird\'s sound. Our pattern recognition gives the best results for recordings that are under 10 seconds.")
                        .caption(color: .onPrimaryLowEmphasis)
                        .padding([.horizontal, .bottom], .defaultPadding)
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
                    HStack {
                        FABView("ic_play_circle_outline", color: .onPrimaryButtonPrimary)
                            .onTapGesture {
                                streamController.play(url: model.sound.url)
                            }
                        Text(timeText(spectrogram: spectrogram))
                            .font(.nbHeadline3)
                            .foregroundColor(.onPrimaryHighEmphasis)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.defaultPadding)
                } else {
                    ProgressView {
                        Text("Downloading spectrogram")
                            .font(.nbButton)
                            .foregroundColor(.onSecondaryMediumEmphasis)
                    }
                    .progressViewStyle(.circular)
                    .foregroundColor(.onSecondaryHighEmphasis)
                    .controlSize(.large)
                }
            }
        } sheet: {
            HStack {
                Button("Discard") {
                    navigationController?.popToRootViewController(animated: true)
                }
                .buttonStyle(DestructiveButton())
                Button("Identify species") {
                    crop()
                }
                .buttonStyle(ConfirmButton())
                .padding(.leading, .defaultPadding)
            }
        }
        .alertHttpError(isPresented: $model.isPresented, error: model.error) { details in
            Button("Try again") {
                model.downloadSpectrogram()
            }
            Button("Browse species") {
                
            }
            Button("Save as unknown species") {
                flow.selectSpecies(species: nil)
            }
        }
        .onReceive(model.$spectrogram) { spectrogramOpt in
            if let spectrogram = spectrogramOpt {
                let initialStart = 1 - 400 / spectrogram.size.width
                start = initialStart > 0 ? initialStart : 0
            }
        }
    }
}

struct SpectrogramView_Previews: PreviewProvider {
    static var previews: some View {
        SpectrogramView(sound: NBSound(), flow: CreateFlowViewModel(persistenceController: ObservationPersistenceController(inMemory: true)))
    }
}
