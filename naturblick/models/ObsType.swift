//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation

enum ObsType: String, Decodable {
    case manual
    case audio
    case image
    case unidentifiedimage
    case unidentifiedaudio
}
