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
    
    @State private var lastOffset: CGSize = .zero
    @State private var isZoomedIn = false

    let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 15)

    var body: some View {
        GeometryReader { geometry in
            let boardSize = min(geometry.size.width, geometry.size.height)
            
            let snapZoomGesture = MagnificationGesture()
                .onEnded { value in
                    let targetScale = dragManager.boardZoomScale * value
                    withAnimation(.easeInOut) {
                        dragManager.boardZoomScale = (targetScale > 1.5) ? 2.0 : 1.0
                        isZoomedIn = dragManager.boardZoomScale > 1.0
                        dragManager.boardOffset = .zero
                        lastOffset = .zero
                    }
                }
            
            let dragGesture = DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if (isZoomedIn) {
                        let proposedOffset = CGSize(
                            width: lastOffset.width + value.translation.width,
                            height: lastOffset.height + value.translation.height)
                        
                        let scaledSize = boardSize * dragManager.boardZoomScale
                        let maxOffsetX = (scaledSize - boardSize) / 2
                        let maxOffsetY = (scaledSize - boardSize) / 2
                        
                        dragManager.boardOffset = CGSize(
                            width: proposedOffset.width.clamped(to: -maxOffsetX...maxOffsetX),
                            height: proposedOffset.height.clamped(to: -maxOffsetY...maxOffsetY))
                    }
                }
                .onEnded { _ in
                    if (isZoomedIn) {
                        lastOffset = dragManager.boardOffset
                    }
                }
            
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
            .frame(width: boardSize, height: boardSize)
            .scaleEffect(dragManager.boardZoomScale)
            .offset(dragManager.boardOffset)
            .clipped()
            .animation(.easeInOut(duration: 0.3), value: dragManager.boardZoomScale)
            .gesture(dragGesture)
            .simultaneousGesture(snapZoomGesture)
            .onAppear {
                dragManager.boardFrame = geometry.frame(in: .global)
            }
        }
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
