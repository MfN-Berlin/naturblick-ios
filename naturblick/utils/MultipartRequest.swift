//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import Foundation

struct MultipartRequest {
    
    private let boundary: String
    
    private let separator: String = "\r\n"
    private var data: Data

    init(boundary: String = UUID().uuidString) {
        self.boundary = boundary
        self.data = .init()
    }
    
    private mutating func appendBoundarySeparator() {
        data.append("--\(boundary)\(separator)")
    }
    
    private mutating func appendSeparator() {
        data.append(separator)
    }

    private func disposition(_ key: String) -> String {
        "Content-Disposition: form-data; name=\"\(key)\""
    }

    mutating func add(
        key: String,
        value: String
    ) {
        appendBoundarySeparator()
        data.append(disposition(key) + separator)
        appendSeparator()
        data.append(value + separator)
    }
    
    mutating func addJson(
        key: String,
        jsonData: Data
    ) {
        appendBoundarySeparator()
        data.append(disposition(key) + separator)
        data.append("Content-Type: application/json" + separator + separator)
        data.append(jsonData)
        appendSeparator()
    }

    mutating func add(
        key: String,
        fileName: String,
        fileMimeType: String,
        fileData: Data
    ) {
        appendBoundarySeparator()
        data.append(disposition(key) + "; filename=\"\(fileName)\"" + separator)
        data.append("Content-Type: \(fileMimeType)" + separator + separator)
        data.append(fileData)
        appendSeparator()
    }

    var httpContentTypeHeaderValue: String {
        "multipart/form-data; boundary=\(boundary)"
    }

    var httpBody: Data {
        var bodyData = data
        bodyData.append("--\(boundary)--")
        return bodyData
    }
    
    func urlRequest(url: URL, method: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue(httpContentTypeHeaderValue, forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody
        request.setValue(Configuration.deviceIdentifier, forHTTPHeaderField: "X-MfN-Device-Id")
        return request
    }
}
