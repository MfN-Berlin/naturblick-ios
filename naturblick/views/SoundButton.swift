//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import AVFoundation

struct SoundButton: View {
    let url: URL?
    let mediaId: UUID?
    @StateObject private var soundStream = SoundStreamController()
    
    init(url: URL?) {
        self.url = url
        self.mediaId = nil
    }

    init(mediaId: UUID?) {
        self.url = nil
        self.mediaId = mediaId
    }
    
    func buttonIcon() -> FABView {
        switch soundStream.currentStatus {
            case .waitingToPlayAtSpecifiedRate:
                return FABView(systemName: "clock.circle") // placeholder icon
            case .paused:
                return FABView("ic_play_circle_outline")
            case .playing:
                return FABView("ic_pause_circle_outline")
            default:
                return FABView(systemName: "clock.circle")
        }
    }
    
    var body: some View {
        buttonIcon()
        .onTapGesture {
            if (soundStream.currentStatus == AVPlayer.TimeControlStatus.paused) {
                if let url = url {
                    soundStream.play(url: url)
                } else if let mediaId = mediaId {
                    soundStream.play(mediaId: mediaId)
                }
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
        let url = URL(string: Configuration.strapiUrl + "/uploads/bird_33905da8_c19adc870e.mp3")!
        SoundButton(url: url)
    }
}
