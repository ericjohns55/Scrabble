//
//  TileView.swift
//  Scrabble
//
//  Created by Eric Johns on 5/22/25.
//

import SwiftUI

struct TileView: View {
    let letter: String
    let size: CGFloat
    
    var body: some View {
        Text(letter)
            .font(.title2.bold())
            .frame(width: size, height: size)
            .background(Color.yellow)
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black))
    }
}
