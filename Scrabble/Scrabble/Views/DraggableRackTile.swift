//
//  DraggableRackTile.swift
//  Scrabble
//
//  Created by Eric Johns on 5/22/25.
//

import SwiftUI

struct DraggableRackTile: View {
    @Binding var tile: Tile
    let tileSize: CGFloat
    let boardFrame: CGRect
    let viewModel: GameViewModel

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
                            let globalDropPoint = CGPoint(
                                x: geo.frame(in: .named("gameSpace")).minX + value.location.x,
                                y: geo.frame(in: .named("gameSpace")).minY + value.location.y
                            )

                            dragOffset = .zero
                            viewModel.updateTilePosition(tile.id, to: globalDropPoint, boardFrame: boardFrame)
                        }
                )
        }
    }
}
