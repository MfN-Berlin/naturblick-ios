//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import UIKit
import AVFoundation
import AVFAudio

class SpectrogramViewModel: HttpErrorViewModel {
    let client = BackendClient()
    let mediaId: UUID
    @Published var spectrogram: UIImage? = nil
    @Published var currentStatus: AVPlayer.TimeControlStatus = .paused
    @Published var time: Double = 0.0
    @Published var totalDuration: Double = 0
    @Published var startOffset: CGFloat = 0
    @Published var endOffset: CGFloat = 0
    @Published var start: CGFloat = 0
    @Published var end: CGFloat = 1
    var sound: NBSound? = nil
    
    private var audioPlayer: AVPlayer? = nil
    private var timeObserver: Any? = nil
    init(mediaId: UUID) {
        self.mediaId = mediaId
        super.init()
        do {
            try AVAudioSession.sharedInstance().setCategory(.soloAmbient)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            preconditionFailure("\(error)")
        }
        downloadSpectrogram()
    }
    
    func toggle(start: CGFloat, end: CGFloat) {
        guard let player = audioPlayer else {
            return
        }
        if player.rate != 0 && player.error == nil {
            player.pause()
        } else {
            Task {
                await player.seek(to: CMTimeMakeWithSeconds(start, preferredTimescale: 100))
                player.currentItem?.forwardPlaybackEndTime = CMTimeMakeWithSeconds(end, preferredTimescale: 100)
                player.play()
            }
        }
    }
    
    func stop() {
        guard let player = audioPlayer else {
            return
        }
        player.pause()
    }
    
    func downloadSpectrogram() {
        Task {
            do {
                let sound = try await NBSound(id: mediaId)
                self.sound = sound
                self.audioPlayer = AVPlayer(url: sound.url)
                self.audioPlayer?.currentItem?.publisher(for: \.status)
                    .filter({ $0 == .readyToPlay})
                    .compactMap({ _ in self.audioPlayer?.currentItem?.duration.seconds })
                    .assign(to: &$totalDuration)
                self.audioPlayer?.publisher(for: \.timeControlStatus)
                    .filter({ $0 != self.currentStatus }) // prevent firing multiple waiting
                    .assign(to: &$currentStatus)
                let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
                self.timeObserver = self.audioPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
                    Task { @MainActor [weak self] in
                        self?.time = time.seconds
                    }
                }
                try await client.upload(sound: sound.url, mediaId: sound.id)
                let spectrogram = try await client.spectrogram(mediaId: sound.id)
                Task { @MainActor [weak self] in
                    self?.spectrogram = spectrogram
                }
            } catch {
                let _ = handle(error)
            }
        }
    }
    
    func crop() -> (sound: NBSound, crop: NBThumbnail, start: Int, end: Int)? {
        guard let spectrogram = self.spectrogram, let sound = self.sound else {
            return nil
        }
        let startPx = spectrogram.size.width * start
        let endPx = spectrogram.size.width * end
        let crop = UIGraphicsImageRenderer(size: .thumbnail, format: .noScale).image { _ in
            let cropRect = CGRect(
                x: startPx,
                y: 0,
                width: endPx,
                height: spectrogram.size.height
            )
            if let cgImage = spectrogram.cgImage {
                if let crop = cgImage.cropping(to: cropRect) {
                    let uiImageCrop = UIImage(cgImage: crop, scale: spectrogram.scale, orientation: spectrogram.imageOrientation)
                    uiImageCrop.draw(in: CGRect(origin: .zero, size: .thumbnail))
                }
            }
        }
        let thumbnail = NBThumbnail(image: crop)
        return (sound: sound, crop: thumbnail, start: Int(startPx * .pixelToMsFactor), end: Int(endPx * .pixelToMsFactor))
    }

    deinit {
        do {
            self.audioPlayer?.pause()
            if let observer = self.timeObserver {
                self.audioPlayer?.removeTimeObserver(observer)
                self.timeObserver = nil
            }
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
        }
    }
}
