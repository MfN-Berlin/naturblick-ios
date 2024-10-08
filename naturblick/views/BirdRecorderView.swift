//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct BirdRecorderView: NavigatableView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    var alwaysDarkBackground: Bool = true
    @StateObject private var model = BirdRecorderViewModel()
    @ObservedObject var flow: CreateFlowViewModel
    
    var body: some View {
        StaticBottomSheetView {
            HStack(alignment: .center) {
                Text("\(model.currentTime)")
                    .headline3()
                    .foregroundColor(.onPrimaryHighEmphasis)
                    .onAppear {
                        model.record()
                    }
                    .onDisappear {
                        model.cancel()
                    }
            }
        } sheet: {
            Circle()
                .stroke(Color.onSecondaryDisabled, lineWidth: .goodToKnowLineWidth)
                .overlay {
                    RoundedRectangle(cornerRadius: .largeCornerRadius)
                        .fill(Color.onSecondarywarning)
                        .frame(width: .stopButtonSize, height: .stopButtonSize)
                        .nbShadow()
                }
                .frame(width: .stopButtonCircleSize, height: .stopButtonCircleSize)
                .onTapGesture {
                    flow.soundRecorded(sound: model.stop()!)
                }
                .padding(.defaultPadding)
        }
        .accessibilityAction(.magicTap) {
            flow.soundRecorded(sound: model.stop()!)
        }
    }
}

struct BirdRecorderView_Previews: PreviewProvider {
    static var previews: some View {
        BirdRecorderView(flow: CreateFlowViewModel(backend: Backend(persistence: ObservationPersistenceController(inMemory: true))))
    }
}
