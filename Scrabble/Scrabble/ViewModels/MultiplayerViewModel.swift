//
//  MultiplayerViewModel.swift
//  Scrabble
//
//  Created by Eric Johns on 7/3/25.
//

import SwiftUI

@MainActor
class MultiplayerViewModel: ObservableObject {
    private var scrabbleClient: ScrabbleClient?
    private var currentPlayer: Player
    
    private var allGames: [Game] = []
    @Published var pendingGames: [Game] = []
    @Published var currentPlayersTurn: [Game] = []
    @Published var otherPlayersTurn: [Game] = []
    @Published var completedGames: [Game] = []
    
    @Published var allPlayers: [Player] = []
    
    init() {
        self.scrabbleClient = nil
        self.currentPlayer = Player(id: 0, uuid: UUID.init(), username: "EMPTY", profilePicture: nil, createdDate: Date(), updatedDate: Date())
    }
    
    init(scrabbleClient: ScrabbleClient, currentPlayer: Player) {
        self.scrabbleClient = scrabbleClient
        self.currentPlayer = currentPlayer
    }
    
    func loadMultiplayerMenuData() async {
        await fetchPlayers()
        await fetchGames()
    }
    
    func fetchPlayers() async {
        let serverResponse = await scrabbleClient?.getPlayers(includeSelf: false)
        
        if let playerData = serverResponse?.data {
            allPlayers = playerData
        }
    }
    
    func getPlayer(_ playerUuid: UUID?) -> Player? {
        return self.allPlayers.first(where: { $0.uuid == playerUuid })
    }
    
    func fetchGames() async {
        let serverResponse = await scrabbleClient?.getGames()
        
        if let gameData = serverResponse?.data {
            allGames = gameData
            
            completedGames = allGames.filter { $0.isCompleted() }
            pendingGames = allGames.filter { $0.isPending(player: currentPlayer) }
            currentPlayersTurn = allGames.filter { $0.isCurrentPlayersTurn(player: currentPlayer) }
            otherPlayersTurn = allGames.filter { $0.isOtherPlayersTurn(player: currentPlayer) }
        }
    }
    
    func createGame(opponentUuid: UUID, board: BoardIdentifier) async -> Bool {
        let generatedSeed: UInt64 = UInt64.random(in: 0..<UInt64.max)
        let newGamePayload = GameCreationPayload(boardIdentifier: board, seed: generatedSeed, opponentUuid: opponentUuid.uuidString)
        
        let serverResponse = await scrabbleClient?.createGame(creationPayload: newGamePayload)
        
        return serverResponse?.data != nil
    }
    
    func getStatusTextForGame(game: Game) -> String {
        let comparisonLambda = { $0.uuid == game.uuid } as (Game) -> Bool
        var gameStateMessage = "State unknown"
        
        if (pendingGames.contains(where: comparisonLambda)) {
            gameStateMessage = "\(game.getOtherPlayer(currentPlayer: currentPlayer).username) invited you"
        } else if (currentPlayersTurn.contains(where: comparisonLambda)) {
            gameStateMessage = "Play your turn"
        } else if (otherPlayersTurn.contains(where: comparisonLambda)) {
            gameStateMessage = "Waiting for opponent"
        } else if (completedGames.contains(where: comparisonLambda)) {
            if (game.gameState == .declined) {
                gameStateMessage = "\(game.opposingPlayer.username) declined"
            } else if (game.gameState == .forfeited) {
                let forfeitingPlayer = game.getOtherPlayer(currentPlayer: game.winningPlayer!)
                gameStateMessage = "\(forfeitingPlayer.username) forfeited"
            } else if (game.winningPlayer != nil) {
                gameStateMessage = "\(game.winningPlayer!.username) won!"
            } else if (game.gameTied != nil) {
                gameStateMessage = "Game was tied!"
            } else {
                gameStateMessage = "Unknown completed state"
            }
        }
        
        let otherPlayerName = game.getOtherPlayer(currentPlayer: currentPlayer).username
        
        if (gameStateMessage.contains(currentPlayer.username)) {
            gameStateMessage = gameStateMessage.replacing(currentPlayer.username, with: "You")
        } else if (gameStateMessage.contains(otherPlayerName)) {
            gameStateMessage = gameStateMessage.replacing(otherPlayerName, with: "They")
        }
        
        return gameStateMessage
    }
}
