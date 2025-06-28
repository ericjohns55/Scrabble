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
    
    init (serverUrl: String, authToken: String?, refreshToken: String?) {
        _serverUrl = serverUrl
        _bearerToken = authToken
        _refreshToken = refreshToken
    }
    
    func updateTokens(authToken: String?, refreshToken: String?) {
        _bearerToken = authToken
        _refreshToken = refreshToken
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
            
            if let bearerToken = authToken {
                request.headers.add(contentsOf: ["Authorization": "Bearer \(bearerToken)"])
            }
            
            print("[REQUEST] \(String(describing: request.method).uppercased()) - \(route)")
            
            let httpResponse = try await httpClient.execute(request, timeout: .seconds(3))
            let responseBody = try await httpResponse.body.collect(upTo: 1024 * 1024)
            
            if (200...299).contains(httpResponse.status.code) {
                response = try JSONDecoder().decode(T.self, from: responseBody)
                print("[RESPONSE] \(httpResponse.status.code) - returning \(T.self)")
            } else {
                let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: responseBody)
                print("[RESPONSE] \(httpResponse.status.code) - \(errorResponse.message)")
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
            
            if let bearerToken = authToken {
                request.headers.add(contentsOf: ["Authorization": "Bearer \(bearerToken)"])
            }
            
            print("[REQUEST] \(String(describing: request.method).uppercased()) - \(route)")
            
            if (body != nil) {
                let jsonData = try JSONEncoder().encode(body!)
                request.body = .bytes(jsonData)
            }
            
            let httpResponse = try await httpClient.execute(request, timeout: .seconds(3))
            let responseBody = try await httpResponse.body.collect(upTo: 1024 * 1024)
            
            if (200...299).contains(httpResponse.status.code) {
                response = try JSONDecoder().decode(T.self, from: responseBody)
                print("[RESPONSE] \(httpResponse.status.code) - returning \(T.self)")
            } else {
                let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: responseBody)
                print("[RESPONSE] \(httpResponse.status.code) - \(errorResponse.message)")
                throw NSError(domain: "Server Error", code: Int(httpResponse.status.code), userInfo: ["error": errorResponse])
            }
        } catch {
            throw error
        }
        
        return response
    }
}
