//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation

protocol LocalFileDownloader {
    func download(url: URL) async throws -> Data
}

extension URLSession: LocalFileDownloader {
    func download(url: URL) async throws -> Data {
        return try await URLSession.shared.data(for: URLRequest(url: url)).0
    }
}
