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
    unowned let game: GameViewModel
    
    @Published var wordCount: Int = 0
    @Published var currentPoints: Int = 0
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
        
        if (!game.boardViewModel.isCenterTileFilled()) {
            updateTileState(.centerTileEmpty)
            return
        }
        
        var allCreatedWords: [Word] = []
        
        if (placedTiles.count != 1) {
            if (allSameRow) {
                // check consecutive rows
                print("Checking for vertical words in created row...")
                
                let placedTilesSorted = placedTiles.sorted(by: { $0.boardPosition!.col < $1.boardPosition!.col })
                
                if (!game.boardViewModel.arePlacedTilesConsecutive(placedTilesSorted, wordOrientation: .horizontal)) {
                    updateTileState(.notConsecutive)
                    return
                }
                
                // find all words created vertically
                for placedTile in placedTilesSorted {
                    if let createdWord = game.boardViewModel.getWordVertical(placedTile.id) {
                        allCreatedWords.append(createdWord)
                    }
                }
                
                // find the word created horizontally (guaranteed to only have one)
                if let createdWord = game.boardViewModel.getWordHorizontal(placedTilesSorted.first!.id) {
                    allCreatedWords.append(createdWord)
                } else {
                    print("Could not find horizontally created word")
                }
            }
            
            if (allSameColumn) {
                // check consecutive cols
                print("Checking for horizontal words in created column...")
                
                let placedTilesSorted = placedTiles.sorted(by: { $0.boardPosition!.row < $1.boardPosition!.row })
                
                if (!game.boardViewModel.arePlacedTilesConsecutive(placedTilesSorted, wordOrientation: .vertical)) {
                    updateTileState(.notConsecutive)
                    return
                }
                
                // find all words created horizontally
                for placedTile in placedTilesSorted {
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
            if (game.boardViewModel.hasCommittedTiles() && !allCreatedWords.contains(where: { $0.connectedToExistingTiles() })) {
                updatedState = .notConnected
            } else if (invalidWords.count == 0) {
                updatedState = .valid
                
                if (validWords.count > 0) {
                    points = validWords.map { $0.getPoints() }.reduce(0, +)
                }
            }
            
            updateTileState(updatedState, validWords: validWords, invalidWords: invalidWords, points: points)
        } else {
            if (placedTiles.count == 1) {
                updateTileState(.tooShort)
            } else {
                updateTileState(.invalid)
            }
        }
    }
    
    private func updateTileState(_ placementStatus: PlacementStatus, validWords: Set<Word>? = nil, invalidWords: Set<Word>? = nil, points: Int = 0) {
        self.placementState = placementStatus
        self.currentPoints = points
        
        if (validWords != nil && invalidWords != nil) {
            self.currentValidWords = validWords!.map { "\($0)"}.joined(separator: ", ")
            self.currentInvalidWords = invalidWords!.map { "\($0)"}.joined(separator: ", ")
            self.wordCount = validWords!.count + invalidWords!.count
        } else {
            self.currentValidWords = ""
            self.currentInvalidWords = ""
            self.wordCount = 0
        }
    }
}
