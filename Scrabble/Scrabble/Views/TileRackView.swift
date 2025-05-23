//
//  TileRack.swift
//  Scrabble
//
//  Created by Eric Johns on 5/18/25.
//

import SwiftUI

struct TileRackView: View {
    @ObservedObject var scrabbleController: ScrabbleController
    
    var body: some View {
        HStack {
            ForEach(scrabbleController.availableTiles) { tile in
                Text(tile.letter)
                    .font(.title)
                    .frame(width: 40, height: 40)
                    .background(Color.yellow)
                    .cornerRadius(8)
                    .onDrag {
                        let data = try! JSONEncoder().encode(tile)
                        var jsonString = String(data: data, encoding: .utf8)!
                    
                        print("Drag event")
                        return NSItemProvider(object: jsonString as NSString)
                    }
            }
        }
    }
}


#Preview {
    TileRackView(scrabbleController: ScrabbleController())
}
