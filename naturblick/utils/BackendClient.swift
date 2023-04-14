//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import Combine

class BackendClient {
    let downloader: HTTPJsonDownloader

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

    func sync() -> AnyPublisher<NetworkResult<ObservationResponse>, Never> {
        let boundary = UUID()
        var request = URLRequest(url: URL(string: Configuration.backendUrl + "obs/androidsync")!)
        request.httpMethod = "PUT"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue(Configuration.deviceIdentifier, forHTTPHeaderField: "X-MfN-Device-Id")
        let body = NSMutableData()
        body.append(dataFormField(named: "operations", data: """
{
    "operations": [],
    "syncInfo": {
        "deviceIdentifier": "\(Configuration.deviceIdentifier)"
    }
}
""".data(using: .utf8)!, contentType: "application/json", boundary: boundary))
        body.append("--\(boundary)--")
        request.httpBody = body as Data
        return downloader.httpJson(request: request)
    }
}
