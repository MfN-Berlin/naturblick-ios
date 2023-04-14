//
// Copyright © 2023 Museum für Naturkunde Berlin.
// All Rights Reserved.


import SwiftUI
import AVFoundation
import AVFAudio
import Combine

class SoundStreamer : ObservableObject {
    var audioPlayer: AVPlayer?
    var streamEnd = NotificationCenter.default.publisher(for: NSNotification.Name.NSManagedObjectContextObjectsDidChange)

    func load(sound: String){
        if let url = URL(string: Configuration.strapiUrl + sound) {
            self.audioPlayer = AVPlayer(url: url)
            streamEnd = NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)
        }
    }
}

struct ExampleSoundButton: View {
    let url: String
    let color: Color
    @State var isPlaying = false
    @StateObject private var soundStream = SoundStreamer()
    
    var body: some View {
        VStack {
            Circle()
                .fill(color)
                .overlay {
                    Image(isPlaying ? "pause_circle_outline": "play_circle_outline")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.nbWhite)
                }
        }
        .onTapGesture {
            
            isPlaying.toggle()
            
            if isPlaying {
                soundStream.load(sound: url)
                soundStream.audioPlayer?.play()
            } else {
                soundStream.audioPlayer?.pause()
            }
        }
        .onReceive(soundStream.streamEnd) { _ in
            isPlaying.toggle()
        }
        
    }
}

struct ExampleSoundButton_Previews: PreviewProvider {
    static var previews: some View {
        ExampleSoundButton(url: "/uploads/bird_33905da8_c19adc870e.mp3", color: Color.secondary500)
    }
}

