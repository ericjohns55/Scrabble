//
//  ScrabbleClient.swift
//  Scrabble
//
//  Created by Eric Johns on 6/28/25.
//

import Foundation

struct ServerResponse<T> {
    let data: Optional<T>
    let errorMessage: String
}

class ScrabbleClient {
    private let httpClient: BaseWebClient
    private var authenticated: Bool = false
    
    init(serverUrl: String) {
        httpClient = BaseWebClient(serverUrl: serverUrl, authToken: nil, refreshToken: nil)
    }
    
    init(serverUrl: String, refreshToken: String) {
        httpClient = BaseWebClient(serverUrl: serverUrl, authToken: nil, refreshToken: refreshToken)
    }
    
    var authToken: String? {
        httpClient.getAuthToken()
    }
    
    public func pingServer() async -> Bool {
        return await httpClient.pingServer(route: "health")
    }
    
    public func getSelf() async -> ServerResponse<Player> {
        let serverResponse: ServerResponse<Player> = await executeWithServerResponse(
            request: {
                try await self.httpClient.getRequest(route: "players/self", authToken: self.httpClient.getAuthToken())
            }
        )
        
        return serverResponse
    }
    
    public func getPlayers(includeSelf: Bool = false) async -> ServerResponse<[Player]> {
        let route = "players?includeSelf=\(String(describing: includeSelf))"
        
        let serverResponse: ServerResponse<[Player]> = await executeWithServerResponse(
            request: {
                try await self.httpClient.getRequest(route: route, authToken: self.httpClient.getAuthToken())
            }
        )
        
        return serverResponse
    }
    
    public func getPlayer(playerId: String) async -> ServerResponse<Player?> {
        let route = "players/\(playerId)"
        
        let serverResponse: ServerResponse<Player?> = await executeWithServerResponse(
            request: {
                try await self.httpClient.getRequest(route: route, authToken: self.authToken)
            }
        )
        
        return serverResponse
    }
    
    public func getGames() async -> ServerResponse<[Game]> {
        let serverResponse: ServerResponse<[Game]> = await executeWithServerResponse(
            request: {
                try await self.httpClient.getRequest(route: "games", authToken: self.httpClient.getAuthToken())
            }
        )
        
        return serverResponse
    }
    
    public func createGame(creationPayload: GameCreationPayload) async -> ServerResponse<Game?> {
        let serverResponse: ServerResponse<Game?> = await executeWithServerResponse(
            request: {
                try await self.httpClient.postRequest(route: "games/create", authToken: self.authToken, body: creationPayload)
            }
        )
        
        return serverResponse
    }
    
    public func getGame(gameId: String) async -> ServerResponse<Game?> {
        let route = "games/\(gameId)"
        
        let serverResponse: ServerResponse<Game?> = await executeWithServerResponse(
            request: {
                try await self.httpClient.getRequest(route: route, authToken: self.authToken)
            }
        )
        
        return serverResponse
    }
    
    public func submitMove(gameId: String, gameMovePayload: GameMovePayload) async -> ServerResponse<Game?> {
        let route = "games/\(gameId)/submit"
        
        let serverResponse: ServerResponse<Game?> = await executeWithServerResponse(
            request: {
                try await self.httpClient.postRequest(route: route, authToken: self.authToken, body: gameMovePayload)
            }
        )
        
        return serverResponse
    }
    
    public func declineGame(gameId: String) async -> ServerResponse<Game?> {
        let route = "games/\(gameId)/decline"
        
        let serverResponse: ServerResponse<Game?> = await executeWithServerResponse(
            request: {
                try await self.httpClient.postRequest(route: route, authToken: self.authToken, body: nil)
            }
        )
        
        return serverResponse
    }
    
    public func acceptGame(gameId: String) async -> ServerResponse<Game?> {
        let route = "games/\(gameId)/accept"
        
        let serverResponse: ServerResponse<Game?> = await executeWithServerResponse(
            request: {
                try await self.httpClient.postRequest(route: route, authToken: self.authToken, body: nil)
            }
        )
        
        return serverResponse
    }
    
    public func forfeitGame(gameId: String) async -> ServerResponse<Game?> {
        let route = "games/\(gameId)/forfeit"
        
        let serverResponse: ServerResponse<Game?> = await executeWithServerResponse(
            request: {
                try await self.httpClient.postRequest(route: route, authToken: self.authToken, body: nil)
            }
        )
        
        return serverResponse
    }
    
    public func isNameTaken() async -> ServerResponse<Bool> {
        let serverResponse: ServerResponse<Bool> = await executeWithServerResponse(
            request: {
                try await self.httpClient.getRequest(route: "authentication/name-taken", authToken: nil)
            }
        )
        
        return serverResponse
    }
    
    public func register(username: String, password: String) async -> ServerResponse<TokensPayload> {
        let postBody = CredentialsPayload(username: username, password: password)
        
        let tokensResponse: ServerResponse<TokensPayload> = await queryAndSaveTokens(tokensRequest: {
            try await self.httpClient.postRequest(route: "authentication/register", authToken: nil, body: postBody)!
        })
        
        return tokensResponse
    }
    
    public func login(username: String, password: String) async -> Bool {
        let postBody = CredentialsPayload(username: username, password: password)
        
        let response: ServerResponse<TokensPayload> = await queryAndSaveTokens(tokensRequest: {
            try await self.httpClient.postRequest(route: "authentication/login", authToken: nil, body: postBody)
        })
        
        return response.data != nil
    }
    
    public func refreshTokens() async -> Bool {
        let response: ServerResponse<TokensPayload> = await queryAndSaveTokens(tokensRequest: {
            try await self.httpClient.postRequest(route: "authentication/refresh", authToken: self.httpClient.getRefreshToken(), body: nil)
        })
        
        return response.data != nil
    }
    
    private func queryAndSaveTokens(tokensRequest: @escaping () async throws -> TokensPayload?) async -> ServerResponse<TokensPayload> {
        let serverResponse: ServerResponse<TokensPayload> = await executeWithServerResponse(
            request: {
               try await tokensRequest()
            },
            successFunction: { response in
                self.httpClient.updateTokens(authToken: response.accessToken, refreshToken: response.refreshToken)
                self.updateSavedTokens(tokensPayload: response)
                self.authenticated = true
            },
            failureFunction: { error in
                self.removeCredentials()
            }
        )
        
        return serverResponse
    }
    
    public func removeCredentials() {
        self.httpClient.updateTokens(authToken: nil, refreshToken: nil)
        self.updateSavedTokens(tokensPayload: nil)
        self.authenticated = false
    }
    
    private func executeWithServerResponse<T: Decodable>(request: @escaping () async throws -> T?, successFunction: ((T) -> Void)? = nil, failureFunction: ((ErrorResponse) -> Void)? = nil) async -> ServerResponse<T> {
        var data: T? = nil
        var errorMessage: String = ""
        
        do {
            if let response: T = try await request() as T? {
                successFunction?(response)
                data = response
            } else {
                errorMessage = "Could not decode response envelope"
            }
        } catch let nsError as NSError {
            if let errorEnvelope = nsError.userInfo["error"] as? ErrorResponse {
                failureFunction?(errorEnvelope)
                
                errorMessage = errorEnvelope.message
            } else {
                errorMessage = "Could not decode ErrorEnvelope from exception"
            }
        } catch {
            errorMessage = "An unknown error has occurred on the client"
            print("[ScrabbleClient] An error has occurred: \(error)")
        }
        
        return ServerResponse(data: data, errorMessage: errorMessage)
    }
    
    private func updateSavedTokens(tokensPayload: TokensPayload?) {
        print("TODO - save refresh token")
        // TODO
    }
}
