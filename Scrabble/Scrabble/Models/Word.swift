//
//  Word.swift
//  Scrabble
//
//  Created by Eric Johns on 6/14/25.
//

enum WordOrientation {
    case horizontal, vertical
}

class Word {
    private var boardSquares: [BoardSquare]
    private var wordOrientation: WordOrientation
    
    init(boardSquares: [BoardSquare], wordOrientation: WordOrientation) {
        self.boardSquares = boardSquares
        self.wordOrientation = wordOrientation
    }
    
    func getWord() -> String {
        var wordBuilder: String = ""
        
        if (wordOrientation == .horizontal) {
            let sortedSquares = boardSquares.sorted(by: { $0.column < $1.column })
            
            for square in sortedSquares {
                wordBuilder.append(square.tile!.letter)
            }
        } else {
            let sortedSquares = boardSquares.sorted(by: { $0.row < $1.row })
            
            for square in sortedSquares {
                wordBuilder.append(square.tile!.letter)
            }
        }
        
        return wordBuilder
    }
    
    func connectedToExistingTiles() -> Bool {
        return boardSquares.contains(where: { $0.tile?.tileState == .committedToBoard })
    }
}
