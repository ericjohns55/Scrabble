//
//  BoardSetup.swift
//  Scrabble
//
//  Created by Eric Johns on 6/17/25.
//

import UIKit

enum BoardIdentifier: String, Codable, CaseIterable {
    case diamond9, diamond11, diamond13, x9, x11, x13
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self).lowercased()
        
        if let match = BoardIdentifier.allCases.first(where: { $0.rawValue.lowercased() == rawValue }) {
            self = match
        } else {
            print("Could not decode enum value: \(rawValue)")
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Could not decode enum value: \(rawValue)"))
        }
    }
    
    static func getBoardSize(_ identifier: BoardIdentifier) -> Int {
        switch identifier {
            case .diamond9, .x9:
                return 9
            case .diamond11, .x11:
                return 11
            case .diamond13, .x13:
                return 13
        }
    }
    
    static func getLabel(_ identifier: BoardIdentifier) -> String {
        switch identifier {
            case .diamond9:
                return "Diamond 9x9"
            case .x9:
                return "X 9x9"
            case .diamond11:
                return "Diamond 11x11"
            case .x11:
                return "X 11x11"
            case .diamond13:
                return "Diamond 13x13"
            case .x13:
                return "X 13x13"
        }
    }
    
    static func getImage(_ identifier: BoardIdentifier) -> UIImage {
        switch identifier {
            case .diamond9:
                return UIImage(named: "diamond9")!
            case .x9:
                return UIImage(named: "x9")!
            case .diamond11:
                return UIImage(named: "diamond11")!
            case .x11:
                return UIImage(named: "x11")!
            case .diamond13:
                return UIImage(named: "diamond13")!
            case .x13:
                return UIImage(named: "x13")!
        }
    }
}

class BoardSetup {
    private static let Diamond9x9: [[Int]] = [
        [0, 0, 5, 0, 0, 0, 5, 0, 0],
        [0, 3, 0, 0, 4, 0, 0, 3, 0],
        [5, 0, 0, 2, 0, 2, 0, 0, 5],
        [0, 0, 2, 0, 0, 0, 2, 0, 0],
        [0, 4, 0, 0, 1, 0, 0, 4, 0],
        [0, 0, 2, 0, 0, 0, 2, 0, 0],
        [5, 0, 0, 2, 0, 2, 0, 0, 5],
        [0, 3, 0, 0, 4, 0, 0, 3, 0],
        [0, 0, 5, 0, 0, 0, 5, 0, 0]
    ]
    
    private static let X9x9: [[Int]] = [
        [5, 0, 0, 2, 0, 2, 0, 0, 5],
        [0, 3, 0, 0, 4, 0, 0, 3, 0],
        [0, 0, 4, 0, 0, 0, 4, 0, 0],
        [2, 0, 0, 0, 0, 0, 0, 0, 2],
        [0, 4, 0, 0, 1, 0, 0, 4, 0],
        [2, 0, 0, 0, 0, 0, 0, 0, 2],
        [0, 0, 4, 0, 0, 0, 4, 0, 0],
        [0, 3, 0, 0, 4, 0, 0, 3, 0],
        [5, 0, 0, 2, 0, 2, 0, 0, 5]
    ]
    
    private static let Diamond11x11: [[Int]] = [
        [0, 0, 0, 5, 0, 0, 0, 5, 0, 0, 0],
        [0, 0, 3, 0, 0, 4, 0, 0, 3, 0, 0],
        [0, 3, 0, 0, 2, 0, 2, 0, 0, 3, 0],
        [5, 0, 0, 3, 0, 0, 0, 3, 0, 0, 5],
        [0, 0, 2, 0, 0, 0, 0, 0, 2, 0, 0],
        [0, 4, 0, 0, 0, 1, 0, 0, 0, 4, 0],
        [0, 0, 2, 0, 0, 0, 0, 0, 2, 0, 0],
        [5, 0, 0, 3, 0, 0, 0, 3, 0, 0, 5],
        [0, 3, 0, 0, 2, 0, 2, 0, 0, 3, 0],
        [0, 0, 3, 0, 0, 4, 0, 0, 3, 0, 0],
        [0, 0, 0, 5, 0, 0, 0, 5, 0, 0, 0]
    ]
    
    private static let X11x11: [[Int]] = [
        [0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0],
        [0, 5, 0, 0, 3, 0, 3, 0, 0, 5, 0],
        [0, 0, 3, 0, 0, 4, 0, 0, 3, 0, 0],
        [2, 0, 0, 4, 0, 0, 0, 4, 0, 0, 2],
        [0, 3, 0, 0, 0, 0, 0, 0, 0, 3, 0],
        [0, 0, 4, 0, 0, 1, 0, 0, 4, 0, 0],
        [0, 3, 0, 0, 0, 0, 0, 0, 0, 3, 0],
        [2, 0, 0, 4, 0, 0, 0, 4, 0, 0, 2],
        [0, 0, 3, 0, 0, 4, 0, 0, 3, 0, 0],
        [0, 5, 0, 0, 3, 0, 3, 0, 0, 5, 0],
        [0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0]
    ]
    
    private static let Diamond13x13: [[Int]] = [
        [0, 0, 0, 0, 5, 0, 0, 0, 5, 0, 0, 0, 0],
        [0, 0, 0, 3, 0, 0, 0, 0, 0, 3, 0, 0, 0],
        [0, 0, 2, 0, 0, 0, 4, 0, 0, 0, 2, 0, 0],
        [0, 3, 0, 0, 0, 2, 0, 2, 0, 0, 0, 3, 0],
        [5, 0, 0, 0, 3, 0, 0, 0, 3, 0, 0, 0, 5],
        [0, 0, 0, 2, 0, 0, 0, 0, 0, 2, 0, 0, 0],
        [0, 0, 4, 0, 0, 0, 1, 0, 0, 0, 4, 0, 0],
        [0, 0, 0, 2, 0, 0, 0, 0, 0, 2, 0, 0, 0],
        [5, 0, 0, 0, 3, 0, 0, 0, 3, 0, 0, 0, 5],
        [0, 3, 0, 0, 0, 2, 0, 2, 0, 0, 0, 3, 0],
        [0, 0, 2, 0, 0, 0, 4, 0, 0, 0, 2, 0, 0],
        [0, 0, 0, 3, 0, 0, 0, 0, 0, 3, 0, 0, 0],
        [0, 0, 0, 0, 5, 0, 0, 0, 5, 0, 0, 0, 0]
    ]
    
    private static let X13x13: [[Int]] = [
        [5, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 5],
        [0, 4, 0, 0, 0, 3, 0, 3, 0, 0, 0, 4, 0],
        [0, 0, 2, 0, 0, 0, 5, 0, 0, 0, 2, 0, 0],
        [0, 0, 0, 3, 0, 0, 0, 0, 0, 3, 0, 0, 0],
        [2, 0, 0, 0, 4, 0, 0, 0, 4, 0, 0, 0, 2],
        [0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0],
        [0, 0, 5, 0, 0, 0, 1, 0, 0, 0, 5, 0, 0],
        [0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0],
        [2, 0, 0, 0, 4, 0, 0, 0, 4, 0, 0, 0, 2],
        [0, 0, 0, 3, 0, 0, 0, 0, 0, 3, 0, 0, 0],
        [0, 0, 2, 0, 0, 0, 5, 0, 0, 0, 2, 0, 0],
        [0, 4, 0, 0, 0, 3, 0, 3, 0, 0, 0, 4, 0],
        [5, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 5]
    ]
    
    static func getBoardTile(_ boardIdentifier: BoardIdentifier, row: Int, col: Int) -> TileType {
        var boardTileValue: Int = 0
        
        switch (boardIdentifier) {
            case .diamond9:
                boardTileValue = Diamond9x9[row][col]
                break
            case .x9:
                boardTileValue = X9x9[row][col]
                break
            case .diamond11:
                boardTileValue = Diamond11x11[row][col]
                break
            case .x11:
                boardTileValue = X11x11[row][col]
                break
            case .diamond13:
                boardTileValue = Diamond13x13[row][col]
                break
            case .x13:
                boardTileValue = X13x13[row][col]
                break
        }
        
        return TileType(rawValue: boardTileValue) ?? .empty
    }
}
