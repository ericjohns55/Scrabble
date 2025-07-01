//
//  ServerModels.swift
//  Scrabble
//
//  Created by Eric Johns on 6/28/25.
//

import Foundation

enum GameState: Decodable {
    case pending, declined, waitingForMoves, completed, forfeitted
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

struct Player: Decodable {
    let id: UInt64
    let uuid: UUID
    let username: String
    let profilePicture: String?
    let createdDate: Date
    let updatedDate: Date
}

struct Game: Decodable {
    let id: UInt64
    let uuid: String
    let seed: UInt64
    let createdAt: Date
    let completedAt: Date
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
