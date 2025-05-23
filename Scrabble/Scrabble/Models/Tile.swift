//
//  Tile.swift
//  Scrabble
//
//  Created by Eric Johns on 5/18/25.
//

import Foundation

struct Tile: Identifiable, Hashable, Codable {
    var id = UUID()
    let letter: String
    let points: Int
}
