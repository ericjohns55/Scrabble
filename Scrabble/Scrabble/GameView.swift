//
//  ContentView.swift
//  Scrabble
//
//  Created by Eric Johns on 5/18/25.
//

import SwiftUI

struct GameView: View {
    @StateObject var scrabbleController = ScrabbleController()
    
    var body: some View {
        VStack {
            ScrabbleBoardView(scrabbleController: scrabbleController)
            TileRackView(scrabbleController: scrabbleController)
            
            Button("Test") {
                _ = scrabbleController.placeTile(Tile(letter: "A", points: 3), row: 4, col: 4)
            }
        }
    }
}

#Preview {
    GameView()
}
