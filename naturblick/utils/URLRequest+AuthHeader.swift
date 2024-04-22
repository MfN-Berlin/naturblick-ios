//
// Copyright © 2024 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation

extension URLRequest {
    mutating func setAuthHeader(bearerToken: String?) {
        if let token = bearerToken {
            setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            setValue(Settings.deviceIdHeader(), forHTTPHeaderField: "X-MfN-Device-Id")
        }
    }
}