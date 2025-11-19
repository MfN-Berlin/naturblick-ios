//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import AVFoundation

struct SoundButton: View {
    let url: URL?
    let speciesId: Int64?
    let sound: NBSound?
    @StateObject private var soundStream = SoundStreamController()
    
    init(url: URL?, speciesId: Int64?) {
        self.url = url
        self.speciesId = speciesId
        self.sound = nil
    }

    init(sound: NBSound) {
        self.url = nil
        self.speciesId = nil
        self.sound = sound
    }
    
    func buttonIcon() -> FABView {
        switch soundStream.currentStatus {
            case .waitingToPlayAtSpecifiedRate:
            return FABView(systemName: "clock.circle", color: .onSecondaryButtonSecondary, size: .mini) // placeholder icon
            case .paused:
                return FABView("ic_play_circle_outline", color: .onSecondaryButtonSecondary, size: .mini)
            case .playing:
                return FABView("ic_pause_circle_outline", color: .onSecondaryButtonSecondary, size: .mini)
            default:
                return FABView(systemName: "clock.circle", color: .onSecondaryButtonSecondary, size: .mini)
        }
    }
    
    private func toggle() {
        if (soundStream.currentStatus == AVPlayer.TimeControlStatus.paused) {
            if let url = url {
                soundStream.play(url: url, soundFromTo: nil)
                if let specId = speciesId {
                    AnalyticsTracker.trackPortraitSound(speciesId: specId, url: url.absoluteString)
                }
            } else if let sound = sound {
                soundStream.play(sound: sound, soundFromTo: sound.soundFromTo)
            }
        } else {
            soundStream.stop()
        }
    }
    
    var body: some View {
        buttonIcon()
        .accessibilityRepresentation {
            switch soundStream.currentStatus {
                case .waitingToPlayAtSpecifiedRate:
                    Button("Waiting") {
                        self.toggle()
                    }
                case .paused:
                    Button("Play") {
                        self.toggle()
                    }
                case .playing:
                    Button("Pause") {
                        self.toggle()
                    }
                default:
                    Button("Waiting") {
                        self.toggle()
                    }
            }
        }
        .onTapGesture {
            toggle()
        }
        .onDisappear {
            soundStream.stop()
        }        
    }
}

struct SoundButton_Previews: PreviewProvider {
    static var previews: some View {
        let url = URL(string: Configuration.djangoUrl + "/uploads/bird_33905da8_c19adc870e.mp3")!
        SoundButton(url: url, speciesId: 0)
    }
}
