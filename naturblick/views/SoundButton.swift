//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import AVFoundation

struct SoundButton: View {
    let url: String
    @StateObject private var soundStream = SoundStreamController()
    
    func buttonIcon() -> Image {
        switch soundStream.currentStatus {
            case .waitingToPlayAtSpecifiedRate:
                return Image(systemName: "clock.circle") // placeholder icon
            case .paused:
                return Image("ic_play_circle_outline")
            case .playing:
                return Image("ic_pause_circle_outline")
            default:
                return Image(systemName: "clock.circle")
        }
    }
    
    var body: some View {
        VStack {
            Circle()
                .fill(Color.primaryColor)
                .overlay {
                    buttonIcon()
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.onPrimaryHighEmphasis)
                    .padding(.fabIconPadding)
                }
        }
        .onTapGesture {
            if (soundStream.currentStatus == AVPlayer.TimeControlStatus.paused) {
                soundStream.play(sound: url)
            } else {
                soundStream.stop()
            }
        }
        .onDisappear {
            soundStream.stop()
        }        
    }
}

struct SoundButton_Previews: PreviewProvider {
    static var previews: some View {
        SoundButton(url: "/uploads/bird_33905da8_c19adc870e.mp3")
    }
}
