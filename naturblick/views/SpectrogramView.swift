//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct SpectrogramView: View {
    let spectrogram: UIImage
    @State private var startOffset: CGFloat = 0
    @State private var endOffset: CGFloat = 0
    @Binding var start: CGFloat
    @Binding var end: CGFloat
    
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
    }
}

struct SpectrogramView_Previews: PreviewProvider {
    static var previews: some		 View {
        SpectrogramView(spectrogram: UIImage(systemName: "map")!, start: .constant(0), end: .constant(1))
    }
}
