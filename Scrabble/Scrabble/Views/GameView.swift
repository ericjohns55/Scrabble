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
    @Published var boardZoomScale: CGFloat = 1.0
    @Published var boardOffset: CGSize = .zero
}

struct GameView: View {
    @StateObject private var viewModel = GameViewModel()
    @StateObject private var dragManager = DragManager()
    
    private let buttonHeight: CGFloat = 72
    
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

            TileRackView(viewModel: viewModel, dragManager: dragManager)
                .padding(.bottom, 8)
            
            HStack {
                Button(action: {
                    viewModel.shuffleOrRecall()
                }) {
                    Text(viewModel.canShuffle() ? "Shuffle Tiles" : "Recall Tiles")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .contentShape(Rectangle())
                .border(.gray)
                .padding(10)
                
                Button(action: {
                    viewModel.commitTiles()
                }) {
                    Text("Submit Word")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .contentShape(Rectangle())
                .border(.gray)
                .padding(10)
                .disabled(viewModel.wordValidator.placementState != .valid)
            }
            .frame(maxWidth: .infinity, maxHeight: buttonHeight)
            
            Text("Tile Placement: \(viewModel.wordValidator.placementState)")
                .foregroundStyle(PlacementStatus.getColor(for: viewModel.wordValidator.placementState))
            
            Text("Valid Words: \(viewModel.wordValidator.currentValidWords)")
                .foregroundStyle(PlacementStatus.getColor(for: viewModel.wordValidator.placementState))
            
            Text("Invalid Words: \(viewModel.wordValidator.currentInvalidWords)")
                .foregroundStyle(PlacementStatus.getColor(for: viewModel.wordValidator.placementState))
            
//            Text("Total \(viewModel.boardViewModel.tileCount); Placed: \(viewModel.boardViewModel.placedCount); Committed: \(viewModel.boardViewModel.committedCount)")
//                .foregroundStyle(PlacementStatus.getColor(for: viewModel.wordValidator.placementState))
        }
    }
}
