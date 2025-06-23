//
//  ScrabbleApp.swift
//  Scrabble
//
//  Created by Eric Johns on 5/18/25.
//

import SwiftUI

@main
struct ScrabbleApp: App {
    @StateObject private var appViewModel: AppViewModel
    
    init() {
        _appViewModel = StateObject(wrappedValue: AppViewModel())
    }
    
    var body: some Scene {
        WindowGroup {
            MainMenu()
                .environmentObject(appViewModel)
        }
    }
}
