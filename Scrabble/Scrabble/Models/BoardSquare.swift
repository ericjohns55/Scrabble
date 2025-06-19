//
//  BoardSquare.swift
//  Scrabble
//
//  Created by Eric Johns on 6/14/25.
//

import SwiftUI

enum TileType: Int {
    case empty = 0
    case startingSquare = 1
    case doubleLetter = 2
    case tripleLetter = 3
    case doubleWord = 4
    case tripleWord = 5
    
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
                return Color(red: 0.12, green: 0.12, blue: 0.12)
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
                return "+"
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
    
    init(row: Int, column: Int, boardIdentifier: BoardIdentifier) {
        self.row = row
        self.column = column
        self.tileType = BoardSetup.getBoardTile(boardIdentifier, row: row, col: column)
    }
    
    static func == (lhs: BoardSquare, rhs: BoardSquare) -> Bool {
        lhs.id == rhs.id && lhs.row == rhs.row && lhs.column == rhs.column
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
