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

class BirdRecorderViewModel: ObservableObject {
    @Published private(set) var isDenied: Bool = false
    @Published private(set) var currentTime: String = "00:00.0"
    private var recorder: BirdRecorder? = nil
    let audioSession: AVAudioSession
    init() {
        self.audioSession = AVAudioSession.sharedInstance()
        do {
            // Set the audio session category and mode.
            try audioSession.setCategory(.record, mode: .measurement)
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
    func record() {
        guard self.recorder == nil else {
            return
        }
        
        do {
            try audioSession.setActive(true)
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
            recorder.audioRecorder.record(forDuration: 60)
            self.recorder = recorder
        } catch {
            Fail.with(error)
        }
    }
    
    func stop() -> NBSound? {
        guard let recorder = self.recorder else {
            return nil
        }
        do {
            recorder.audioRecorder.stop()
            try AVAudioSession.sharedInstance().setActive(false)
            return recorder.sound
        } catch {
            return recorder.sound
        }
    }
    
    func cancel() {
        do {
            if let isRecording = self.recorder?.audioRecorder.isRecording, isRecording {
                self.recorder?.audioRecorder.stop()
                self.recorder?.audioRecorder.deleteRecording()
            }
            self.recorder = nil
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
                /* Ignore errors when canceling */
        }
    }
    
    deinit {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            /* Ignore errors when canceling */
        }
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
