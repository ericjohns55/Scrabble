//
//  GameViewModel.swift
//  Scrabble
//
//  Created by Eric Johns on 5/22/25.
//

import SwiftUI

class GameViewModel: ObservableObject {
    @Published var tiles: [Tile] = []

    let boardSize = 15
    let tileSize: CGFloat = 44

    init() {
        tiles = "TESTING".map { Tile(letter: String($0)) }
    }

    func updateTilePosition(_ tileID: UUID, to dropPoint: CGPoint, dragManager: DragManager) {
        guard let index = tiles.firstIndex(where: { $0.id == tileID }) else { return }

        let tileSize = dragManager.boardFrame.width / 15
        let col = Int(dropPoint.x / tileSize)
        let row = Int(dropPoint.y / tileSize)
        
        let existingTile = tiles.firstIndex(where: { $0.boardPosition?.row == row && $0.boardPosition?.col == col })
        
        if (existingTile == nil) {
            if row >= 0, row < 15, col >= 0, col < 15 {
                tiles[index].boardPosition = BoardPosition(row: row, col: col)
                tiles[index].offset = .zero
            } else {
                tiles[index].boardPosition = nil // tile returns to rack
            }
        }
    }
    
    func recallTiles() {
        for (index, _) in tiles.enumerated() {
            tiles[index].boardPosition = nil
            tiles[index].offset = .zero
        }
    }
}
