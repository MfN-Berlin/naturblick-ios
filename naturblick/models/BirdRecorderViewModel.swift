//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import AVFoundation
import AVFAudio
import Combine

struct BirdRecorder {
    let audioRecorder: AVAudioRecorder
    let sound: NBSound
}

class BirdRecorderViewModel: NSObject, ObservableObject, AVAudioRecorderDelegate {
    private let flow: CreateFlowViewModel
    @Published private(set) var currentTime: String = "00:00.0"
    private var recorder: BirdRecorder? = nil
    private var canceled: Bool = false

    init(flow: CreateFlowViewModel) {
        self.flow = flow
    }
    
    func record() {
        guard self.recorder == nil else {
            return
        }
        
        do {
            // Set the audio session category and mode.
            try AVAudioSession.sharedInstance().setCategory(.record, mode: .measurement)
            try AVAudioSession.sharedInstance().setActive(true)
            let sound = NBSound()
            let recorder = BirdRecorder(
                audioRecorder: try AVAudioRecorder(url: sound.url, settings: [
                    AVFormatIDKey: kAudioFormatMPEG4AAC,
                    AVSampleRateKey: 44100,
                    AVNumberOfChannelsKey: 1,
                    AVEncoderBitRateKey: 256000
                ]),
                sound: sound
            )
            recorder.audioRecorder.delegate = self
            recorder.audioRecorder.record(forDuration: 60)
            self.recorder = recorder
            Timer.publish(every: 0.1, on: .main, in: .default)
                .autoconnect()
                .map { [weak self] t in
                    (self?.recorder?.audioRecorder.currentTime ?? 0).toTimeString
                }
                .assign(to: &$currentTime)
        } catch {
            Fail.with(error)
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully: Bool) {
        if let sound = self.recorder?.sound, !canceled {
            Task { @MainActor in
                self.flow.soundRecorded(sound: sound)
            }
        }
        try! AVAudioSession.sharedInstance().setActive(false)
    }

    func stop() {
        recorder?.audioRecorder.stop()
    }
    
    func cancel() {
        canceled = true
        if let isRecording = self.recorder?.audioRecorder.isRecording, isRecording {
            self.recorder?.audioRecorder.stop()
            self.recorder?.audioRecorder.deleteRecording()
        }
        self.recorder = nil
        try! AVAudioSession.sharedInstance().setActive(false)
    }
    
    deinit {
        /* Ignore errors when canceling */
        try! AVAudioSession.sharedInstance().setActive(false)
        try! AVAudioSession.sharedInstance().setCategory(.playback)
    }
}

extension Double {
    var toTimeString: String {
        let time = Int(self)
        let ms = Int((self.truncatingRemainder(dividingBy: 1)) * 10)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        return String(format: "%0.2d:%0.2d.%d",minutes,seconds,ms)
    }
}
