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
                if model.isAuthorized {
                    Text("\(model.currentTime)")
                        .headline3()
                        .foregroundColor(.onPrimaryHighEmphasis)
                        .onAppear {
                            model.record()
                        }
                        .onDisappear {
                            model.cancel()
                        }
                } else if model.isDenied {
                    Text("Without permission to record it is not possible to record birds")
                } else {
                    Text("Naturblick requires recording")
                }
            }
        } sheet: {
                Circle()
                    .stroke(Color.onSecondaryHighEmphasis, lineWidth: .goodToKnowLineWidth)
                    .overlay {
                        RoundedRectangle(cornerRadius: .smallCornerRadius)
                            .fill(Color.onSecondarywarning)
                            .padding(.defaultPadding * 2)
                    }
                    .frame(width: .stopButtonSize, height: .stopButtonSize)
                    .onTapGesture {
                        flow.soundRecorded(sound: model.stop()!)
                    }
                    .padding(.defaultPadding)
        }
    }
}

struct BirdRecorderView_Previews: PreviewProvider {
    static var previews: some View {
        BirdRecorderView(flow: CreateFlowViewModel(persistenceController: ObservationPersistenceController(inMemory: true)))
    }
}
