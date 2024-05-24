//
// Copyright © 2024 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation

enum Fail {
    static func with(_ error: Error) -> Never {
        AnalyticsTracker.trackError(error: error)
        Thread.sleep(forTimeInterval: 1)
        preconditionFailure("\(error)")
    }
    
    static func with(message: String) -> Never {
        AnalyticsTracker.trackError(message: message)
        Thread.sleep(forTimeInterval: 1)
        preconditionFailure(message)
    }
}
