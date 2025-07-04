//
//  ServerModels.swift
//  Scrabble
//
//  Created by Eric Johns on 6/28/25.
//

import Foundation

enum GameState: String, Codable, CaseIterable {
    case pending, declined, waitingForMoves, completed, forfeited
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self).lowercased()
        
        if let match = GameState.allCases.first(where: { $0.rawValue.lowercased() == rawValue }) {
            self = match
        } else {
            print("Could not decode enum value: \(rawValue)")
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Could not decode enum value: \(rawValue)"))
        }
    }
}

struct CredentialsPayload: Codable {
    let username: String
    let password: String
}

struct TokensPayload: Decodable {
    let accessToken: String
    let refreshToken: String
}

struct GameCreationPayload: Codable {
    let boardIdentifier: BoardIdentifier
    let seed: UInt64
    let opponentUuid: String
}

struct GameMovePayload: Codable {
    let score: Int
    let wordsPlayed: Int
    let tilesPlayed: Int
    let movesMade: Int
    let serializedBoard: String?
}

struct Player: Decodable, Hashable, Identifiable {
    let id: UInt64
    let uuid: UUID
    let username: String
    let profilePicture: String?
    let createdDate: Date
    let updatedDate: Date
}

struct Game: Decodable {
    let id: UInt64
    let uuid: UUID
    let seed: UInt64
    let createdAt: Date
    let completedAt: Date?
    let updatedAt: Date
    let boardIdentifier: BoardIdentifier
    let gameState: GameState
    let initiatingPlayer: Player
    let opposingPlayer: Player
    let initiatingPlayerMove: GameMove?
    let opposingPlayerMove: GameMove?
    let winningPlayer: Player?
    let gameTied: Bool?
}

struct GameMove: Decodable {
    let id: UInt64
    let playerId: UInt64
    let gameId: UInt64
    let sentAt: Date
    let score: Int
    let wordsPlayed: Int
    let tilesPlayed: Int
    let movesMade: Int
    let serializedBoard: String?
}

extension Game {
    func isCompleted() -> Bool {
        return self.gameState == .completed || self.gameState == .forfeited || self.gameState == .declined
    }
    
    func isPending(player: Player) -> Bool {
        return self.gameState == .pending && self.opposingPlayer.id == player.id
    }
    
    func isCurrentPlayersTurn(player: Player) -> Bool {
        if (self.gameState == .pending) {
            return self.initiatingPlayer.id == player.id && self.initiatingPlayerMove == nil
        }
        
        return self.gameState == .waitingForMoves
            && ((self.initiatingPlayer.id == player.id && self.initiatingPlayerMove == nil)
                || (self.opposingPlayer.id == player.id && self.opposingPlayerMove == nil))
    }
    
    func isOtherPlayersTurn(player: Player) -> Bool {
        if (self.gameState == .pending) {
            return self.initiatingPlayer.id == player.id && self.initiatingPlayerMove != nil
        }
        
        return self.gameState == .waitingForMoves
            && ((self.initiatingPlayer.id == player.id && self.initiatingPlayerMove != nil && self.opposingPlayerMove == nil)
                || (self.opposingPlayer.id == player.id && self.opposingPlayerMove != nil && self.initiatingPlayerMove == nil))
    }
    
    func getOtherPlayer(currentPlayer: Player) -> Player {
        return self.initiatingPlayer.id == currentPlayer.id ? self.opposingPlayer : self.initiatingPlayer
    }
}
