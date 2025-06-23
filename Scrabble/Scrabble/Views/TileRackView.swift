//
//  TileRackView.swift
//  Scrabble
//
//  Created by Eric Johns on 5/22/25.
//

import SwiftUI

struct TileRackView: View {
    @ObservedObject var viewModel: GameViewModel
    @ObservedObject var dragManager: DragManager
    
    @State private var tileHeight: CGFloat = 20
    @State private var draggingTileId: UUID? = nil
    
    let extraHeightPadding: CGFloat = 8
    let widthPadding: CGFloat = 24
    
    var body: some View {
        VStack {
            GeometryReader { geo in
                let totalWidth = geo.size.width - widthPadding
                let tileCount = viewModel.maxTiles
                let spacing: CGFloat = 4
                let availableWidth = totalWidth - CGFloat(tileCount - 1) * spacing
                let adjustedTileSize = availableWidth / CGFloat(tileCount)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        .onAppear {
                            tileHeight = adjustedTileSize
                        }
                    
                    ForEach($viewModel.playerTiles) { $tile in
                        if (tile.tileState == .inPlayerHand) {
                            TileView(tile: tile, size: adjustedTileSize)
                                .position(rackPosition(for: tile, tileSize: adjustedTileSize, spacing: spacing)
                                    .applying(CGAffineTransform(translationX: 0, y: extraHeightPadding / 2)))
                                .offset(tile.offset)
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            tile.offset = value.translation
                                            draggingTileId = tile.id
                                        }
                                        .onEnded { value in
                                            let localDropPoint = value.location
                                            tile.offset = .zero
                                                                                        
                                            if (localDropPoint.y > 0) {
                                                // Rearrange tile rack
                                                
                                                if let fromIndex = viewModel.playerTiles.firstIndex(where: { $0.id == tile.id }) {
                                                    let toIndex = indexForDropLocation(localDropPoint, tileSize: adjustedTileSize, spacing: spacing)
                                                    
                                                    if (fromIndex != toIndex) {
                                                        let toOffset = toIndex > fromIndex ? toIndex + 1 : toIndex
                                                        
                                                        viewModel.playerTiles.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toOffset)
                                                    }
                                                }
                                            } else {
                                                // Drop on board by converting global point into board's coordinate space
                                                
                                                let dropPointInBoard = convertGlobalToBoardPoint(
                                                    globalPoint: value.locationInViewGlobal(in: geo),
                                                    boardOrigin: dragManager.boardFrame.origin,
                                                    boardSize: dragManager.boardFrame.width,
                                                    boardOffset: dragManager.boardOffset,
                                                    zoomScale: dragManager.boardZoomScale)
                                                
                                                viewModel.updateTilePosition(tile.id, to: dropPointInBoard, dragManager: dragManager)
                                            }
                                            
                                            draggingTileId = nil
                                        }
                                )
                                .animation(.easeInOut(duration: 0.2), value: tile.offset)
                        }
                    }
                }
            }.frame(height: tileHeight + extraHeightPadding)
        }
    }
    
    func convertGlobalToBoardPoint(globalPoint: CGPoint, boardOrigin: CGPoint, boardSize: CGFloat, boardOffset: CGSize, zoomScale: CGFloat) -> CGPoint {
        let localX = globalPoint.x - boardOrigin.x
        let localY = globalPoint.y - boardOrigin.y
        
        let centerX = boardSize / 2
        let centerY = boardSize / 2
        
        let centeredX = localX - centerX
        let centeredY = localY - centerY
        
        let unpannedX = centeredX - boardOffset.width
        let unpannedY = centeredY - boardOffset.height
        
        let unscaledX = unpannedX / zoomScale
        let unscaledY = unpannedY / zoomScale
        
        let boardX = unscaledX + centerX
        let boardY = unscaledY + centerY
        
        return CGPoint(x: boardX, y: boardY)
    }


    private func rackPosition(for tile: Tile, tileSize: CGFloat, spacing: CGFloat) -> CGPoint {
        let index = $viewModel.playerTiles.firstIndex(where: { $0.id == tile.id})!
        
        let x = CGFloat(index) * (tileSize + spacing) + tileSize / 2 + widthPadding / 2
        let y = tileSize / 2
        return CGPoint(x: x, y: y)
    }
    
    private func indexForDropLocation(_ location: CGPoint, tileSize: CGFloat, spacing: CGFloat) -> Int {
        let tileWidthWithSpacing = tileSize + spacing
        let index = Int((location.x - widthPadding / 2) / tileWidthWithSpacing)
        return min(max(index, 0), viewModel.playerTiles.count - 1)
    }
}

extension DragGesture.Value {
    func locationInViewGlobal(in geo: GeometryProxy) -> CGPoint {
        let viewOrigin = geo.frame(in: .named("boardSpace")).origin
        return CGPoint(
            x: viewOrigin.x + self.location.x,
            y: viewOrigin.y + self.location.y
        )
    }
}
