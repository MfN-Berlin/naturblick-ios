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
        GeometryReader { geo in
            VStack(spacing: .zero) {
                HStack(alignment: .center) {
                    Text("\(model.currentTime)")
                        .headline3()
                        .accessibilityLabel(Text("acc_record_duration"))
                        .accessibilityValue(model.currentTime)
                        .foregroundColor(.onPrimaryHighEmphasis)
                        .onAppear {
                            model.record()
                        }
                        .onDisappear {
                            model.cancel()
                        }
                }
                    .frame(maxHeight: .infinity)
                VStack(spacing: .zero) {
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
                        .accessibilityElement(children: .combine)
                        .accessibility(label: Text("Stop"))
                }
                .padding(.defaultPadding)
                .padding(.bottom, geo.safeAreaInsets.bottom)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: .largeCornerRadius)
                        .fill(Color.secondaryColor)
                        .nbShadow()
                )
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

struct BirdRecorderView_Previews: PreviewProvider {
    static var previews: some View {
        BirdRecorderView(flow: CreateFlowViewModel(persistenceController: ObservationPersistenceController(inMemory: true)))
    }
}
