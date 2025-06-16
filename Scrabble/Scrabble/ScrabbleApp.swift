//
//  ScrabbleApp.swift
//  Scrabble
//
//  Created by Eric Johns on 5/18/25.
//

import SwiftUI

@main
struct ScrabbleApp: App {
    @StateObject private var toastManager: ToastManager
    @StateObject private var gameViewModel: GameViewModel
    
    init() {
        let toastManager = ToastManager()
        
        _toastManager = StateObject(wrappedValue: toastManager)
        _gameViewModel = StateObject(wrappedValue: GameViewModel(toastManager: toastManager))
    }
    
    var body: some Scene {
        WindowGroup {
            GameView()
                .environmentObject(toastManager)
                .environmentObject(gameViewModel)
        }
    }
}
