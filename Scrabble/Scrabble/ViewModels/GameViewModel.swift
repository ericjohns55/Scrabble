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
        tiles = "EXAMPLE".map { Tile(letter: String($0)) }
    }

    func updateTilePosition(_ tileID: UUID, to dropPoint: CGPoint, boardFrame: CGRect) {
        guard let index = tiles.firstIndex(where: { $0.id == tileID }) else { return }

        let localX = dropPoint.x - boardFrame.minX
        let localY = dropPoint.y - boardFrame.minY

        let tileSize = boardFrame.width / 15
        let col = Int(localX / tileSize)
        let row = Int(localY / tileSize)

        print("DropPoint: \(dropPoint)")
        print("BoardFrame: \(boardFrame)")
        print("→ localX: \(dropPoint.x - boardFrame.minX), localY: \(dropPoint.y - boardFrame.minY)")
        print("Dropped tile at row: \(row), col: \(col)")
        
        print("\n\n")

        if row >= 0, row < 15, col >= 0, col < 15 {
            tiles[index].boardPosition = BoardPosition(row: row, col: col)
            tiles[index].offset = .zero
        } else {
            tiles[index].boardPosition = nil // tile returns to rack
        }
    }
}
