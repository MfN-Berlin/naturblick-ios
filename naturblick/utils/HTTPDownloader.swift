//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import Combine

let validStatus = 200...299

protocol HTTPDownloader {
    func httpJson<T: Decodable>(request: URLRequest) async throws -> T
    func http(request: URLRequest) async throws -> Data
}

extension URLSession: HTTPDownloader {
    func httpJson<T: Decodable>(request: URLRequest) async throws -> T {
        do {
            let (data, response) = try await self.data(for: request)
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, validStatus.contains(statusCode) else {
                throw HttpError.serverError
            }
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            switch error {
            case is URLError:
                throw HttpError.networkError
            case let httpError as HttpError:
                throw httpError
            default:
                preconditionFailure(error.localizedDescription)
            }
        }
    }
    func http(request: URLRequest) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, validStatus.contains(statusCode) else {
            throw HttpError.serverError
        }
        return data
    }
}
