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
    @EnvironmentObject var popupManager: PopupManager
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
                .onTapGesture {
                    popupManager.displayActionSheet(title: "Scrabble Board", message: "Select a board type to load", buttons: [
                        .default(Text("Diamond 9x9")) { viewModel.changeBoard(newBoardIdentifier: .diamond9) },
                        .default(Text("Diamond 11x11")) { viewModel.changeBoard(newBoardIdentifier: .diamond11) },
                        .default(Text("Diamond 13x13")) { viewModel.changeBoard(newBoardIdentifier: .diamond13) },
                        .default(Text("X 9x9")) { viewModel.changeBoard(newBoardIdentifier: .x9) },
                        .default(Text("X 11x11")) { viewModel.changeBoard(newBoardIdentifier: .x11) },
                        .default(Text("X 13x13")) { viewModel.changeBoard(newBoardIdentifier: .x13) },
                        .cancel()
                    ])
                }
            
            HStack {
                Text("Moves: \(viewModel.totalMoves)")
                    .foregroundStyle(.white)
                    .font(.title2)
                    .padding(.bottom, 8)
                    .padding(.leading, 4)
                
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
                    .padding(.trailing, 4)
            }
            
            BoardView(viewModel: viewModel, dragManager: dragManager)
                .aspectRatio(1, contentMode: .fit)
                .padding(.bottom, 8)

            TileRackView(viewModel: viewModel, dragManager: dragManager)
                .padding(.bottom, 8)
            
            HStack {
                Button(action: {
                    popupManager.displayConfirmationDialog(message: "Are you sure you want to restart?", confirmAction: {
                        viewModel.setupGame()
                    }, cancelAction: {
                        viewModel.changeBoard(newBoardIdentifier: .diamond13)
                    })
                }) {
                    Text("Reset Game")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .contentShape(Rectangle())
                .border(.gray)
                .padding(.horizontal, 4)
                .padding(.vertical, 10)
                
                Button(action: {
                    viewModel.shuffleOrRecall()
                }) {
                    Text(viewModel.canShuffle() ? "Shuffle Tiles" : "Recall Tiles")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .contentShape(Rectangle())
                .border(.gray)
                .padding(.horizontal, 4)
                .padding(.vertical, 10)
                
                Button(action: {
                    viewModel.commitTiles()
                }) {
                    Text("Submit Word")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .contentShape(Rectangle())
                .border(.gray)
                .padding(.horizontal, 4)
                .padding(.vertical, 10)
                .disabled(viewModel.wordValidator.placementState != .valid)
                
                // NEXT: discard
            }
            .frame(maxWidth: .infinity, maxHeight: buttonHeight)
            
            VStack {
                Text(PlacementStatus.getMessage(for: viewModel.wordValidator.placementState))
                    .font(.title2)
                    .foregroundStyle(.white)
                    .bold()
                
                if (viewModel.wordValidator.currentValidWords != "") {
                    Text("Valid Words: \(viewModel.wordValidator.currentValidWords)")
                        .foregroundStyle(.green)
                } else {
                    Text("No valid words present")
                        .foregroundStyle(textColor)
                }
                
                if (viewModel.wordValidator.currentInvalidWords != "") {
                    Text("Invalid Words: \(viewModel.wordValidator.currentInvalidWords)")
                        .foregroundStyle(.red)
                } else {
                    Text("No invalid words present")
                        .foregroundStyle(textColor)
                }
                               
                Text("Current Points: \(viewModel.wordValidator.currentPoints)")
                    .foregroundStyle(textColor)
                
                Text("Current Words: \(viewModel.wordValidator.wordCount)")
                    .foregroundStyle(textColor)
            }
        }
        .confirmationDialog(popupManager.confirmationDialogOptions.message,
                            isPresented: $popupManager.showConfirmationDialog,
                            titleVisibility: popupManager.confirmationDialogOptions.displayTitle ? .visible : .hidden) {
            Button("Confirm", role: .destructive) {
                popupManager.confirmationDialogOptions.confirmAction()
            }
            
            Button("Cancel", role: .cancel) {
                popupManager.confirmationDialogOptions.cancelAction()
            }
        }
        .actionSheet(isPresented: $popupManager.showActionSheet) {
            ActionSheet(title: Text(popupManager.actionSheetOptions.title),
                        message: Text(popupManager.actionSheetOptions.message),
                        buttons: popupManager.actionSheetOptions.buttons)
        }
        .toast(isPresenting: $popupManager.showToast,
               duration: popupManager.toastOptions.toastDuration,
               tapToDismiss: true) {
            AlertToast(displayMode: .alert,
                       type: popupManager.toastOptions.toastType,
                       title: popupManager.toastOptions.toastText,
                       style: .style(backgroundColor: popupManager.toastOptions.toastColor))
        }
    }
}
