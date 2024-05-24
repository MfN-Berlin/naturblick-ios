//
// Copyright © 2024 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation

enum Fail {
    static func with(_ error: Error) -> Never {
        AnalyticsTracker.trackError(error: error)
        preconditionFailure("\(error)")
    }
    
    static func with(message: String) -> Never {
        AnalyticsTracker.trackError(message: message)
        preconditionFailure(message)
    }
}
