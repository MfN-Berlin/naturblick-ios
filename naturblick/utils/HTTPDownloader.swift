//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import Combine
import os

let validStatus = 200...299

protocol HTTPDownloader {
    func httpJson<T: Decodable>(request: URLRequest) async throws -> T
    func http(request: URLRequest) async throws -> Data
    func postPut(request: URLRequest, completionHandler: @Sendable @escaping (Data?, URLResponse?, Error?) -> Void) async throws
}

extension URLSession: HTTPDownloader {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: HTTPDownloader.self)
    )
    func httpJson<T: Decodable>(request: URLRequest) async throws -> T {
        do {
            let (data, response) = try await self.data(for: request)
            let httpResponse = (response as! HTTPURLResponse)
            let statusCode = httpResponse.statusCode
            guard validStatus.contains(statusCode) else {
                throw HttpError.serverError(statusCode: statusCode, data: String(decoding: data[..<min(64, data.count)], as: UTF8.self))
            }
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            switch error {
            case is URLError:
                Self.logger.error("Network error \(error)")
                throw HttpError.networkError
            case let httpError as HttpError:
                Self.logger.error("Server error \(error)")
                throw httpError
            default:
                preconditionFailure("\(error)")
            }
        }
    }
    func http(request: URLRequest) async throws -> Data {
        do {
            let (data, response) = try await self.data(for: request)
            let statusCode = (response as? HTTPURLResponse)!.statusCode
            guard validStatus.contains(statusCode) else {
                throw HttpError.serverError(statusCode: statusCode, data: String(decoding: data[..<min(64, data.count)], as: UTF8.self))
            }
            return data
        } catch {
            switch error {
            case is URLError:
                Self.logger.error("Network error \(error)")
                throw HttpError.networkError
            case let httpError as HttpError:
                Self.logger.error("Server error \(error)")
                throw httpError
            default:
                preconditionFailure("\(error)")
            }
        }
    }
    
    func postPut(request: URLRequest, completionHandler: @Sendable @escaping (Data?, URLResponse?, Error?) -> Void) async throws {
        dataTask(with: request, completionHandler: completionHandler).resume()
    }
    
}
