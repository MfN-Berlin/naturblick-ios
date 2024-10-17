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
    
    func play(sound: NBSound, soundFromTo: SoundFromTo?) {
        currentStatus = .waitingToPlayAtSpecifiedRate
        Task { @MainActor in
            play(url: sound.url, soundFromTo: soundFromTo)
        }
    }
    
    func play(url: URL, soundFromTo: SoundFromTo?) {
        // Always use playback for playback, could have been changed by the sound recorder
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        self.audioPlayer = AVPlayer(url: url)
        
        if let from = soundFromTo?.from, let to = soundFromTo?.to, let audioPlayer = self.audioPlayer {
            let newTime = CMTime(seconds: Double(from/1000), preferredTimescale: 1000)
            audioPlayer.seek(to: newTime, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] success in
                guard success, let self = self else {
                    print("Seek failed")
                    return
                }
                audioPlayer.play()
                let interval = Double(to - from) / 1000
                Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { _ in
                    self.stop()
                }
            }
        } else {
            self.audioPlayer?.play()
        }

        self.audioPlayer?.publisher(for: \.timeControlStatus)
            .filter({ $0 != self.currentStatus }) // prevent firing multiple times
            .assign(to: &$currentStatus)
    }
    
    func stop() {
        self.audioPlayer?.pause()
    }
    
    deinit {
        self.audioPlayer?.pause()
    }
}
