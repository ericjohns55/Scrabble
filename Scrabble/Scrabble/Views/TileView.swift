//
//  TileView.swift
//  Scrabble
//
//  Created by Eric Johns on 5/22/25.
//

import SwiftUI

struct TileView: View {
    let tile: Tile
    let size: CGFloat
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Text(tile.letter)
                .font(.title2.bold())
                .frame(width: size, height: size)
                .background(tile.tileState != .committedToBoard ? Color.yellow : Color.gray)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black))
            
            Text("\(tile.points)")
                .font(.caption2)
                .foregroundStyle(Color.white)
                .padding(4)
        }
    }
}
