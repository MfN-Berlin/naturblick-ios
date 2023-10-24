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
    
    func play(mediaId: UUID) {
        currentStatus = .waitingToPlayAtSpecifiedRate
        Task {
            do {
                let sound = try await NBSound(id: mediaId)
                await play(url: sound.url)
            } catch {
                stop()
            }
        }
    }
    
    @MainActor func play(url: URL){
        do {
            try AVAudioSession.sharedInstance().setCategory(.soloAmbient)
            try AVAudioSession.sharedInstance().setActive(true)
            self.audioPlayer = AVPlayer(url: url)
            self.audioPlayer?.play()
            self.audioPlayer?.publisher(for: \.timeControlStatus)
                .filter({ $0 != self.currentStatus }) // prevent firing multiple waiting
                .assign(to: &$currentStatus)
        } catch {
            preconditionFailure("\(error)")
        }
    }
    
    func stop() {
        do {
            self.audioPlayer?.pause()
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
        }
    }
    
    deinit {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
        }
    }
}
