//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import AVFoundation
import AVFAudio
import Combine

class SoundStreamController : ObservableObject {
    @Published var currentStatus: AVPlayer.TimeControlStatus?
    private(set) var statusChange: AnyCancellable?
    private var audioPlayer: AVPlayer?
    
    static let shared = SoundStreamController()
    
    private init() { }
    
    func play(sound: String){
        if let url = URL(string: Configuration.strapiUrl + sound) {
            self.audioPlayer = AVPlayer(url: url)
            self.audioPlayer?.play()
            statusChange = self.audioPlayer?.publisher(for: \.timeControlStatus)
                .filter({ $0 != self.currentStatus }) // prevent firing multiple waiting events
                .sink { newStatus in
                    self.currentStatus = newStatus
                }
        }
    }
    
    func stop(){
        self.audioPlayer?.pause()
    }
}
