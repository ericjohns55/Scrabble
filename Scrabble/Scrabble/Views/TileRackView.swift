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
    
    @State private var tileHeight: CGFloat = 20
    let extraHeightPadding: CGFloat = 8
    let widthPadding: CGFloat = 24

    var body: some View {
        VStack {
            GeometryReader { geo in
                let totalWidth = geo.size.width - widthPadding
                let tileCount = tiles.count
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
                    
                    ForEach($tiles) { $tile in
                        if tile.boardPosition == nil {
                            TileView(letter: tile.letter, size: adjustedTileSize)
                                .position(rackPosition(for: tile, tileSize: adjustedTileSize, spacing: spacing)
                                    .applying(CGAffineTransform(translationX: 0, y: extraHeightPadding / 2)))
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
            }.frame(height: tileHeight + extraHeightPadding)
        }
    }

    private func rackPosition(for tile: Tile, tileSize: CGFloat, spacing: CGFloat) -> CGPoint {
        guard let index = tiles.firstIndex(where: { $0.id == tile.id }) else {
            return .zero
        }

        let x = CGFloat(index) * (tileSize + spacing) + tileSize / 2 + widthPadding / 2
        let y = tileSize / 2
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
