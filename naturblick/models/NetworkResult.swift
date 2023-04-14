//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import Combine

enum NetworkResult<T> {
    case success(data: T)
    case error(error: HttpError)
}
// This would be nice as an extension to AnyPublisher<NetworkResult<T>, Never>
func assignError<T>(publisher: AnyPublisher<NetworkResult<T>, Never>, errorIsPresented: inout Published<Bool>.Publisher, error: inout Published<HttpError?>.Publisher) -> AnyPublisher<T, Never> {
    let sharedResponse = publisher.share()
    let errorPath = sharedResponse
        .compactMap { result in
            guard case .error(error: let error) = result else {
                return nil as HttpError?
            }
            return error
        }

    errorPath
        .map { $0 as HttpError?}
        .receive(on: RunLoop.main)
        .assign(to: &error)

    errorPath
        .map { _ in true }
        .receive(on: RunLoop.main)
        .assign(to: &errorIsPresented)

    return sharedResponse
        .compactMap { result in
            guard case .success(data: let data) = result else {
                return nil as T?
            }
            return data
        }
        .eraseToAnyPublisher()
}
