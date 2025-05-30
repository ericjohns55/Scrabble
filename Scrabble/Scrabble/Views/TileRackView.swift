//
//  TileRackView.swift
//  Scrabble
//
//  Created by Eric Johns on 5/22/25.
//

import SwiftUI

struct TileRackView: View {
    @ObservedObject var dragManager: DragManager
    
    @Binding var tiles: [Tile]
    let onTileDrop: (UUID, CGPoint) -> Void

    var body: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            let tileCount = tiles.count
            let spacing: CGFloat = 4
            let availableWidth = totalWidth - CGFloat(tileCount - 1) * spacing
            let adjustedTileSize = availableWidth / CGFloat(tileCount)

            ZStack {
                ForEach($tiles) { $tile in
                    if tile.boardPosition == nil {
                        TileView(letter: tile.letter, size: adjustedTileSize)
                            .position(rackPosition(for: tile, tileSize: adjustedTileSize, spacing: spacing))
                            .offset(tile.offset)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        tile.offset = value.translation
                                    }
                                    .onEnded { value in
                                        let globalDropPoint = value.locationInViewGlobal(in: geo)
                                        
                                        // convert global point into board's coordinate space
                                        let boardOrigin = dragManager.boardFrame.origin
                                        let dropPointInBoard = CGPoint(
                                            x: globalDropPoint.x - boardOrigin.x,
                                            y: globalDropPoint.y - boardOrigin.y
                                        )

                                        tile.offset = .zero
                                        onTileDrop(tile.id, dropPointInBoard)
                                    }
                            )
                            .animation(.easeInOut(duration: 0.2), value: tile.offset)
                    }
                }
            }
        }
    }

    private func rackPosition(for tile: Tile, tileSize: CGFloat, spacing: CGFloat) -> CGPoint {
        guard let index = tiles.firstIndex(where: { $0.id == tile.id }) else {
            return .zero
        }

        let x = CGFloat(index) * (tileSize + spacing) + tileSize / 2
        let y = tileSize / 2 + 10
        return CGPoint(x: x, y: y)
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
