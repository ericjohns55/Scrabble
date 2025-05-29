//
//  DraggableTile.swift
//  Scrabble
//
//  Created by Eric Johns on 5/22/25.
//

import SwiftUI

struct DraggableTile: View {
    @Binding var tile: Tile
    let boardFrame: CGRect
    let viewModel: GameViewModel
    let tileSize: CGFloat

    @State private var dragOffset: CGSize = .zero

    var body: some View {
        GeometryReader { geo in
            TileView(letter: tile.letter, size: tileSize)
                .offset(dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation
                        }
                        .onEnded { value in
                            // Calculate the drop point based on current tile position + drag offset
                            // Get the tile’s current position relative to boardFrame
                            guard let pos = tile.boardPosition else {
                                dragOffset = .zero
                                return
                            }
                            
                            let tileSize = boardFrame.width / 15
                            let currentX = CGFloat(pos.col) * tileSize + tileSize / 2
                            let currentY = CGFloat(pos.row) * tileSize + tileSize / 2

                            // Final drop point in board coordinates:
                            let dropPoint = CGPoint(
                                x: currentX + value.translation.width,
                                y: currentY + value.translation.height
                            )
                            
                            print("MOVED TILE in DraggableTile")

                            dragOffset = .zero
                            viewModel.updateTilePosition(tile.id, to: dropPoint, boardFrame: boardFrame)
                        }
                )
        }
    }
}
