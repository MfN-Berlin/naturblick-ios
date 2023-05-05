//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import Combine

class BackendClient {
    let downloader: HTTPJsonDownloader
    private let encoder = JSONEncoder()
    init(downloader: HTTPJsonDownloader = URLSession.shared) {
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
        let operations = try controller.getPendingOperations()
        let observationRequest = ObservationRequest(operations: operations, syncInfo: SyncInfo(deviceIdentifier: Configuration.deviceIdentifier))
        let boundary = UUID()
        var request = URLRequest(url: URL(string: Configuration.backendUrl + "obs/androidsync")!)
        request.httpMethod = "PUT"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue(Configuration.deviceIdentifier, forHTTPHeaderField: "X-MfN-Device-Id")
        let body = NSMutableData()
        body.append(dataFormField(named: "operations", data: try encoder.encode(observationRequest), contentType: "application/json", boundary: boundary))
        body.append("--\(boundary)--")
        request.httpBody = body as Data
        let response: ObservationResponse = try await downloader.httpJson(request: request)
        try controller.clearPendingOperations(ids: operations.map { $0.occurenceId })
        return response
    }
}
