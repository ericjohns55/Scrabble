//
//  Tile.swift
//  Scrabble
//
//  Created by Eric Johns on 5/18/25.
//

import Foundation
import SwiftUI

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

struct CornerRadii: Equatable {
    var topLeft: Bool = false
    var topRight: Bool = false
    var bottomLeft: Bool = false
    var bottomRight: Bool = false
}

struct Tile: Identifiable, Equatable {
    let id = UUID()
    let letter: String
    let points: Int
    var tileState: TileState = .inTileBag
    var boardPosition: BoardPosition? = nil
    var cornerRadii: CornerRadii = CornerRadii()
    var offset: CGSize = .zero
}
