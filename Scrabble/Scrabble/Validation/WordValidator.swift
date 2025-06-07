//
//  WordValidator.swift
//  Scrabble
//
//  Created by Eric Johns on 6/7/25.
//

import SwiftUI

class WordValidator: ObservableObject {
    unowned let game: GameViewModel
    
    @Published var tilePlacementValid: Bool = true
    @Published var currentWord: String = ""
    
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
        
    func validateTilePlacement() -> Bool {
        if (game.playerTiles.allSatisfy { $0.tileState == .inPlayerHand }) {
            tilePlacementValid = true
            return true
        }
        
        let tilesToConsider = game.playerTiles.filter { $0.tileState == .placedByPlayer }
        let allSameColumn = tilesToConsider.allSatisfy { $0.boardPosition?.col == tilesToConsider.first?.boardPosition?.col }
        let allSameRow = tilesToConsider.allSatisfy { $0.boardPosition?.row == tilesToConsider.first?.boardPosition?.row }
        
        // if they do not all share the same row or column then they must be invalid
        if (!allSameRow && !allSameColumn) {
            tilePlacementValid = false
            return false
        }
        
        var mappedPositions: [Int] = []
        if (allSameRow) {
            // check consecutive rows
            mappedPositions = tilesToConsider.map { $0.boardPosition!.col }.sorted()
        } else {
            // check consecutive cols
            mappedPositions = tilesToConsider.map { $0.boardPosition!.row }.sorted()
        }
        
        let areConsecutive: Bool = zip(mappedPositions, mappedPositions.dropFirst()).allSatisfy { $1 == $0 + 1 }
        
        var isValidWord = false
        if (areConsecutive) {
            // check word
            var wordBuilder = ""
            
            for i in 0..<mappedPositions.count {
                if (allSameRow) {
                    wordBuilder += tilesToConsider.first(where: { $0.boardPosition!.col == mappedPositions[i] })!.letter
                } else {
                    wordBuilder += tilesToConsider.first(where: { $0.boardPosition!.row == mappedPositions[i] })!.letter
                }
            }
            
            currentWord = wordBuilder.uppercased()
            isValidWord = wordSet.contains(currentWord)
        }
        
        tilePlacementValid = areConsecutive && isValidWord
        return tilePlacementValid
    }
}
