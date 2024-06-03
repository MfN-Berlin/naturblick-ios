//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import AVFoundation
import AVFAudio
import Combine

class SoundStreamController : ObservableObject {
    @Published var currentStatus: AVPlayer.TimeControlStatus = .paused
    private var audioPlayer: AVPlayer? = nil
    
    func play(sound: NBSound) {
        currentStatus = .waitingToPlayAtSpecifiedRate
        Task { @MainActor in
            play(url: sound.url)
        }
    }
    
    @MainActor func play(url: URL){
        // Always use solo ambient (default) for playback, could have been changed by the sound recorder
        try? AVAudioSession.sharedInstance().setCategory(.soloAmbient)
        self.audioPlayer = AVPlayer(url: url)
        self.audioPlayer?.play()
        self.audioPlayer?.publisher(for: \.timeControlStatus)
            .filter({ $0 != self.currentStatus }) // prevent firing multiple waiting
            .assign(to: &$currentStatus)
    }
    
    func stop() {
        self.audioPlayer?.pause()
    }
    
    deinit {
        self.audioPlayer?.pause()
    }
}
