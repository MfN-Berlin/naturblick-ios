//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation

@MainActor
class HttpErrorViewModel: ObservableObject {
    @Published var isPresented = false
    @Published var error: HttpError? = nil
    
    @discardableResult
    func handle(_ anyError: Error) -> Bool {
        if case HttpError.loggedOut = anyError {
            error = .loggedOut
            isPresented = true
            return true
        } else if let httpError = anyError as? HttpError {
            error = httpError
            isPresented = true
            return false
        } else {
            preconditionFailure("\(anyError)")
        }
    }
}
