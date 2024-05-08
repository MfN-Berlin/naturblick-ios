//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import Foundation
import Combine
import SwiftUI

struct Chunk {
    
    private let MAX_CHUNK_SIZE = 5 * 1024 * 1024 // 5 MB
    
    private(set) var size: Int = 0
    private(set) var ids: [Int64] = []
    private(set) var operations: [Operation] = []
    
    mutating func addOperation(id: Int64, operation: Operation) {
        operations.append(operation)
        ids.append(id)
        
        guard let encoded = try? JSONEncoder().encode(operation) else {
            preconditionFailure("Failed to encode operation")
        }
        
        size += encoded.count

        if case .upload(let upload) = operation {
            let fileUrl = URL.uploadFileURL(id: upload.mediaId, mime: upload.mime)
            size += fileUrl.fileSizeBytes()
        }
    }
    
    func exceedsMaxSize() -> Bool {
        size > MAX_CHUNK_SIZE
    }
}

class BackendClient {
    let downloader: HTTPDownloader
    let local: LocalFileDownloader
    private let encoder = JSONEncoder()
    @AppSecureStorage(NbAppSecureStorageKey.BearerToken) var bearerToken: String?
    
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

    func sync(controller: ObservationPersistenceController) async throws {
        let (ids, operations) = try controller.getPendingOperations()
        var chunk = Chunk()
        
        for (i, o) in zip(ids, operations) {
            chunk.addOperation(id: i, operation: o)
            if chunk.exceedsMaxSize() {
                try await syncChunk(chunk: chunk, controller: controller)
                chunk = Chunk()
            }
        }
        try await syncChunk(chunk: chunk, controller: controller)
    }
    
    private func syncChunk(chunk: Chunk, controller: ObservationPersistenceController) async throws {
        let sync = try controller.getSync()
        let observationRequest = ObservationRequest(operations: chunk.operations, syncInfo: SyncInfo(deviceIdentifier: Settings.deviceId(), syncId: sync?.syncId))
        var mpr = MultipartRequest()
        let json = try encoder.encode(observationRequest)
        mpr.addJson(key: "operations", jsonData: json)
        for operation in chunk.operations {
            if case .upload(let upload) = operation {
                let fileUrl = URL.uploadFileURL(id: upload.mediaId, mime: upload.mime)
                let data = try await local.download(url: fileUrl)
                mpr.add(key: upload.mediaId.uuidString.lowercased(), fileName: upload.mediaId.filename(mime: upload.mime), fileMimeType: upload.mime.rawValue, fileData: data)
            }
        }
        
        var request = mpr.urlRequest(url: URL(string: Configuration.backendUrl + "obs/androidsync")!, method: "PUT")
        request.timeoutInterval = 30
        request.setAuthHeader(bearerToken: bearerToken)
 
        let response: ObservationResponse = try await downloader.httpJson(request: request)
        
        if (!response.partial) {
            try controller.truncateObservations()
        }
        
        try controller.handleChunk(from: response.data, ids: chunk.ids, syncId: response.syncId)
        
        for operation in chunk.operations {
            if case .upload(let upload) = operation {
                // Ignore failures deleting the file uploaded
                try? FileManager().removeItem(at: URL.uploadFileURL(id: upload.mediaId, mime: upload.mime))
            }
        }
    }
    
    func deviceConnect(token: String, deviceId: String) async throws {
    
        struct ConnectDevice: Encodable {
            let deviceIdentifier: String
        }
        
        let url = URL(string: Configuration.backendUrl + "device-connect")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                
        guard let encoded = try? JSONEncoder().encode(ConnectDevice(deviceIdentifier: deviceId)) else {
            preconditionFailure("Failed to encode ConnectDevice")
        }
        
        let _ = try await downloader.httpSend(request: request, data: encoded)
    }

    func upload(image: NBThumbnail) async throws {
        let mediaId = image.id.uuidString.lowercased()
        var mpr = MultipartRequest()
        mpr.add(
            key: "file",
            fileName: "\(mediaId).jpg",
            fileMimeType: "image/jpeg",
            fileData: image.image.jpegData(compressionQuality: 0.81)!
        )
        
        let url = URL(string: Configuration.backendUrl + "upload-media?mediaId=\(mediaId)&deviceIdentifier=\(Settings.deviceId())")
        var request = mpr.urlRequest(url: url!, method: "PUT")
        request.setValue(Settings.deviceIdHeader(), forHTTPHeaderField: "X-MfN-Device-Id")
        let _ = try await downloader.http(request: request)
    }
    
    func upload(sound: URL, mediaId: UUID) async throws {
        var mpr = MultipartRequest()
        mpr.add(
            key: "file",
            fileName: "\(mediaId).mp4",
            fileMimeType: "audio/mp4",
            fileData: try await local.download(url: sound)
        )
        
        let url = URL(string: Configuration.backendUrl + "upload-media?mediaId=\(mediaId)&deviceIdentifier=\(Settings.deviceId())")
        var request = mpr.urlRequest(url: url!, method: "PUT")
        request.setValue(Settings.deviceIdHeader(), forHTTPHeaderField: "X-MfN-Device-Id")
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
        request.setAuthHeader(bearerToken: bearerToken)
        let data = try await downloader.http(request: request)
        return UIImage(data: data)!
    }

    func downloadSound(mediaId: UUID) async throws -> Data {
        let url = URL(string: Configuration.backendUrl + "/media/\(mediaId)")!
        var request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        request.setAuthHeader(bearerToken: bearerToken)
        return try await downloader.http(request: request)
    }
    
    func downloadCached(mediaId: UUID) async throws -> UIImage {
        let url = URL(string: Configuration.backendUrl + "/media/\(mediaId)")!
        var request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        request.setAuthHeader(bearerToken: bearerToken)
        let data = try await downloader.http(request: request)
        return UIImage(data: data)!
    }

    func downloadCached(speciesUrl: String) async throws -> UIImage {
        let url = URL(string: Configuration.strapiUrl + speciesUrl)!
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        let data = try await downloader.http(request: request)
        return UIImage(data: data)!
    }
    
    func signUp(deviceId: String, email: String, password: String) async throws {
                
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
        
        let _ = try await downloader.http(request: request)
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
        for deviceId in Settings.getAllDeviceIds() {
            try await deviceConnect(token: signInResponse.access_token, deviceId: deviceId)
        }
        
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
    
    func forgotPassword(email: String) async throws -> Void {
                
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
    
    func activateAccount(token: String) async throws -> Void {
        let url = URL(string: Configuration.backendUrl + "/account/activate/\(token)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        let _ = try await downloader.http(request: request)
    }
    
    func resetPassword(token: String, password: String) async throws -> Void {
        let url = URL(string: Configuration.backendUrl + "/password/reset/\(token)")!
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        var requestBody = URLComponents()
        requestBody.queryItems = [
            URLQueryItem(name: "password", value: password)
        ]
        
        request.httpBody = requestBody.query?.data(using: .utf8)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let _ = try await downloader.http(request: request)
    }
    
    
    func register() async throws {
        
        struct RegisterDevice: Encodable {
            let deviceIdentifier: String
            let model: String
            let platform: String
            let osVersion: String
            let appVersion: String
        }
        
        let url = URL(string: Configuration.backendUrl + "device")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "PUT"
        
        let deviceId = Settings.deviceId()
        
        guard let encoded = try? await JSONEncoder().encode(
            RegisterDevice(
                deviceIdentifier: deviceId,
                model: UIDevice.modelName,
                platform: "ios",
                osVersion: UIDevice.current.systemVersion,
                appVersion: UIApplication.appVersion))
        else {
            preconditionFailure("Failed to encode RegisterDevice")
        }
        
        let _ = try await downloader.httpSend(request: request, data: encoded)
    }
}
