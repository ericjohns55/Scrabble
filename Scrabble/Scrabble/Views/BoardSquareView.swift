//
//  BoardSquare.swift
//  Scrabble
//
//  Created by Eric Johns on 5/18/25.
//

import SwiftUI

struct BoardSquareView: View {
    var square: BoardSquare
    var dropAction: (BoardSquare) -> Void
    
    var body: some View {
        ZStack {
            Rectangle()
                .stroke(Color.gray, lineWidth: 1)
                .background(Color.white)
            
            if let tile = square.tile {
                Text(tile.letter)
                    .foregroundColor(.black)
                    .font(.title3)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onDrop(of: [.text], isTargeted: nil) { providers in
            print("Drop event")
            if let provider = providers.first {
                print("In provider")
                provider.loadItem(forTypeIdentifier: "public.text", options: nil) { (data, _) in
                    DispatchQueue.main.async {
                        dropAction(square)
                    }
                }
                
                return true
            }
            
            return false
        }
    }
}


//#Preview {
//    BoardSquareView(square: BoardSquare(tile: Tile(letter: "A", points: 3)))
//}
