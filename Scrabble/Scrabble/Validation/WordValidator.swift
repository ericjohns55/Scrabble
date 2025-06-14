//
//  WordValidator.swift
//  Scrabble
//
//  Created by Eric Johns on 6/7/25.
//

import SwiftUI

enum PlacementStatus {
    case valid, invalid, tooShort, none
    
    static func getColor(for status: PlacementStatus) -> Color {
        switch status {
            case .valid:
                return .green
            case .invalid:
                return .red
            default:
                return .blue
        }
    }
}

class WordValidator: ObservableObject {
    unowned let game: GameViewModel
    
    @Published var placementState: PlacementStatus = .none
    @Published var currentValidWords: String = ""
    @Published var currentInvalidWords: String = ""
    
    private var wordSet: Set<String> = []
    
    init(gameViewModel: GameViewModel) {
        self.game = gameViewModel
        
        print("Loading all words from resources...")
        
        if let wordSetPath = Bundle.main.path(forResource: "WordList", ofType: "txt") {
            if let fileContents = try? String(contentsOfFile: wordSetPath, encoding: .utf8) {
                wordSet = Set(fileContents.components(separatedBy: .newlines).filter { !$0.isEmpty })
            }
        }
        
        print("Loaded \(wordSet.count) words")
    }
        
    func updateTileState() {
        if (game.playerTiles.allSatisfy { $0.tileState == .inPlayerHand }) {
            updateTileState(.none)
            return
        }
        
        let placedTiles = game.playerTiles.filter { $0.tileState == .placedByPlayer }
        let allSameColumn = placedTiles.allSatisfy { $0.boardPosition?.col == placedTiles.first?.boardPosition?.col }
        let allSameRow = placedTiles.allSatisfy { $0.boardPosition?.row == placedTiles.first?.boardPosition?.row }
        
        // if they do not all share the same row or column then they must be invalid
        if (!allSameRow && !allSameColumn) {
            updateTileState(.invalid)
            return
        }
        
        var allCreatedWords: [Word] = []
        
        if (placedTiles.count != 1) {
            if (allSameRow) {
                // check consecutive rows
                print("Checking for vertical words in created row...")
                
                // find all words created vertically
                for placedTile in placedTiles.sorted(by: { $0.boardPosition!.col < $1.boardPosition!.col }) {
                    if let createdWord = game.boardViewModel.getWordVertical(placedTile.id) {
                        allCreatedWords.append(createdWord)
                    }
                }
                
                // find the word created horizontally (guaranteed to only have one)
                if let createdWord = game.boardViewModel.getWordHorizontal(placedTiles.first!.id) {
                    allCreatedWords.append(createdWord)
                } else {
                    print("Could not find horizontally created word")
                }
            }
            
            if (allSameColumn) {
                // check consecutive cols
                print("Checking for horizontal words in created column...")
                
                // find all words created horizontally
                for placedTile in placedTiles.sorted(by: { $0.boardPosition!.row < $1.boardPosition!.col }) {
                    if let createdWord = game.boardViewModel.getWordHorizontal(placedTile.id) {
                        allCreatedWords.append(createdWord)
                    }
                }
                
                if let createdWord = game.boardViewModel.getWordVertical(placedTiles.first!.id) {
                    allCreatedWords.append(createdWord)
                } else {
                    print("Could not find vertically created word")
                }
            }
        } else {
            let placedTileId = placedTiles.first!.id
            
            if let horizontalWord = game.boardViewModel.getWordHorizontal(placedTileId) {
                allCreatedWords.append(horizontalWord)
            }
            
            if let verticalWord = game.boardViewModel.getWordVertical(placedTileId) {
                allCreatedWords.append(verticalWord)
            }
        }
        
        if (allCreatedWords.count > 0) {
            // check word
            var validWords = Set<String>()
            var invalidWords = Set<String>()
            
            for createdWord in allCreatedWords {
                let calculatedWord = createdWord.getWord()
                
                if (wordSet.contains(calculatedWord)) {
                    validWords.insert(calculatedWord)
                } else {
                    invalidWords.insert(calculatedWord)
                }
            }
            
            let validStatus = invalidWords.count > 0 ? PlacementStatus.invalid : PlacementStatus.valid
            updateTileState(validStatus, validWords: validWords.joined(separator: ", "), invalidWords: invalidWords.joined(separator: ", "))
        } else {
            if (placedTiles.count == 1) {
                updateTileState(.tooShort)
            } else {
                updateTileState(.invalid)
            }
        }
    }
    
    private func updateTileState(_ placementStatus: PlacementStatus, validWords: String = "", invalidWords: String = "") {
        self.placementState = placementStatus
        self.currentValidWords = validWords
        self.currentInvalidWords = invalidWords
    }
}
