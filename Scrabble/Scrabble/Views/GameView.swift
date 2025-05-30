//
//  GameView.swift
//  Scrabble
//
//  Created by Eric Johns on 5/22/25.
//

import SwiftUI

class DragManager: ObservableObject {
    @Published var boardFrame: CGRect = .zero
    @Published var dropLocationInBoard: CGPoint?
}

struct GameView: View {
    @StateObject private var viewModel = GameViewModel()
    @StateObject private var dragManager = DragManager()

    var body: some View {
        VStack(spacing: 0) {
            BoardView(viewModel: viewModel, dragManager: dragManager)
                .aspectRatio(1, contentMode: .fit)

            TileRackView(
                dragManager: dragManager,
                tiles: $viewModel.tiles,
                onTileDrop: { id, dropPoint in
                    viewModel.updateTilePosition(id, to: dropPoint, dragManager: dragManager)
                }
            )
            .frame(height: dragManager.boardFrame.width / 15 + 20)
            .padding(.top, 8)
        }
    }
}
