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
    @StateObject private var confirmationDialogManager: ConfirmationDialogManager
    
    init() {
        let toastManager = ToastManager()
        let confirmationDialogManager = ConfirmationDialogManager()
        
        _toastManager = StateObject(wrappedValue: toastManager)
        _confirmationDialogManager = StateObject(wrappedValue: confirmationDialogManager)
        _gameViewModel = StateObject(wrappedValue: GameViewModel(toastManager: toastManager))
    }
    
    var body: some Scene {
        WindowGroup {
            GameView()
                .environmentObject(toastManager)
                .environmentObject(gameViewModel)
                .environmentObject(confirmationDialogManager)
        }
    }
}
