//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation

@MainActor
class HttpErrorViewModel: ObservableObject {
    @Published var isPresented = false
    @Published var error: HttpError? = nil
    
    func handle(_ anyError: Error) {
        if case HttpError.clientError(statusCode: 401) = anyError {
            error = .clientError(statusCode: 401)
            isPresented = true
        } else if let httpError = anyError as? HttpError {
            error = httpError
            isPresented = true
        } else {
            preconditionFailure("\(anyError)")
        }
    }
}
