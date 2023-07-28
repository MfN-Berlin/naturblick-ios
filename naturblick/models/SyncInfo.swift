//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation

struct SyncInfo: Encodable {
    let deviceIdentifier: String
    let syncId: Int?
}
