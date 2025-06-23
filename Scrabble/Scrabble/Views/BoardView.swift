//
//  BoardView.swift
//  Scrabble
//
//  Created by Eric Johns on 5/22/25.
//

import SwiftUI

struct GridFrame: Shape {
    var cornerRadius: CGFloat
    var lineWidth: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let insectRectangle = rect.insetBy(dx: lineWidth, dy: lineWidth)
        
        var path = Path()
        path.addRect(rect)
        path.addPath(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .path(in: insectRectangle))
        
        return path
    }
}

struct BoardView: View {
    @ObservedObject var viewModel: GameViewModel
    @ObservedObject var dragManager: DragManager
    
    @State private var lastOffset: CGSize = .zero
    @State private var isZoomedIn = false

    let FRAME_COLOR: Color = .black
    
    let columns: Array<GridItem>

    init(viewModel: GameViewModel, dragManager: DragManager) {
        self.viewModel = viewModel
        self.dragManager = dragManager
        
        columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: viewModel.boardManager.getGridSize())
    }
    
    var body: some View {
        GeometryReader { geometry in
            let boardSize = min(geometry.size.width, geometry.size.height)
            let tileSize = dragManager.boardFrame.width / CGFloat(viewModel.boardManager.getGridSize())
            
            let snapZoomGesture = MagnificationGesture()
                .onEnded { value in
                    let targetScale = dragManager.boardZoomScale * value
                    withAnimation(.easeInOut) {
                        dragManager.boardZoomScale = (targetScale > 1.5) ? 1.5 : 1.0
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
                    ForEach(viewModel.boardManager.board) { boardSquare in
                        ZStack {
                            Rectangle()
                                .stroke(FRAME_COLOR, lineWidth: 0.5)
                                .aspectRatio(1, contentMode: .fit)
                                .background(TileType.getTileColor(boardSquare.tileType))
                                .overlay(
                                    Text(TileType.getTileText(boardSquare.tileType))
                                        .font(.caption)
                                        .bold()
                                        .foregroundColor(.white)
                                )
                            
                            GridFrame(cornerRadius: 8, lineWidth: 1)
                                .fill(FRAME_COLOR, style: FillStyle(eoFill: true))
                        }
                    }
                }
                            
                ForEach($viewModel.committedTiles) { $tile in
                    createDraggableTile($tile, tileSize: tileSize)
                }

                ForEach($viewModel.playerTiles) { $tile in
                    if (tile.boardPosition != nil) {
                        createDraggableTile($tile, tileSize: tileSize)
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
    
    @ViewBuilder
    private func createDraggableTile(_ tile: Binding<Tile>, tileSize: CGFloat) -> some View {
        DraggableTile(
            dragManager: dragManager,
            viewModel: viewModel,
            tile: tile
        )
        .frame(width: tileSize, height: tileSize)
        .position(
            x: CGFloat(tile.boardPosition.wrappedValue!.col) * tileSize + tileSize / 2,
            y: CGFloat(tile.boardPosition.wrappedValue!.row) * tileSize + tileSize / 2
        )
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
