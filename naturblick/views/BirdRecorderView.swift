//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct BirdRecorderView: View {
    @StateObject private var model = BirdRecorderViewModel()
    @Binding var sound: NBSound?
    var body: some View {
        if model.isAuthorized {
            Text("\(model.currentTime)")
                .onTapGesture {
                    sound = model.stop()
                }
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
}

struct BirdRecorderView_Previews: PreviewProvider {
    static var previews: some View {
        BirdRecorderView(sound: .constant(nil))
    }
}
