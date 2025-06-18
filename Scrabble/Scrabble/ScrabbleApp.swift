//
//  ScrabbleApp.swift
//  Scrabble
//
//  Created by Eric Johns on 5/18/25.
//

import SwiftUI

@main
struct ScrabbleApp: App {
    @StateObject private var popupManager: PopupManager
    @StateObject private var gameViewModel: GameViewModel
    
    init() {
        let popupManager = PopupManager()
        
        _popupManager = StateObject(wrappedValue: popupManager)
        _gameViewModel = StateObject(wrappedValue: GameViewModel(popupManager: popupManager))
    }
    
    var body: some Scene {
        WindowGroup {
            GameView()
                .environmentObject(popupManager)
                .environmentObject(gameViewModel)
        }
    }
}
