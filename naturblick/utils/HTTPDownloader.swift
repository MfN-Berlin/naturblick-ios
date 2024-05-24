//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import Combine
import os
import UIKit

let validStatus = 200...299
let clientError = 400...499

protocol HTTPDownloader {
    func httpJson<T: Decodable>(request: URLRequest) async throws -> T
    func http(request: URLRequest) async throws -> Data
    func httpSend(request: URLRequest, data: Data) async throws -> Data
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
            try await checkForErrorStatus(statusCode: statusCode, data: data)
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            Logger.http.info("HTTP error: \(error)")
            switch error {
            case is URLError:
                throw HttpError.networkError
            case let httpError as HttpError:
                throw httpError
            default:
                Fail.with(error)
            }
        }
    }
    func http(request: URLRequest) async throws -> Data {
        do {
            let (data, response) = try await self.data(for: request)
            let statusCode = (response as? HTTPURLResponse)!.statusCode
            try await checkForErrorStatus(statusCode: statusCode, data: data)
            return data
        } catch {
            Logger.http.info("HTTP error: \(error)")
            switch error {
            case is URLError:
                throw HttpError.networkError
            case let httpError as HttpError:
                throw httpError
            default:
                Fail.with(error)
            }
        }
    }
    
    private func checkForErrorStatus(statusCode: Int, data: Data) async throws {
        guard validStatus.contains(statusCode) else {
            if statusCode == 401 {
                await Keychain.shared.deleteToken()
                throw HttpError.loggedOut
            } else if clientError.contains(statusCode) {
                throw HttpError.clientError(statusCode: statusCode)
            } else {
                throw HttpError.serverError(statusCode: statusCode, data: String(decoding: data[..<min(64, data.count)], as: UTF8.self))
            }
        }
    }

    func httpSend(request: URLRequest, data: Data) async throws -> Data {
        do {
            let (responseData, response) = try await self.upload(for: request, from: data)
            let httpResponse = (response as! HTTPURLResponse)
            let statusCode = httpResponse.statusCode
            try await checkForErrorStatus(statusCode: statusCode, data: data)
            return responseData
        } catch {
            Logger.http.info("HTTP error: \(error)")
            switch error {
            case is URLError:
                throw HttpError.networkError
            case let httpError as HttpError:
                throw httpError
            default:
                Fail.with(error)
            }
        }
    }

}

extension URLSession {
    func cachedImage(url: URL) async -> UIImage? {
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        guard let data = try? await URLSession.shared.data(for: request).0 else {
            return nil
        }
        return UIImage(data: data)
    }
}
