//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import Combine
import SwiftUI

class BackendClient {
    let downloader: HTTPDownloader
    let local: LocalFileDownloader
    private let encoder = JSONEncoder()
    init(downloader: HTTPDownloader = URLSession.shared, local: LocalFileDownloader = URLSession.shared) {
        self.downloader = downloader
        self.local = local
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
        
        if let token = Settings.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            request.setValue(Configuration.deviceIdentifier, forHTTPHeaderField: "X-MfN-Device-Id")
        }
 
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
    
    func upload(sound: URL, mediaId: UUID) async throws {
        var mpr = MultipartRequest()
        mpr.add(
            key: "file",
            fileName: "\(mediaId).mp4",
            fileMimeType: "audio/mp4",
            fileData: try await local.download(url: sound)
        )
        
        let url = URL(string: Configuration.backendUrl + "upload-media?mediaId=\(mediaId)&deviceIdentifier=\(Configuration.deviceIdentifier)")
        var request = mpr.urlRequest(url: url!, method: "PUT")
        request.setValue(Configuration.deviceIdentifier, forHTTPHeaderField: "X-MfN-Device-Id")
        let _ = try await downloader.http(request: request)
    }
    
    func imageId(mediaId: String) async throws -> [SpeciesResult] {
        let url = URL(string: Configuration.backendUrl + "androidimageid?mediaId=\(mediaId)")
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        let speciesResults: [SpeciesResult] = try await downloader.httpJson(request: request)
        return speciesResults
    }
    
    func soundId(mediaId: String, start: Int, end: Int) async throws -> [SpeciesResult] {
        let url = URL(string: Configuration.backendUrl + "androidsoundid?mediaId=\(mediaId)&segmentStart=\(start)&segmentEnd=\(end)")
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        let speciesResults: [SpeciesResult] = try await downloader.httpJson(request: request)
        return speciesResults
    }
    
    func spectrogram(mediaId: UUID) async throws -> UIImage {
        let url = URL(string: Configuration.backendUrl + "/specgram/\(mediaId)")!
        var request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        request.setValue(Configuration.deviceIdentifier, forHTTPHeaderField: "X-MfN-Device-Id")
        let data = try await downloader.http(request: request)
        return UIImage(data: data)!
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
    
    func signUp(deviceId: String, email: String, password: String) async throws -> Data {
                
        let url = URL(string: Configuration.backendUrl + "signUp")
        var request = URLRequest(url: url!)

        var requestBody = URLComponents()
        requestBody.queryItems = [
            URLQueryItem(name: "deviceIdentifier", value: deviceId),
            URLQueryItem(name: "email", value: email),
            URLQueryItem(name: "password", value: password)
        ]
        
        request.httpBody = requestBody.query?.data(using: .utf8)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        return try await downloader.http(request: request)
    
    }
    
    func signIn(email: String, password: String) async throws -> SigninResponse {
                
        let url = URL(string: Configuration.backendUrl + "signIn")
        var request = URLRequest(url: url!)

        var requestBody = URLComponents()
        requestBody.queryItems = [
            URLQueryItem(name: "username", value: email),
            URLQueryItem(name: "password", value: password),
            URLQueryItem(name: "grant_type", value: "password")
        ]
        
        request.httpBody = requestBody.query?.data(using: .utf8)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
 
        let data = try await downloader.http(request: request)
        let decoder = JSONDecoder()
        let signInResponse = try decoder.decode(SigninResponse.self, from: data)
        
        return signInResponse
    }
    
    func deleteAccount(email: String, password: String) async throws -> Void {
                
        let url = URL(string: Configuration.backendUrl + "account/delete")
        var request = URLRequest(url: url!)

        var requestBody = URLComponents()
        requestBody.queryItems = [
            URLQueryItem(name: "username", value: email),
            URLQueryItem(name: "password", value: password),
            URLQueryItem(name: "grant_type", value: "password")
        ]
        
        request.httpBody = requestBody.query?.data(using: .utf8)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let _ = try await downloader.http(request: request)
    }
    
    func resetPassword(email: String) async throws -> Void {
                
        let url = URL(string: Configuration.backendUrl + "password/forgot")
        var request = URLRequest(url: url!)

        var requestBody = URLComponents()
        requestBody.queryItems = [
            URLQueryItem(name: "email", value: email)
        ]
        
        request.httpBody = requestBody.query?.data(using: .utf8)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let _ = try await downloader.http(request: request)
    }
}
