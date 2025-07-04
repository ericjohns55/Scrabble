//
//  BoardSelectorView.swift
//  Scrabble
//
//  Created by Eric Johns on 6/21/25.
//

import SwiftUI

struct BoardSelectorView: View {
    private var appViewModel: AppViewModel
    
    init(appViewModel: AppViewModel) {
        self.appViewModel = appViewModel
    }
    
    var body: some View {
        GeometryReader { geometry in
            let imageSize = geometry.size.width * 0.4
            
            VStack(spacing: 0) {
                Text("Select a Board")
                    .foregroundStyle(.white)
                    .font(.title)
                    .bold()
                    .padding(.vertical, 8)
                
                HStack {
                    boardImageButton(boardIdentifier: .diamond9, size: imageSize)
                    boardImageButton(boardIdentifier: .x9, size: imageSize)
                }
                
                HStack {
                    boardImageButton(boardIdentifier: .diamond11, size: imageSize)
                    boardImageButton(boardIdentifier: .x11, size: imageSize)
                }
                
                HStack {
                    boardImageButton(boardIdentifier: .diamond13, size: imageSize)
                    boardImageButton(boardIdentifier: .x13, size: imageSize)
                }
                                
                Button(action: {
                    appViewModel.currentPage = .mainMenu
                }) {
                    Text("Back to Main Menu")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(width: geometry.size.width * 0.5, height: geometry.size.width * 0.15)
                .contentShape(Rectangle())
                .border(.gray)
                .padding(.vertical, 8)
            }
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
    
    @ViewBuilder
    private func boardImageButton(boardIdentifier: BoardIdentifier, size: CGFloat) -> some View {
        VStack(spacing: 0) {
            Button(action: {
                loadBoard(boardIdentifier: boardIdentifier)
            }) {
                Image(String(describing: boardIdentifier))
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .border(.gray)
                    .padding(.horizontal, 12)
            }
            
            Text(BoardIdentifier.getLabel(boardIdentifier))
                .font(.system(size: 16))
                .foregroundStyle(.white)
        }
        .padding(.vertical, 8)
    }
    
    private func loadBoard(boardIdentifier: BoardIdentifier) {
        appViewModel.boardIdentifier = boardIdentifier
        appViewModel.currentPage = .game
    }
}
