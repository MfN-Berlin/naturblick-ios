//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import Combine
import SwiftUI

class BackendClient {
    let downloader: HTTPDownloader
    private let encoder = JSONEncoder()
    init(downloader: HTTPDownloader = URLSession.shared) {
        self.downloader = downloader
    }

    private func dataFormField(named name: String,
                               data: Data,
                               contentType: String,
                               boundary: UUID) -> Data {
        let fieldData = NSMutableData()

        fieldData.append("--\(boundary.uuidString)\r\n")
        fieldData.append("Content-Disposition: form-data; name=\"\(name)\"\r\n")
        fieldData.append("Content-Type: \(contentType)\r\n")
        fieldData.append("\r\n")
        fieldData.append(data)
        fieldData.append("\r\n")

        return fieldData as Data
    }

    func sync(controller: ObservationPersistenceController) async throws -> ObservationResponse {
        let (ids, operations) = try controller.getPendingOperations()
        let observationRequest = ObservationRequest(operations: operations, syncInfo: SyncInfo(deviceIdentifier: Configuration.deviceIdentifier))
        var mpr = MultipartRequest()
        mpr.addJson(key: "operations", jsonData: try encoder.encode(observationRequest))
        var request = mpr.urlRequest(url: URL(string: Configuration.backendUrl + "obs/androidsync")!, method: "PUT")
        request.setValue(Configuration.deviceIdentifier, forHTTPHeaderField: "X-MfN-Device-Id")
        let response: ObservationResponse = try await downloader.httpJson(request: request)
        try controller.clearPendingOperations(ids: ids)
        return response
    }
    
    func upload(img: UIImage, mediaId: String) async throws {
        var mpr = MultipartRequest()
        mpr.add(
            key: "file",
            fileName: "\(mediaId).jpg",
            fileMimeType: "image/jpeg",
            fileData: img.jpegData(compressionQuality: 0.81)!
        )
        
        let url = URL(string: Configuration.backendUrl + "upload-media?mediaId=\(mediaId)&deviceIdentifier=\(Configuration.deviceIdentifier)")
        var request = mpr.urlRequest(url: url!, method: "PUT")
        request.setValue(Configuration.deviceIdentifier, forHTTPHeaderField: "X-MfN-Device-Id")
        let (_, _) = try await URLSession.shared.data(for: request)
    }
    
    func imageId(mediaId: String) async throws -> [SpeciesResult] {
        let url = URL(string: Configuration.backendUrl + "androidimageid?mediaId=\(mediaId)")
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        let speciesResults: [SpeciesResult] = try await downloader.httpJson(request: request)
        return speciesResults
    }

    func downloadCached(mediaId: UUID) async throws -> UIImage {
        let url = URL(string: Configuration.backendUrl + "/media/\(mediaId)")!
        var request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        request.setValue(Configuration.deviceIdentifier, forHTTPHeaderField: "X-MfN-Device-Id")
        let data = try await downloader.http(request: request)
        return UIImage(data: data)!
    }

    func downloadCached(speciesUrl: String) async throws -> UIImage {
        let url = URL(string: Configuration.strapiUrl + speciesUrl)!
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        let data = try await downloader.http(request: request)
        return UIImage(data: data)!
    }
}
