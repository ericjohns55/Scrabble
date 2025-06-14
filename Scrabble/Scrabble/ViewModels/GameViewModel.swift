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
    @Published var playerTiles: [Tile] = []
    @Published var committedTiles: [Tile] = []
    @Published var tileBag: [Tile] = []
    
    var boardViewModel: BoardViewModel = BoardViewModel()
    lazy var wordValidator = WordValidator(gameViewModel: self)
    
    let tileSize: CGFloat = 44
    let maxTiles: Int = 7

    init() {
        populateTileBag()
        drawTiles(maxTiles)
    }
    
    private func populateTileBag() {
        let tileBreakdowns = [
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
        
        tileBag = []
        for tile in tileBreakdowns {
            for _ in 0..<tile.count {
                tileBag.append(Tile(letter: tile.letter, points: tile.points))
            }
        }
        
        tileBag.shuffle()
    }
    
    func drawTiles(_ count: Int) {
        for _ in 0..<count {
            if tileBag.isEmpty {
                break
            }
            
            var tileToDraw = tileBag.removeLast()
            tileToDraw.tileState = .inPlayerHand
            
            playerTiles.append(tileToDraw)
        }
    }

    func updateTilePosition(_ tileID: UUID, to dropPoint: CGPoint, dragManager: DragManager) {
        guard let index = playerTiles.firstIndex(where: { $0.id == tileID }) else { return }
        
        // TODO: make sure tile is in bounds of visible rectangle
//        print("BOARD FRAME: \(dragManager.boardFrame)")
//        print("DROP POINT: \(dropPoint)")
//        print("IN BOUNDS: \(dragManager.boardFrame.contains(dropPoint))")

        let tileSize = dragManager.boardFrame.width / CGFloat(BoardViewModel.GRID_SIZE)
        let col = Int(dropPoint.x / tileSize)
        let row = Int(dropPoint.y / tileSize)
        
        let existingTile = playerTiles.firstIndex(where: { $0.boardPosition?.row == row && $0.boardPosition?.col == col })
                        ?? committedTiles.firstIndex(where: { $0.boardPosition?.row == row && $0.boardPosition?.col == col})
        
        if (existingTile == nil) {
            if let currentBoardSquare = boardViewModel.getBoardSquareByTileId(tileID) {
                currentBoardSquare.tile = nil
            }
            
            var tileToUpdate = playerTiles[index]
            if row >= 0, row < BoardViewModel.GRID_SIZE, col >= 0, col < BoardViewModel.GRID_SIZE {
                tileToUpdate.boardPosition = BoardPosition(row: row, col: col)
                tileToUpdate.offset = .zero
                tileToUpdate.tileState = .placedByPlayer
                
                boardViewModel.updateTileAtPosition(tileToUpdate, row: row, col: col)
            } else {
                tileToUpdate.boardPosition = nil // tile returns to rack
                tileToUpdate.tileState = .inPlayerHand
                
                boardViewModel.updateTileAtPosition(nil, row: row, col: col)
            }
            
            playerTiles[index] = tileToUpdate
        }
        
        wordValidator.updateTileState()
    }
    
    func canShuffle() -> Bool {
        return playerTiles.allSatisfy { $0.tileState == .inPlayerHand }
    }
    
    func shuffleOrRecall() {
        if (canShuffle()) {
            playerTiles.shuffle()
        } else {
            for (_, currentTile) in playerTiles.enumerated() {
                if (currentTile.tileState == .placedByPlayer) {
                    let tileIndex = playerTiles.firstIndex(of: currentTile)!
                    
                    playerTiles[tileIndex].boardPosition = nil
                    playerTiles[tileIndex].offset = .zero
                    playerTiles[tileIndex].tileState = .inPlayerHand
                    
                    if let currentBoardSquare = boardViewModel.getBoardSquareByTileId(currentTile.id) {
                        currentBoardSquare.tile = nil
                    }
                }
            }
            
            wordValidator.updateTileState()
        }
    }
    
    func commitTiles() {
        for (_, currentTile) in playerTiles.enumerated() {
            if (currentTile.tileState == .placedByPlayer) {
                let indexInHand = playerTiles.firstIndex(of: currentTile)!
                
                var tileToUpdate = playerTiles.remove(at: indexInHand)
                tileToUpdate.tileState = .committedToBoard
                
                committedTiles.append(tileToUpdate)
                
                if let currentBoardSquare = boardViewModel.getBoardSquareByTileId(currentTile.id) {
                    currentBoardSquare.tile = tileToUpdate
                }
            }
        }
        
        let numTilesToDraw = maxTiles - playerTiles.count
        drawTiles(numTilesToDraw)
        
        wordValidator.updateTileState()
    }
}
