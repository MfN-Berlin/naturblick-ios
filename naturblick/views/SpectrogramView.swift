//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

class SpectrogramViewController<Flow>: HostingController<SpectrogramView<Flow>> where Flow: IdFlow {
    let flow: Flow
    let model: SpectrogramViewModel
    
    init(mediaId: UUID, flow: Flow) {
        self.flow = flow
        self.model = SpectrogramViewModel(mediaId: mediaId, obsIdent: flow.obsIdent)
        super.init(rootView: SpectrogramView(model: model, flow: flow))
    }
}

struct SpectrogramView<Flow>: HostedView where Flow: IdFlow {
    var holder: ViewControllerHolder = ViewControllerHolder()
    var alwaysDarkBackground: Bool = true
    @ObservedObject var flow: Flow
    @ObservedObject var model: SpectrogramViewModel
    
    func configureNavigationItem(item: UINavigationItem) {
        item.rightBarButtonItem = UIBarButtonItem(primaryAction: UIAction(title: String(localized: "identify_species")) {_ in
            if let (sound, thumbnail, start, end) = self.model.crop() {
                self.flow.spectrogramCropDone(sound: sound, crop: thumbnail, start: start, end: end)
            }
        })
    }
    
    init(model: SpectrogramViewModel, flow: Flow) {
        self.model = model
        self.flow = flow
    }
    
    func updateStartOffset(translation: CGSize, width: CGFloat, minWidth: CGFloat) {
        let startOffset = translation.width
        if model.start * width + startOffset > 0, (model.end * width + model.endOffset) - (model.start * width + startOffset) > minWidth {
            model.startOffset = startOffset
        }
    }
    
    func updateEndOffset(translation: CGSize, width: CGFloat, minWidth: CGFloat) {
        let endOffset = translation.width
        if model.end * width + endOffset < width, (model.end * width + endOffset) - (model.start * width + model.startOffset) > minWidth {
            model.endOffset = endOffset
        }
    }
    
    func updateStartAndEndOffset(translation: CGSize, width: CGFloat) {
        let offset = translation.width
        if model.start * width + offset > 0, model.end * width + offset < width {
            model.startOffset = offset
            model.endOffset = offset
        }
    }
    
    func startHandle(width: CGFloat, height: CGFloat, minWidth: CGFloat) -> some View {
        Path { path in
            path.addRect(CGRect(x: width * model.start + 8 + model.startOffset, y: height / 2 - height / 5, width: 4, height: (height / 5) * 2))
        }
        .fill(Color.whiteOpacity60)
        .overlay {
            Color.clear.contentShape(
                Path { path in
                    path.addRect(CGRect(x: width * model.start + model.startOffset, y: 0, width: 20, height: height))
                })
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        model.stop()
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
                        model.start = model.start + (model.startOffset / width)
                        model.startOffset = 0
                    }
            )
        }
    }
    
    func endHandle(width: CGFloat, height: CGFloat, minWidth: CGFloat) -> some View {
        Path { path in
            path.addRect(CGRect(x: width * model.end - 8 + model.endOffset, y: height / 2 - height / 5, width: -4, height: (height / 5) * 2))
        }
        .fill(Color.whiteOpacity60)
        .overlay {
            Color.clear.contentShape(
                Path { path in
                    path.addRect(CGRect(x: width * model.end + model.endOffset, y: 0, width: -20, height: height))
                })
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        model.stop()
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
                        model.end = model.end + (model.endOffset / width)
                        model.endOffset = 0
                    }
            )
        }
    }
    
    func selectedRectangle(width: CGFloat, height: CGFloat) -> some View {
        let rect = Path { path in
            path
                .addRect(CGRect(
                    x: width * model.start + model.startOffset,
                    y: 0,
                    width: (width * model.end + model.endOffset) - (width * model.start + model.startOffset),
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
                        model.stop()
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
                        model.start = model.start + (model.startOffset / width)
                        model.end = model.end + (model.endOffset / width)
                        model.startOffset = 0
                        model.endOffset = 0
                    }
            )
    }
    
    func timeText(spectrogram: UIImage) -> String {
        if model.currentStatus != .playing {
            Double((((model.end - model.start) * spectrogram.size.width) * .pixelToMsFactor) / 1000).toTimeString
        } else {
            (model.time - model.start * model.totalDuration).toTimeString
        }
    }
    
    func buttonIcon() -> FABView {
        switch model.currentStatus {
            case .waitingToPlayAtSpecifiedRate:
                return FABView(systemName: "clock.circle", color: .onPrimaryButtonPrimary) // placeholder icon
            case .paused:
                return FABView("ic_play_circle_outline", color: .onPrimaryButtonPrimary)
            case .playing:
                return FABView("ic_pause_circle_outline", color: .onPrimaryButtonPrimary)
            default:
                return FABView(systemName: "clock.circle", color: .onPrimaryButtonPrimary)
        }
    }
    
    var body: some View {
        VStack(spacing: .defaultPadding) {
            if let spectrogram = model.spectrogram {
                Text("choose_section")
                    .headline6()
                    .padding(.top, .doublePadding)
                Text("please_select")
                    .caption(color: .onPrimaryLowEmphasis)
                    .padding([.trailing, .leading])
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
                    buttonIcon()
                        .onTapGesture {
                            model.toggle(start: model.start * model.totalDuration, end: model.end * model.totalDuration)
                        }
                    Text(timeText(spectrogram: spectrogram))
                        .headline3()
                }
                .fixedSize(horizontal: false, vertical: true)
                .padding(.defaultPadding)
            } else {
                ProgressView {
                    Text("downloading_spectrogram")
                        .headline6(color: .onPrimaryMediumEmphasis)
                        .padding()
                }
                .progressViewStyle(CircularProgressViewStyle(tint: .onPrimaryHighEmphasis))
                .controlSize(.large)
            }
        }
        .alertHttpError(isPresented: $model.isPresented, error: model.error) { details in
            Button("try_again") {
                model.downloadSpectrogram()
            }
            Button("browse_species") {
                flow.searchSpecies()
            }
            Button("save_unknown") {
                flow.selectSpecies(species: nil)
            }
        }
        .onReceive(model.$spectrogram) { spectrogramOpt in
            if let spectrogram = spectrogramOpt {
                let initialStart = 1 - 400 / spectrogram.size.width
                model.start = initialStart > 0 ? initialStart : 0
            }
        }
    }
}

struct SpectrogramView_Previews: PreviewProvider {
    static var previews: some View {
        SpectrogramView(model: SpectrogramViewModel(mediaId: UUID(), obsIdent: nil), flow: CreateFlowViewModel(persistenceController: ObservationPersistenceController(inMemory: true)))
    }
}
