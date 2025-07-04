//
//  DraggableTile.swift
//  Scrabble
//
//  Created by Eric Johns on 5/22/25.
//

import SwiftUI

struct DraggableTile: View {
    @ObservedObject var dragManager: DragManager
    @ObservedObject var viewModel: GameViewModel
    
    @Binding var tile: Tile

    @State private var dragOffset: CGSize = .zero

    var body: some View {
        GeometryReader { geo in
            let tileSize = dragManager.boardFrame.width / CGFloat(viewModel.boardManager.getGridSize())
            
            TileView(tile: tile, size: tileSize)
                .offset(dragOffset)
                .gesture(
                    tile.tileState == .committedToBoard ? nil :
                        DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation
                            }
                            .onEnded { value in
                                guard let pos = tile.boardPosition else {
                                    dragOffset = .zero
                                    return
                                }
                                
                                let currentX = CGFloat(pos.col) * tileSize + tileSize / 2
                                let currentY = CGFloat(pos.row) * tileSize + tileSize / 2
                                
                                // Final drop point in board coordinates:
                                let dropPoint = CGPoint(
                                    x: currentX + value.translation.width,
                                    y: currentY + value.translation.height
                                )
                                
                                dragOffset = .zero
                                viewModel.updateTilePosition(tile.id, to: dropPoint, dragManager: dragManager)
                            }
                )
        }
    }
}
