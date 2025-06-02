//
//  BoardView.swift
//  Scrabble
//
//  Created by Eric Johns on 5/22/25.
//

import SwiftUI

struct BoardView: View {
    @ObservedObject var viewModel: GameViewModel
    @ObservedObject var dragManager: DragManager

    let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 15)

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(0..<(15*15)) { _ in
                        Rectangle()
                            .stroke(Color.gray.opacity(0.5), lineWidth: 0.5)
                            .aspectRatio(1, contentMode: .fit)
                    }
                }

                ForEach($viewModel.allTiles) { $tile in
                    if let position = tile.boardPosition {
                        let tileSize = dragManager.boardFrame.width / 15

                        DraggableTile(
                            dragManager: dragManager,
                            viewModel: viewModel,
                            tile: $tile
                        )
                        .frame(width: tileSize, height: tileSize)
                        .position(
                            x: CGFloat(position.col) * tileSize + tileSize / 2,
                            y: CGFloat(position.row) * tileSize + tileSize / 2
                        )
                    }
                }
            }
            .onAppear {
                dragManager.boardFrame = geometry.frame(in: .global)
            }
        }
    }
}
