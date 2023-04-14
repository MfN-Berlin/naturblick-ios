//
// Copyright © 2023 Museum für Naturkunde Berlin.
// All Rights Reserved.


import Foundation
import Combine

let validStatus = 200...299

protocol HTTPJsonDownloader {
    func httpJson<T: Decodable>(request: URLRequest) -> AnyPublisher<NetworkResult<T>, Never>
}

extension URLSession: HTTPJsonDownloader {
    func httpJson<T: Decodable>(request: URLRequest) -> AnyPublisher<NetworkResult<T>, Never> {
        self
            .dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, validStatus.contains(statusCode) else {
                    throw HttpError.serverError
                }
                let decoder = JSONDecoder()
                return try .success(data: decoder.decode(T.self, from: data))
            }
            .catch { error in
                switch error {
                    case is URLError:
                        return Just(NetworkResult<T>.error(error: .networkError))
                    case let httpError as  HttpError:
                        return Just(NetworkResult<T>.error(error: httpError))
                    default:
                        preconditionFailure(error.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
    }
}
