//
//  ScrabbleBoardView.swift
//  Scrabble
//
//  Created by Eric Johns on 5/18/25.
//

import SwiftUI
//
//@ObservedObject var scrabbleController: ScrabbleController

struct ScrabbleBoardView: View {
    @ObservedObject var scrabbleController: ScrabbleController
    @State private var zoomScale: CGFloat = 1.0
    @State private var isZoomed: Bool = false

    @GestureState private var dragOffset: CGSize = .zero
    @State private var finalOffset: CGSize = .zero

    var body: some View {
        GeometryReader { geometry in
            let containerSize = min(geometry.size.width, geometry.size.height)
            let tileCount = scrabbleController.board.count
            let tileSize = containerSize / CGFloat(tileCount)

            let scale = zoomScale
            let scaledBoardSize = containerSize * scale
            let maxOffset = max((scaledBoardSize - containerSize) / 2, 0)

            let rawOffset = CGSize(
                width: finalOffset.width + dragOffset.width,
                height: finalOffset.height + dragOffset.height
            )
            let clampedOffset = CGSize(
                width: max(-maxOffset, min(rawOffset.width, maxOffset)),
                height: max(-maxOffset, min(rawOffset.height, maxOffset))
            )

            ZStack {
                Color.clear

                ZStack {
                    VStack(spacing: 0) {
                        ForEach(0..<tileCount, id: \.self) { row in
                            HStack(spacing: 0) {
                                ForEach(0..<tileCount, id: \.self) { col in
                                    let square = scrabbleController.board[row][col]
                                    
                                    BoardSquareView(square: square, dropAction: { boardSquare in
                                        print("DROP")
                                        let tile = Tile(letter: boardSquare.tile?.letter ?? "Z", points: 2)
                                        
                                        print("Place event at \(row)x\(col)")
                                        
                                        _ = scrabbleController.placeTile(tile, row: row, col: col)
                                    })
                                    .aspectRatio(1, contentMode: .fit)
                                    .frame(width: tileSize)
                                }
                            }
                        }
                    }
                    .frame(width: containerSize, height: containerSize)
                    .scaleEffect(scale)
                    .offset(clampedOffset)
                    .gesture(
                        TapGesture(count: 2).onEnded {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isZoomed.toggle()
                                zoomScale = isZoomed ? 2.0 : 1.0
                                if !isZoomed {
                                    finalOffset = .zero
                                }
                            }
                        }
                    )
                    .gesture(
                        isZoomed ?
                        DragGesture()
                            .updating($dragOffset) { value, state, _ in
                                state = value.translation
                            }
                            .onEnded { value in
                                let newOffset = CGSize(
                                    width: finalOffset.width + value.translation.width,
                                    height: finalOffset.height + value.translation.height
                                )
                                finalOffset = CGSize(
                                    width: max(-maxOffset, min(newOffset.width, maxOffset)),
                                    height: max(-maxOffset, min(newOffset.height, maxOffset))
                                )
                            }
                        : nil
                    )
                }
                .frame(width: containerSize, height: containerSize)
                .clipped()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.clear)
        }
    }
}

#Preview {
    ScrabbleBoardView(scrabbleController: ScrabbleController())
}
