//
//  GameViewModel.swift
//  Scrabble
//
//  Created by Eric Johns on 5/22/25.
//

import SwiftUI

struct TileBreakdown {
    var letter: String
    var count: Int
    var points: Int
}

class GameViewModel: ObservableObject {
    @Published var allTiles: [Tile] = []
    @Published var tileRack: [UUID] = []

    let boardSize = 15
    let tileSize: CGFloat = 44

    init() {
        let tileBag = [
            TileBreakdown(letter: "?", count: 2, points: 0),
            TileBreakdown(letter: "A", count: 9, points: 1),
            TileBreakdown(letter: "B", count: 2, points: 4),
            TileBreakdown(letter: "C", count: 2, points: 4),
            TileBreakdown(letter: "D", count: 5, points: 2),
            TileBreakdown(letter: "E", count: 13, points: 1),
            TileBreakdown(letter: "F", count: 2, points: 4),
            TileBreakdown(letter: "G", count: 3, points: 3),
            TileBreakdown(letter: "H", count: 4, points: 3),
            TileBreakdown(letter: "I", count: 8, points: 1),
            TileBreakdown(letter: "J", count: 1, points: 10),
            TileBreakdown(letter: "K", count: 1, points: 5),
            TileBreakdown(letter: "L", count: 4, points: 2),
            TileBreakdown(letter: "M", count: 2, points: 4),
            TileBreakdown(letter: "N", count: 5, points: 2),
            TileBreakdown(letter: "O", count: 8, points: 1),
            TileBreakdown(letter: "P", count: 2, points: 4),
            TileBreakdown(letter: "Q", count: 1, points: 10),
            TileBreakdown(letter: "R", count: 6, points: 1),
            TileBreakdown(letter: "S", count: 5, points: 1),
            TileBreakdown(letter: "T", count: 7, points: 1),
            TileBreakdown(letter: "U", count: 4, points: 2),
            TileBreakdown(letter: "V", count: 2, points: 5),
            TileBreakdown(letter: "W", count: 2, points: 4),
            TileBreakdown(letter: "X", count: 1, points: 8),
            TileBreakdown(letter: "Y", count: 2, points: 3),
            TileBreakdown(letter: "Z", count: 1, points: 10)
        ]
        
        allTiles = []
        for tile in tileBag {
            for _ in 0..<tile.count {
                allTiles.append(Tile(letter: tile.letter, points: tile.points))
            }
        }
        
        allTiles.shuffle()
        
        for i in 0..<7 {
            allTiles[i].tileState = .inPlayerHand
            tileRack.append(allTiles[i].id)
        }
    }

    func updateTilePosition(_ tileID: UUID, to dropPoint: CGPoint, dragManager: DragManager) {
        guard let index = allTiles.firstIndex(where: { $0.id == tileID }) else { return }
        
        print("BOARD FRAME: \(dragManager.boardFrame)")
        print("DROP POINT: \(dropPoint)")
        print("IN BOUNDS: \(dragManager.boardFrame.contains(dropPoint))")
        // TODO: make sure tile is in bounds of visible rectangle

        let tileSize = dragManager.boardFrame.width / 15
        let col = Int(dropPoint.x / tileSize)
        let row = Int(dropPoint.y / tileSize)
        
        let existingTile = allTiles.firstIndex(where: { $0.boardPosition?.row == row && $0.boardPosition?.col == col })
        
        if (existingTile == nil) {
            if row >= 0, row < 15, col >= 0, col < 15 {
                allTiles[index].boardPosition = BoardPosition(row: row, col: col)
                allTiles[index].offset = .zero
                allTiles[index].tileState = .placedByPlayer
            } else {
                allTiles[index].boardPosition = nil // tile returns to rack
                allTiles[index].tileState = .inPlayerHand
            }
        }
    }
    
    func recalculateTileRack() {
        tileRack = []
        
        for (index, _) in allTiles.enumerated() {
            if (allTiles[index].isActiveTile()) {
                tileRack.append(allTiles[index].id)
            }
        }
    }
    
    func recallTiles() {
        for (index, _) in allTiles.enumerated() {
            if (allTiles[index].tileState == .placedByPlayer) {
                allTiles[index].boardPosition = nil
                allTiles[index].offset = .zero
                allTiles[index].tileState = .inPlayerHand
            }
        }
    }
    
    func commitTiles() {
        for (index, _) in allTiles.enumerated() {
            if (allTiles[index].tileState == .placedByPlayer) {
                allTiles[index].tileState = .committedToBoard
            }
        }
        
        let numTilesToPlace = 7 - allTiles.filter { $0.tileState == .inPlayerHand }.count
        var currentTileIndex = 0
        
        for _ in 0..<numTilesToPlace {
            while allTiles[currentTileIndex].tileState != .inTileBag {
                currentTileIndex += 1
            }
            
            allTiles[currentTileIndex].tileState = .inPlayerHand
            
            currentTileIndex += 1
            if currentTileIndex >= allTiles.count {
                currentTileIndex = 0
            }
        }
        
        recalculateTileRack()
    }
}
