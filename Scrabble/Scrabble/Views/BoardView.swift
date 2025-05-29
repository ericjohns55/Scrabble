//
//  BoardView.swift
//  Scrabble
//
//  Created by Eric Johns on 5/22/25.
//

import SwiftUI

struct BoardView: View {
    @ObservedObject var viewModel: GameViewModel
    @Binding var boardFrame: CGRect

    let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 15)

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(0..<15) { _ in
                        ForEach(0..<15) { _ in
                            Rectangle()
                                .stroke(Color.gray.opacity(0.5), lineWidth: 0.5)
                                .aspectRatio(1, contentMode: .fit)
                        }
                    }
                }

                ForEach($viewModel.tiles) { $tile in
                    if let position = tile.boardPosition {
                        let tileSize = boardFrame.width / 15

                        DraggableTile(
                            tile: $tile,
                            boardFrame: boardFrame,
                            viewModel: viewModel,
                            tileSize: tileSize
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
                boardFrame = geometry.frame(in: .named("gameSpace"))
            }
            .onChange(of: geometry.size) { _, _ in
                boardFrame = geometry.frame(in: .named("gameSpace"))
            }
        }
    }
}
