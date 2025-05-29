//
//  BoardGrid.swift
//  Scrabble
//
//  Created by Eric Johns on 5/22/25.
//

import SwiftUI

struct BoardGrid: View {
    let size: CGFloat
    let tileSize: CGFloat
    
    var body: some View {
        ZStack {
            ForEach(0..<15) { row in
                ForEach(0..<15) { col in
                    Rectangle()
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        .frame(width: tileSize, height: tileSize)
                        .position(
                            x: CGFloat(col) * tileSize + tileSize / 2,
                            y: CGFloat(row) * tileSize + tileSize / 2)
                }
            }
        }
        .frame(width: size, height: size)
    }
}

//#Preview {
//    BoardGrid(size: 44, tileSize: 44)
//}
