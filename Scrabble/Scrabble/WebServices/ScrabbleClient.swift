//
//  ScrabbleClient.swift
//  Scrabble
//
//  Created by Eric Johns on 6/28/25.
//

class ScrabbleClient {
    private let httpClient: BaseWebClient
    private var authenticated: Bool = false
    
    private var currentUser: Player? = nil
    
    init(serverUrl: String) {
        httpClient = BaseWebClient(serverUrl: serverUrl, authToken: nil, refreshToken: nil)
    }
    
    init(serverUrl: String, refreshToken: String) {
        httpClient = BaseWebClient(serverUrl: serverUrl, authToken: nil, refreshToken: refreshToken)
    }
    
    public func getUser() -> Player? {
        return currentUser
    }
    
    var authToken: String? {
        httpClient.getAuthToken()
    }
    
    public func isNameTaken() async throws -> Bool {
        guard let response: ResponseEnvelope<Bool> = try? await httpClient.getRequest(route: "authentication/name-taken", authToken: nil) else {
            return true
        }
        
        return response.data
    }
    
    public func register(username: String, password: String) async throws -> Player? {
        let postBody = CredentialsPayload(username: username, password: password)
        
        guard let response: ResponseEnvelope<Player> = try? await httpClient.postRequest(route: "authentication/register", authToken: nil, body: postBody) else {
            return nil
        }
        
        return response.data
    }
    
    public func login(username: String, password: String) async throws {
        let postBody = CredentialsPayload(username: username, password: password)
        
        guard let response: ResponseEnvelope<TokensPayload> = try? await httpClient.postRequest(route: "authentication/login", authToken: nil, body: postBody) else {
            authenticated = false
            httpClient.updateTokens(authToken: nil, refreshToken: nil)
            updateSavedTokens(tokensPayload: nil)
            return
        }
        
        httpClient.updateTokens(authToken: response.data.accessToken, refreshToken: response.data.refreshToken)
        updateSavedTokens(tokensPayload: response.data)
    }
    
    public func refreshTokens() async throws {
        guard let response: ResponseEnvelope<TokensPayload> = try? await httpClient.postRequest(route: "authentication/refresh", authToken: httpClient.getRefreshToken(), body: nil) else {
            authenticated = false
            return
        }
        
        httpClient.updateTokens(authToken: response.data.accessToken, refreshToken: response.data.refreshToken)
        updateSavedTokens(tokensPayload: response.data)
    }
    
    public func getSelf() async throws -> Player? {
        guard let response: ResponseEnvelope<Player> = try? await httpClient.getRequest(route: "players/self", authToken: authToken) else {
            currentUser = nil
            return nil
        }
        
        currentUser = response.data
        return currentUser
    }
    
    public func getPlayers(includeSelf: Bool = false) async throws -> [Player] {
        let route = "players?includeSelf=\(String(describing: includeSelf))"
        
        guard let response: ResponseEnvelope<[Player]> = try? await httpClient.getRequest(route: route, authToken: authToken) else {
            currentUser = nil
            return []
        }
        
        return response.data
    }
    
    public func getPlayer(playerId: String) async throws -> Player? {
        let route = "players/\(playerId)"
        
        guard let response: ResponseEnvelope<Player> = try? await httpClient.getRequest(route: route, authToken: authToken) else {
            return nil
        }
        
        return response.data
    }
    
    public func getGames() async throws -> [Game] {
        guard let response: ResponseEnvelope<[Game]> = try? await httpClient.getRequest(route: "games", authToken: httpClient.getAuthToken()) else {
            return []
        }
        
        return response.data
    }
    
    public func createGame(creationPayload: GameCreationPayload) async throws -> Game? {
        guard let response: ResponseEnvelope<Game> = try? await httpClient.postRequest(route: "games/create", authToken: authToken, body: creationPayload) else {
            return nil
        }
        
        return response.data
    }
    
    public func getGame(gameId: String) async throws -> Game? {
        let route = "games/\(gameId)"
        
        guard let response: ResponseEnvelope<Game> = try? await httpClient.getRequest(route: route, authToken: authToken) else {
            return nil
        }
        
        return response.data
    }
    
    public func submitMove(gameId: String, gameMovePayload: GameMovePayload) async throws -> Game? {
        let route = "games/\(gameId)/submit"
        
        guard let response: ResponseEnvelope<Game> = try? await httpClient.postRequest(route: route, authToken: authToken, body: gameMovePayload) else {
            return nil
        }
        
        return response.data
    }
    
    public func declineGame(gameId: String) async throws -> Game? {
        let route = "games/\(gameId)/decline"
        
        guard let response: ResponseEnvelope<Game> = try? await httpClient.postRequest(route: route, authToken: authToken, body: nil) else {
            return nil
        }
        
        return response.data
    }
    
    public func acceptGame(gameId: String) async throws -> Game? {
        let route = "games/\(gameId)/accept"
        
        guard let response: ResponseEnvelope<Game> = try? await httpClient.postRequest(route: route, authToken: authToken, body: nil) else {
            return nil
        }
        
        return response.data
    }
    
    public func forfeitGame(gameId: String) async throws -> Game? {
        let route = "games/\(gameId)/forfeit"
        
        guard let response: ResponseEnvelope<Game> = try? await httpClient.postRequest(route: route, authToken: authToken, body: nil) else {
            return nil
        }
        
        return response.data
    }
    
    private func updateSavedTokens(tokensPayload: TokensPayload?) {
        // TODO
    }
}
