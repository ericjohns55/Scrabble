//
//  BoardSquare.swift
//  Scrabble
//
//  Created by Eric Johns on 6/14/25.
//

import SwiftUI

enum TileType {
    case doubleLetter, tripleLetter, doubleWord, tripleWord, startingSquare, empty
    
    static func getTileColor(_ tileType: TileType) -> Color {
        switch tileType {
            case .doubleLetter:
                return .blue
            case .tripleLetter:
                return .green
            case .doubleWord:
                return .red
            case .tripleWord:
                return .orange
            case .startingSquare:
                return .purple
            case .empty:
                return .black
        }
    }
    
    static func getTileText(_ tileType: TileType) -> String {
        switch tileType {
            case .doubleLetter:
                return "DL"
            case .tripleLetter:
                return "TL"
            case .doubleWord:
                return "DW"
            case .tripleWord:
                return "TW"
            case .startingSquare:
                return "*"
            case .empty:
                return ""
        }
    }
}

class BoardSquare: Hashable, Equatable, Identifiable {
    let id: UUID = UUID()
    
    let row: Int
    let column: Int
    
    var tile: Tile? = nil
    var tileType = TileType.empty
    
    init(row: Int, column: Int, tileType: TileType = .empty) {
        self.row = row
        self.column = column
        self.tileType = tileType
    }
    
    init(row: Int, column: Int, boardSize: Int = 9) {
        self.row = row
        self.column = column
        self.tileType = BoardSetup.getBoardTile(boardSize, row: row, col: column)
    }
    
    static func == (lhs: BoardSquare, rhs: BoardSquare) -> Bool {
        lhs.id == rhs.id && lhs.row == rhs.row && lhs.column == rhs.column
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

class BoardSetup {
    static let tripleWords: [Int: [(Int, Int)]] = [
        9: [(0, 2), (0, 6), (2, 0), (2, 8), (6, 0), (6, 8), (8, 2), (8, 6)],
        11: [(0, 3), (0, 7), (3, 0), (3, 10), (7, 0), (7, 10), (10, 3), (10, 7)]
    ]
    
    static let tripleLetters: [Int: [(Int, Int)]] = [
        9: [(1, 1), (1, 7), (7, 1), (7, 7)],
        11: [(1, 2), (1, 8), (2, 1), (2, 9), (3, 3), (3, 7), (7, 3), (7, 7), (8, 1), (8, 9), (9, 2), (9, 8)]
    ]
    
    static let doubleWords: [Int: [(Int, Int)]] = [
        9: [(1, 4), (4, 1), (4, 7), (7, 4)],
        11: [(1, 5), (5, 1), (5, 9), (9, 5)]
    ]
    
    static let doubleLetters: [Int: [(Int, Int)]] = [
        9: [(2, 3), (2, 5), (3, 2), (3, 6), (5, 2), (5, 6), (6, 3), (6, 5)],
        11: [(2, 4), (2, 6), (4, 2), (4, 8), (6, 2), (6, 8), (8, 4), (8, 6)]
    ]
    
    static func getBoardTile(_ boardSize: Int, row: Int, col: Int) -> TileType {
        if (row == boardSize / 2 && col == boardSize / 2) {
            return .startingSquare
        }
        
        let currentPosition: ((Int, Int)) -> Bool = { $0.0 == row && $0.1 == col }
        
        if tripleWords[boardSize]?.contains(where: currentPosition) ?? false {
            return .tripleWord
        }
        
        if tripleLetters[boardSize]?.contains(where: currentPosition) ?? false {
            return .tripleLetter
        }
        
        if doubleWords[boardSize]?.contains(where: currentPosition) ?? false {
            return .doubleWord
        }
        
        if doubleLetters[boardSize]?.contains(where: currentPosition) ?? false {
            return .doubleLetter
        }
        
        return .empty
    }
}
