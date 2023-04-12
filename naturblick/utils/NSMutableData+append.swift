//
// Copyright © 2023 Museum für Naturkunde Berlin.
// All Rights Reserved.


import Foundation

extension NSMutableData {
  func append(_ string: String) {
    if let data = string.data(using: .utf8) {
      self.append(data)
    }
  }
}
