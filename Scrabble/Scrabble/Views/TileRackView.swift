//
//  TileRackView.swift
//  Scrabble
//
//  Created by Eric Johns on 5/22/25.
//

import SwiftUI

struct TileRackView: View {
    @Binding var tiles: [Tile]
    let tileSize: CGFloat
    let boardFrame: CGRect
    let onTileDrop: (UUID, CGPoint) -> Void

    @State private var globalFrames: [UUID: CGRect] = [:]

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
                            .background(
                                GeometryReader { tileGeo in
                                    Color.clear
                                        .preference(
                                            key: TileDropOriginKey.self,
                                            value: [tile.id: tileGeo.frame(in: .global)]
                                        )
                                }
                            )
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        tile.offset = value.translation
                                    }
                                    .onEnded { value in
                                        let frame = globalFrames[tile.id] ?? .zero
                                        
                                        let dropPoint = CGPoint(
                                            x: frame.origin.x + tileSize / 2 + value.translation.width,
                                            y: frame.origin.y + tileSize / 2 + value.translation.height
                                        )
                                        tile.offset = .zero
                                        onTileDrop(tile.id, dropPoint)
                                    }
                            )
                            .animation(.easeInOut(duration: 0.2), value: tile.offset)
                    }
                }
            }
            .onPreferenceChange(TileDropOriginKey.self) { newFrames in
                globalFrames.merge(newFrames) { _, new in new }
            }
        }
        .frame(height: tileSize + 20)
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

// MARK: - PreferenceKey
private struct TileDropOriginKey: PreferenceKey {
    static var defaultValue: [UUID: CGRect] = [:]
    static func reduce(value: inout [UUID: CGRect], nextValue: () -> [UUID: CGRect]) {
        value.merge(nextValue()) { _, new in new }
    }
}

