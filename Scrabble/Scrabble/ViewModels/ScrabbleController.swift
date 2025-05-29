//
//  ScrabbleController.swift
//  Scrabble
//
//  Created by Eric Johns on 5/18/25.
//

import Foundation
import SwiftUI

struct TileBreakdown {
    var letter: Character
    var count: Int
    var points: Int
}

class ScrabbleController: ObservableObject {
//    @Published var board: [[BoardSquare]] = []
    @Published var availableTiles: [Tile] = []
    
    init() {
//        board = Array(repeating: Array(repeating: BoardSquare(), count: 15), count: 15)
//        
//        let cornerTile = Tile(letter: "*", points: 1)
//        board[0][14] = BoardSquare(tile: cornerTile)
//        board[14][0] = BoardSquare(tile: cornerTile)
//        board[14][14] = BoardSquare(tile: cornerTile)
//        board[0][0].modifier = "DL"
//        
//        availableTiles = [
//            Tile(letter: "A", points: 1),
//            Tile(letter: "B", points: 4),
//            Tile(letter: "C", points: 4),
//            Tile(letter: "D", points: 2),
//            Tile(letter: "E", points: 1),
//            Tile(letter: "F", points: 4),
//            Tile(letter: "G", points: 3),
//        ]
        
//        var tileBag = [
//            TileBreakdown(letter: "?", count: 2, points: 0),
//            TileBreakdown(letter: "A", count: 9, points: 1),
//            TileBreakdown(letter: "B", count: 2, points: 4),
//            TileBreakdown(letter: "C", count: 2, points: 4),
//            TileBreakdown(letter: "D", count: 5, points: 2),
//            TileBreakdown(letter: "E", count: 13, points: 1),
//            TileBreakdown(letter: "F", count: 2, points: 4),
//            TileBreakdown(letter: "G", count: 3, points: 3),
//            TileBreakdown(letter: "H", count: 4, points: 3),
//            TileBreakdown(letter: "I", count: 8, points: 1),
//            TileBreakdown(letter: "J", count: 1, points: 10),
//            TileBreakdown(letter: "K", count: 1, points: 5),
//            TileBreakdown(letter: "L", count: 4, points: 2),
//            TileBreakdown(letter: "M", count: 2, points: 4),
//            TileBreakdown(letter: "N", count: 5, points: 2),
//            TileBreakdown(letter: "O", count: 8, points: 1),
//            TileBreakdown(letter: "P", count: 2, points: 4),
//            TileBreakdown(letter: "Q", count: 1, points: 10),
//            TileBreakdown(letter: "R", count: 6, points: 1),
//            TileBreakdown(letter: "S", count: 5, points: 1),
//            TileBreakdown(letter: "T", count: 7, points: 1),
//            TileBreakdown(letter: "U", count: 4, points: 2),
//            TileBreakdown(letter: "V", count: 2, points: 5),
//            TileBreakdown(letter: "W", count: 2, points: 4),
//            TileBreakdown(letter: "X", count: 1, points: 8),
//            TileBreakdown(letter: "Y", count: 2, points: 3),
//            TileBreakdown(letter: "Z", count: 1, points: 10)
//        ]
//        
//        availableTiles = []
//        for tile in tileBag {
//            for _ in 0..<tile.count {
//                availableTiles.append(Tile(letter: tile.letter, points: tile.points))
//            }
//        }
    }
//    
//    func placeTile(_ tile: Tile, row: Int, col: Int) -> Bool {
//        guard board[row][col].tile == nil else {
//            print("Cannot place tile here")
//            return false
//        }
//        
//        board[row][col].tile = tile
//        printBoard()
//        
//        print("Placed tile: \(tile.letter) (p\(tile.points))")
//        
//        if let index = availableTiles.firstIndex(of: tile) {
//            availableTiles.remove(at: index)
//            print("Removed from bag")
//            return true
//        }
//        
//        print("Failed to remove from bag")
//        
//        return false
//    }
//    
//    func printBoard() {
//        for i in 0..<15 {
//            for j in 0..<15 {
//                if (board[i][j].tile != nil) {
//                    print(board[i][j].tile?.letter ?? "")
//                }
//            }
//        }
//    }
}
