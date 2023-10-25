//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import AVFoundation

extension AVAudioSession {
    func requestRecordPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }
}
