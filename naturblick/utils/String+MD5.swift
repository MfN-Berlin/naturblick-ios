//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import CryptoKit

extension String {
    func md5() -> String {
        let digest = Insecure.MD5.hash(data: Data(self.utf8))

        return digest.map {
            String(format: "%02hhx", $0)
        }.joined()
    }
}
