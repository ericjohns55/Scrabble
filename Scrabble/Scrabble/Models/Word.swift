//
//  Word.swift
//  Scrabble
//
//  Created by Eric Johns on 6/14/25.
//

import Foundation

enum WordOrientation {
    case horizontal, vertical
}

class Word: CustomStringConvertible, Hashable, Equatable, Identifiable {
    public let id = UUID()
    
    private var boardSquares: [BoardSquare]
    private var wordOrientation: WordOrientation
    private var points: Int = 0
    private var word: String = ""
    
    init(boardSquares: [BoardSquare], wordOrientation: WordOrientation) {
        self.boardSquares = boardSquares
        self.wordOrientation = wordOrientation
        
        self.word = calculateWord()
        self.points = calculatePoints()
    }
    
    var description: String {
        return "\(word) (\(points))"
    }
    
    private func calculateWord() -> String{
        var wordBuilder: String = ""
            
        if (wordOrientation == .horizontal) {
            let sortedSquares = boardSquares.sorted(by: { $0.column < $1.column })
                
            for square in sortedSquares {
                wordBuilder.append(square.tile!.letter)
            }
        } else {
            let sortedSquares = boardSquares.sorted(by: { $0.row < $1.row })
        
            for square in sortedSquares {
                wordBuilder.append(square.tile!.letter)
            }
        }
        
        return wordBuilder
    }
    
    private func calculatePoints() -> Int {
        var totalPoints: Int = 0
        var multiplier: Int = 1
        
        for square in boardSquares {
            if (square.tile!.tileState == .committedToBoard) {
                totalPoints += square.tile!.points
                continue
            }
            
            let currentSquarePoints = square.tile!.points
            
            if (square.tileType == .doubleLetter) {
                totalPoints += currentSquarePoints * 2
            } else if (square.tileType == .tripleLetter) {
                totalPoints += currentSquarePoints * 3
            } else {
                totalPoints += currentSquarePoints
                
                if (square.tileType == .doubleWord) {
                    multiplier *= 2
                } else if (square.tileType == .tripleWord) {
                    multiplier *= 3
                }
            }
        }
        
        return totalPoints * multiplier
    }
    
    func getWord() -> String {
        return word
    }
    
    func getPoints() -> Int {
        return points
    }
    
    func connectedToExistingTiles() -> Bool {
        return boardSquares.contains(where: { $0.tile?.tileState == .committedToBoard })
    }
    
    static func == (lhs: Word, rhs: Word) -> Bool {
        lhs.id == rhs.id && lhs.word == rhs.word && lhs.points == rhs.points && lhs.wordOrientation == rhs.wordOrientation
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
