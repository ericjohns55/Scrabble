//
//  WordValidator.swift
//  Scrabble
//
//  Created by Eric Johns on 6/7/25.
//

import SwiftUI

enum PlacementStatus {
    case valid, invalid, tooShort, none, centerTileEmpty, notConnected, notConsecutive
    
    static func getColor(for status: PlacementStatus) -> Color {
        switch status {
            case .valid:
                return .green
            case .none:
                return .white
            default:
                return .red
        }
    }
    
    static func getMessage(for status: PlacementStatus) -> String {
        switch status {
            case .valid:
                return "All words are valid"
            case .invalid:
                return "Some words are invalid"
            case .tooShort:
                return "Word is too short"
            case .none:
                return "No tiles are on the board"
            case .centerTileEmpty:
                return "Center tile must be filled"
            case .notConnected:
                return "Tiles are not connected"
            case .notConsecutive:
                return "Tiles cannot have gaps"
        }
    }
}

class WordValidator: ObservableObject {
    let boardState: BoardState
    let game: GameViewModel
    let wordSet: Set<String>
    
    init(gameViewModel: GameViewModel, boardState: BoardState, wordSet: Set<String>) {
        self.game = gameViewModel
        self.boardState = boardState
        self.wordSet = wordSet
    }
        
    func updateTileState() {
        if (game.playerTiles.allSatisfy { $0.tileState == .inPlayerHand }) {
            boardState.updateTileState(.none)
            return
        }
        
        let placedTiles = game.playerTiles.filter { $0.tileState == .placedByPlayer }
        let allSameColumn = placedTiles.allSatisfy { $0.boardPosition?.col == placedTiles.first?.boardPosition?.col }
        let allSameRow = placedTiles.allSatisfy { $0.boardPosition?.row == placedTiles.first?.boardPosition?.row }
        
        // if they do not all share the same row or column then they must be invalid
        if (!allSameRow && !allSameColumn) {
            boardState.updateTileState(.invalid)
            return
        }
        
        if (!game.boardManager.isCenterTileFilled()) {
            boardState.updateTileState(.centerTileEmpty)
            return
        }
        
        var allCreatedWords: [Word] = []
        
        if (placedTiles.count != 1) {
            if (allSameRow) {
                let placedTilesSorted = placedTiles.sorted(by: { $0.boardPosition!.col < $1.boardPosition!.col })
                
                if (!game.boardManager.arePlacedTilesConsecutive(placedTilesSorted, wordOrientation: .horizontal)) {
                    boardState.updateTileState(.notConsecutive)
                    return
                }
                
                // find all words created vertically
                for placedTile in placedTilesSorted {
                    if let createdWord = game.boardManager.getWordVertical(placedTile.id) {
                        allCreatedWords.append(createdWord)
                    }
                }
                
                // find the word created horizontally (guaranteed to only have one)
                if let createdWord = game.boardManager.getWordHorizontal(placedTilesSorted.first!.id) {
                    allCreatedWords.append(createdWord)
                }
            }
            
            if (allSameColumn) {
                let placedTilesSorted = placedTiles.sorted(by: { $0.boardPosition!.row < $1.boardPosition!.row })
                
                if (!game.boardManager.arePlacedTilesConsecutive(placedTilesSorted, wordOrientation: .vertical)) {
                    boardState.updateTileState(.notConsecutive)
                    return
                }
                
                // find all words created horizontally
                for placedTile in placedTilesSorted {
                    if let createdWord = game.boardManager.getWordHorizontal(placedTile.id) {
                        allCreatedWords.append(createdWord)
                    }
                }
                
                if let createdWord = game.boardManager.getWordVertical(placedTiles.first!.id) {
                    allCreatedWords.append(createdWord)
                }
            }
        } else {
            let placedTileId = placedTiles.first!.id
            
            if let horizontalWord = game.boardManager.getWordHorizontal(placedTileId) {
                allCreatedWords.append(horizontalWord)
            }
            
            if let verticalWord = game.boardManager.getWordVertical(placedTileId) {
                allCreatedWords.append(verticalWord)
            }
        }
        
        if (allCreatedWords.count > 0) {
            // check word
            var validWords = Set<Word>()
            var invalidWords = Set<Word>()
            
            for createdWord in allCreatedWords {
                // lowercased because the WordList resource is in lowercase
                if (wordSet.contains(createdWord.getWord().lowercased())) {
                    validWords.insert(createdWord)
                } else {
                    invalidWords.insert(createdWord)
                }
            }
            
            var updatedState: PlacementStatus = .invalid
            var points: Int = 0
            
            // if the board has committed tiles and we are not connected to them, the state is invalid
            if (game.boardManager.hasCommittedTiles() && !allCreatedWords.contains(where: { $0.connectedToExistingTiles() })) {
                updatedState = .notConnected
            } else if (invalidWords.count == 0) {
                updatedState = .valid
                
                if (validWords.count > 0) {
                    points = validWords.map { $0.getPoints() }.reduce(0, +)
                }
            }
            
            boardState.updateTileState(updatedState, validWords: validWords, invalidWords: invalidWords, points: points)
        } else {
            if (placedTiles.count == 1) {
                boardState.updateTileState(.tooShort)
            } else {
                boardState.updateTileState(.invalid)
            }
        }
    }
}
