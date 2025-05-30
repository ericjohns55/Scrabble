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
            Text("Scrabble")
                .foregroundStyle(.white)
                .font(.title)
                .bold()
                .padding(.bottom, 8)
            
            BoardView(viewModel: viewModel, dragManager: dragManager)
                .aspectRatio(1, contentMode: .fit)
                .padding(.bottom, 8)

            TileRackView(
                dragManager: dragManager,
                tiles: $viewModel.tiles,
                onTileDrop: { id, dropPoint in
                    viewModel.updateTilePosition(id, to: dropPoint, dragManager: dragManager)
                }
            )
            .padding(.bottom, 8)
            
            Button("Recall Tiles") {
                viewModel.recallTiles()
            }
        }
    }
}
