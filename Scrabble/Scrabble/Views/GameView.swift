//
//  GameView.swift
//  Scrabble
//
//  Created by Eric Johns on 5/22/25.
//

import SwiftUI

struct GameView: View {
    @StateObject private var viewModel = GameViewModel()
    @State private var boardFrame: CGRect = .zero

    var body: some View {
        VStack(spacing: 0) {
            BoardView(viewModel: viewModel, boardFrame: $boardFrame)
                .aspectRatio(1, contentMode: .fit)

            TileRackView(
                tiles: $viewModel.tiles,
                tileSize: boardFrame.width / 15,
                boardFrame: boardFrame,
                onTileDrop: { id, dropPoint in
                    viewModel.updateTilePosition(id, to: dropPoint, boardFrame: boardFrame)
                }
            )
            .frame(height: boardFrame.width / 15 + 20)
            .padding(.top, 8)
        }
        .coordinateSpace(name: "gameSpace")
    }
}
