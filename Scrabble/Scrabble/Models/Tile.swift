//
//  Tile.swift
//  Scrabble
//
//  Created by Eric Johns on 5/18/25.
//

import Foundation

enum TileState {
    case inTileBag
    case committedToBoard
    case placedByPlayer
    case inPlayerHand
}

struct BoardPosition: Equatable {
    var row: Int
    var col: Int
}

struct Tile: Identifiable, Equatable {
    let id = UUID()
    let letter: String
    let points: Int
    var tileState: TileState = .inTileBag
    var boardPosition: BoardPosition? = nil
    var offset: CGSize = .zero
}
