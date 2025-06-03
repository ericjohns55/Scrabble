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
                    viewModel.recallTiles()
                }) {
                    Text("Recall Tiles")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .contentShape(Rectangle())
                .border(.gray)
                .padding(10)
                
                
                Button(action: {
                    viewModel.commitTiles()
                }) {
                    Text("Commit Tiles")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .contentShape(Rectangle())
                .border(.gray)
                .padding(10)
            }
            .frame(maxWidth: .infinity, maxHeight: buttonHeight)
        }
    }
}
