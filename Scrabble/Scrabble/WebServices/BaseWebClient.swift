//
//  HTTPClient.swift
//  Scrabble
//
//  Created by Eric Johns on 6/28/25.
//

import UIKit
import Foundation
import AsyncHTTPClient

struct ResponseEnvelope<T: Decodable>: Decodable {
    let data: T
    let elapsedMilliseconds: Int
}

struct ErrorResponse: Decodable {
    let statusCode: Int
    let identifier: String
    let route: String
    let message: String
    let details: String
}

class BaseWebClient {
    private var _serverUrl: String
    private var _bearerToken: String?
    private var _refreshToken: String?
    
    private let jsonDecoder = JSONDecoder()
    
    init(serverUrl: String, authToken: String?, refreshToken: String?) {
        _serverUrl = serverUrl
        _bearerToken = authToken
        _refreshToken = refreshToken
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
    }
    
    func updateTokens(tokensPayload: TokensPayload?) {
        _bearerToken = tokensPayload?.accessToken
        _refreshToken = tokensPayload?.refreshToken
    }
    
    func getAuthToken() -> String? {
        return _bearerToken
    }
    
    func getRefreshToken() -> String? {
        return _refreshToken
    }
    
    func getRequest<T: Decodable>(route: String, authToken: String?) async throws -> T? {
        return try await requestNoBody(route: route, authToken: authToken)
    }
    
    func deleteRequest<T: Decodable>(route: String, authToken: String?) async throws -> T? {
        return try await requestNoBody(route: route, authToken: authToken, getRequest: false)
    }
    
    func postRequest<T: Decodable>(route: String, authToken: String?, body: Codable?) async throws -> T? {
        return try await requestWithBody(route: route, body: body, authToken: authToken)
    }
        
    func putRequest<T: Decodable>(route: String, authToken: String?, body: Codable?) async throws -> T? {
        return try await requestWithBody(route: route, body: body, authToken: authToken, postRequest: false)
    }
    
    func pingServer(route: String) async -> Bool {
        let httpClient = HTTPClient(eventLoopGroupProvider: .singleton)
        
        defer {
            Task {
                try await httpClient.shutdown()
            }
        }
        
        do {
            var request = HTTPClientRequest(url: "\(_serverUrl)\(route)")
            request.method = .GET
            
            logRequest(request: request)
            
            let httpResponse = try await httpClient.execute(request, timeout: .seconds(3))
            let isOnline = (200...299).contains(httpResponse.status.code)
            
            logSuccessfulResponse(response: httpResponse, responseObject: isOnline ? "HEALTHY" : "UNHEALTHY")
            
            return isOnline
        } catch {
            print("Server was either offline or unhealthy")
            return false
        }
    }
    
    private func requestNoBody<T: Decodable>(route: String, authToken: String?, getRequest: Bool = true) async throws -> T? {
        let httpClient = HTTPClient(eventLoopGroupProvider: .singleton)
        var response: T?
        
        defer {
            Task {
                try await httpClient.shutdown()
            }
        }
        
        do {
            var request = HTTPClientRequest(url: "\(_serverUrl)\(route)")
            request.method = getRequest ? .GET : .DELETE
            request.headers.add(contentsOf: ["Content-Type": "application/json"])
            request.headers.add(contentsOf: ["User-Agent": "swift-app"])
            
            if let bearerToken = authToken {
                request.headers.add(contentsOf: ["Authorization": "Bearer \(bearerToken)"])
            }
            
            logRequest(request: request)
            
            let httpResponse = try await httpClient.execute(request, timeout: .seconds(3))
            let responseBody = try await httpResponse.body.collect(upTo: 1024 * 1024)
            
            if (200...299).contains(httpResponse.status.code) {
                do {
                    let responseEnvelope: ResponseEnvelope<T> = try jsonDecoder.decode(ResponseEnvelope<T>.self, from: responseBody)
                    response = responseEnvelope.data
                    
                    logSuccessfulResponse(response: httpResponse, responseObject: String(describing: T.self))
                } catch {
                    print("Could not deserialize payload: \(error)")
                    throw error
                }
            } else {
                let errorResponse = try jsonDecoder.decode(ErrorResponse.self, from: responseBody)
                logFailedResponse(response: httpResponse, errorEnvelope: errorResponse)
                throw NSError(domain: "Server Error", code: Int(httpResponse.status.code), userInfo: ["error": errorResponse])
            }
        } catch {
            throw error
        }
        
        return response
    }
    
    private func requestWithBody<T: Decodable>(route: String, body: Codable?, authToken: String?, postRequest: Bool = true) async throws -> T? {
        let httpClient = HTTPClient(eventLoopGroupProvider: .singleton)
        var response: T?
        
        defer {
            Task {
                try await httpClient.shutdown()
            }
        }
        
        do {
            var request = HTTPClientRequest(url: "\(_serverUrl)\(route)")
            request.method = postRequest ? .POST : .PUT
            request.headers.add(contentsOf: ["Content-Type": "application/json"])
            request.headers.add(contentsOf: ["User-Agent": "swift-app"])
            
            if let bearerToken = authToken {
                request.headers.add(contentsOf: ["Authorization": "Bearer \(bearerToken)"])
            }
            
            logRequest(request: request, body: body)
            
            if (body != nil) {
                let jsonData = try JSONEncoder().encode(body!)
                request.body = .bytes(jsonData)
            }
            
            let httpResponse = try await httpClient.execute(request, timeout: .seconds(3))
            let responseBody = try await httpResponse.body.collect(upTo: 1024 * 1024)
                        
            if (200...299).contains(httpResponse.status.code) {
                do {
                    let responseEnvelope: ResponseEnvelope<T> = try jsonDecoder.decode(ResponseEnvelope<T>.self, from: responseBody)
                    response = responseEnvelope.data
                    
                    logSuccessfulResponse(response: httpResponse, responseObject: String(describing: T.self))
                } catch {
                    print("Could not deserialize payload: \(error)")
                    throw error
                }
            } else {
                let errorResponse = try jsonDecoder.decode(ErrorResponse.self, from: responseBody)
                logFailedResponse(response: httpResponse, errorEnvelope: errorResponse)
                throw NSError(domain: "Server Error", code: Int(httpResponse.status.code), userInfo: ["error": errorResponse])
            }
        } catch {
            throw error
        }
        
        return response
    }
    
    private func logRequest(request: HTTPClientRequest, body: Codable? = nil) {
        let isAuthed = request.headers.contains(name: "Authorization")
        
        let header = isAuthed ? "[REQUEST - AUTHED]" : "[REQUEST - NO AUTH]"
        let method = String(describing: request.method)
        
        let bodyType = body != nil ? " (\(String(describing: type(of: body!))))" : ""
        
        print("\(header) \(method)\(bodyType) - \(request.url)")
    }
    
    private func logSuccessfulResponse(response: HTTPClientResponse, responseObject: String) {
        print("[RESPONSE] \(response.status.code): \(responseObject) - \(response.url!)")
    }
    
    private func logFailedResponse(response: HTTPClientResponse, errorEnvelope: ErrorResponse) {
        print("[RESPONSE] \(response.status.code) - \(errorEnvelope.message)")
    }
}
