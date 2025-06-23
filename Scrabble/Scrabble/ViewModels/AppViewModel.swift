//
//  AppViewModel.swift
//  Scrabble
//
//  Created by Eric Johns on 6/21/25.
//

import Foundation

enum AppPage {
    case mainMenu, multiplayer, boardSelector, game
}

@MainActor
class AppViewModel: ObservableObject {
    @Published var currentPage: AppPage = .mainMenu
    @Published var boardIdentifier: BoardIdentifier = .diamond11
    
    private var defaultWordSet: Set<String> = []
    
    init() {
        print("Loading all words from resources...")
        
        if let wordSetPath = Bundle.main.path(forResource: "WordList", ofType: "txt") {
            if let fileContents = try? String(contentsOfFile: wordSetPath, encoding: .utf8) {
                defaultWordSet = Set(fileContents.components(separatedBy: .newlines).filter { !$0.isEmpty })
            }
        }
        
        print("Loaded \(defaultWordSet.count) words")
    }
    
    func getWordSet() -> Set<String> {
        return defaultWordSet
    }
    
    func endGame(finalGameStats: GameStats) {
        // TODO: track user stats
        print(String(describing: finalGameStats))
        
        print("Score: \(finalGameStats.score)")
        print("Word Count: \(finalGameStats.words)")
        print("Moves: \(finalGameStats.moves)")
        print("Tiles: \(finalGameStats.tiles)")
    }
}
