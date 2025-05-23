//
//  BoardSquare.swift
//  Scrabble
//
//  Created by Eric Johns on 5/18/25.
//

import Foundation

struct BoardSquare: Identifiable {
    let id = UUID()
    var tile: Tile? = nil
    var modifier: String? = nil
}
