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
                let tileCount = viewModel.allTiles.filter { $0.tileState == .inPlayerHand || $0.tileState == .placedByPlayer }.count
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
                    
                    ForEach($viewModel.allTiles) { $tile in
                        if (viewModel.tileRack.contains($tile.id) && tile.tileState == .inPlayerHand) {
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
                                                
                                                if let fromIndex = viewModel.tileRack.firstIndex(of: tile.id) {
                                                    let toIndex = indexForDropLocation(localDropPoint, tileSize: adjustedTileSize, spacing: spacing)
                                                    
                                                    if (fromIndex != toIndex) {
                                                        let toOffset = toIndex > fromIndex ? toIndex + 1 : toIndex
                                                        
                                                        viewModel.tileRack.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toOffset)
                                                    }
                                                }
                                            } else {
                                                // Drop on board by converting global point into board's coordinate space
                                                
                                                let globalDropPoint = value.locationInViewGlobal(in: geo)
                                                let boardOrigin = dragManager.boardFrame.origin
                                                let dropPointInBoard = CGPoint(
                                                    x: globalDropPoint.x - boardOrigin.x,
                                                    y: globalDropPoint.y - boardOrigin.y)
                                                
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

    private func rackPosition(for tile: Tile, tileSize: CGFloat, spacing: CGFloat) -> CGPoint {
        let index = viewModel.tileRack.firstIndex(of: tile.id)!
        
        let x = CGFloat(index) * (tileSize + spacing) + tileSize / 2 + widthPadding / 2
        let y = tileSize / 2
        return CGPoint(x: x, y: y)
    }
    
    private func indexForDropLocation(_ location: CGPoint, tileSize: CGFloat, spacing: CGFloat) -> Int {
        let tileWidthWithSpacing = tileSize + spacing
        let index = Int((location.x - widthPadding / 2) / tileWidthWithSpacing)
        return min(max(index, 0), viewModel.tileRack.count - 1)
    }
}

extension DragGesture.Value {
    func locationInViewGlobal(in geo: GeometryProxy) -> CGPoint {
        let viewOrigin = geo.frame(in: .global).origin
        return CGPoint(
            x: viewOrigin.x + self.location.x,
            y: viewOrigin.y + self.location.y
        )
    }
}
