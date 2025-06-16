//
//  BoardViewModel.swift
//  Scrabble
//
//  Created by Eric Johns on 6/15/25.
//

import SwiftUI

class BoardViewModel: ObservableObject {
    public static let GRID_SIZE: Int = 11
    
    @Published var board: [BoardSquare] = (0..<GRID_SIZE).map { row in
        (0..<GRID_SIZE).map { column in
            BoardSquare(row: row, column: column, boardSize: GRID_SIZE)
        }
    }.flatMap { $0 }
    
    func getBoardSquareByTileId(_ id: UUID) -> BoardSquare? {
        return board.first(where: { $0.tile?.id == id })
    }
    
    func getBoardSquareByPosition(row: Int, col: Int) -> BoardSquare? {
        return board.first(where: { $0.row == row && $0.column == col })
    }
    
    func hasTileAtPosition(row: Int, col: Int) -> Bool {
        return board.contains(where: { $0.row == row && $0.column == col && $0.tile != nil })
    }
    
    func updateTileAtPosition(_ newTile: Tile?, row: Int, col: Int) {
        board.first(where: { $0.row == row && $0.column == col })?.tile = newTile
    }
    
    func isCenterTileFilled() -> Bool {
        return hasTileAtPosition(row: BoardViewModel.GRID_SIZE / 2, col: BoardViewModel.GRID_SIZE / 2)
    }
    
    func hasCommittedTiles() -> Bool {
        return board.contains(where: { $0.tile?.tileState == .committedToBoard })
    }
    
    func arePlacedTilesConsecutive(_ placedTilesSorted: [Tile], wordOrientation: WordOrientation) -> Bool {
        if (wordOrientation == .horizontal) {
            let row = placedTilesSorted.first!.boardPosition!.row
            let lowestColumn = placedTilesSorted.first!.boardPosition!.col
            let highestColumn = placedTilesSorted.last!.boardPosition!.col
            
            for index in (lowestColumn...highestColumn) {
                if (!hasTileAtPosition(row: row, col: index)) {
                    return false
                }
            }
            
        } else {
            let column = placedTilesSorted.first!.boardPosition!.col
            let lowestRow = placedTilesSorted.first!.boardPosition!.row
            let highestRow = placedTilesSorted.last!.boardPosition!.row
            
            for index in (lowestRow...highestRow) {
                if (!hasTileAtPosition(row: index, col: column)) {
                    return false
                }
            }
        }
        
        return true
    }
    
    func getWordHorizontal(_ tileId: UUID) -> Word? {
        guard let startingSquare = getBoardSquareByTileId(tileId) else {
            return nil
        }
        
        let row = startingSquare.row
        var currentColumn = startingSquare.column
        
        while (hasTileAtPosition(row: row, col: currentColumn - 1)) {
            currentColumn -= 1
        }
        
        var boardSquareAccumulator: [BoardSquare] = []
        
        while (hasTileAtPosition(row: row, col: currentColumn)) {
            boardSquareAccumulator.append(getBoardSquareByPosition(row: row, col: currentColumn)!)
            currentColumn += 1
        }
        
        if (boardSquareAccumulator.count < 2) {
            return nil
        }
        
        return Word(boardSquares: boardSquareAccumulator, wordOrientation: .horizontal)
    }
    
    func getWordVertical(_ tileId: UUID) -> Word? {
        guard let startingSquare = getBoardSquareByTileId(tileId) else {
            return nil
        }
        
        let column = startingSquare.column
        var currentRow = startingSquare.row
        
        while (hasTileAtPosition(row: currentRow - 1, col: column)) {
            currentRow -= 1
        }
        
        var boardSquareAccumulator: [BoardSquare] = []
        
        while (hasTileAtPosition(row: currentRow, col: column)) {
            boardSquareAccumulator.append(getBoardSquareByPosition(row: currentRow, col: column)!)
            currentRow += 1
        }
        
        if (boardSquareAccumulator.count < 2) {
            return nil
        }
        
        return Word(boardSquares: boardSquareAccumulator, wordOrientation: .vertical)
    }
}
