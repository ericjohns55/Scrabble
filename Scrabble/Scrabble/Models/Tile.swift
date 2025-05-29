//
//  Tile.swift
//  Scrabble
//
//  Created by Eric Johns on 5/18/25.
//

import Foundation

struct BoardPosition: Equatable {
    var row: Int
    var col: Int
}

struct Tile: Identifiable, Equatable {
    let id = UUID()
    let letter: String
    var boardPosition: BoardPosition? = nil
    var offset: CGSize = .zero
}
