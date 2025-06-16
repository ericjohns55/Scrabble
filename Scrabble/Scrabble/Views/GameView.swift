//
//  GameView.swift
//  Scrabble
//
//  Created by Eric Johns on 5/22/25.
//

import AlertToast
import SwiftUI

class DragManager: ObservableObject {
    @Published var boardFrame: CGRect = .zero
    @Published var dropLocationInBoard: CGPoint?
    @Published var boardZoomScale: CGFloat = 1.0
    @Published var boardOffset: CGSize = .zero
}

struct GameView: View {
    @EnvironmentObject var toastManager: ToastManager
    @EnvironmentObject var viewModel: GameViewModel
    
    @StateObject private var dragManager = DragManager()
    
    var textColor: Color {
        PlacementStatus.getColor(for: viewModel.wordValidator.placementState)
    }
    
    private let buttonHeight: CGFloat = 72
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Scrabble")
                .foregroundStyle(.white)
                .font(.title)
                .bold()
                .padding(.bottom, 8)
            
            HStack {
                Text("Moves: \(viewModel.totalMoves)")
                    .foregroundStyle(.white)
                    .font(.title2)
                    .padding(.bottom, 8)
                
                Spacer()
                
                Text("Score: \(viewModel.totalScore)")
                    .foregroundStyle(.white)
                    .font(.title2)
                    .padding(.bottom, 8)
                
                Spacer()
                
                Text("Words: \(viewModel.totalWords)")
                    .foregroundStyle(.white)
                    .font(.title2)
                    .padding(.bottom, 8)
            }
            
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
                
//                Button(action: {
//                    toastManager.displayToast(text: "Test", color: .gray, alertType: .error(.red))
//                }) {
//                    Text("Redraw")
//                        .frame(maxWidth: .infinity, maxHeight: .infinity)
//                }
//                .contentShape(Rectangle())
//                .border(.gray)
//                .padding(10)
                
                // NEXT: discard
            }
            .frame(maxWidth: .infinity, maxHeight: buttonHeight)
            
            Text("Tile Placement: \(viewModel.wordValidator.placementState)")
                .foregroundStyle(textColor)
            
            Text("Valid Words: \(viewModel.wordValidator.currentValidWords)")
                .foregroundStyle(textColor)
            
            Text("Invalid Words: \(viewModel.wordValidator.currentInvalidWords)")
                .foregroundStyle(textColor)
            
            Text("Current Points: \(viewModel.wordValidator.currentPoints)")
                .foregroundStyle(textColor)
            
            Text("Current Words: \(viewModel.wordValidator.wordCount)")
                .foregroundStyle(textColor)
        }
        .toast(isPresenting: $toastManager.showToast,
               duration: toastManager.toastDuration,
               tapToDismiss: true) {
            AlertToast(displayMode: .alert,
                       type: toastManager.toastType,
                       title: toastManager.toastText,
                       style: .style(backgroundColor: toastManager.toastColor))
        }
    }
}
