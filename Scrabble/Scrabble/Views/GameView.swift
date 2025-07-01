//
//  GameView.swift
//  Scrabble
//
//  Created by Eric Johns on 5/22/25.
//

import AlertToast
import SwiftUI

class DragManager: ObservableObject {
    @Published var boardFrame: CGRect = .zero
    @Published var dropLocationInBoard: CGPoint?
    @Published var boardZoomScale: CGFloat = 1.0
    @Published var boardOffset: CGSize = .zero
}

class BoardState: ObservableObject {
    @Published var wordCount: Int = 0
    @Published var currentPoints: Int = 0
    @Published var placementState: PlacementStatus = .none
    @Published var currentValidWords: String = ""
    @Published var currentInvalidWords: String = ""
    
    func updateTileState(_ placementStatus: PlacementStatus, validWords: Set<Word>? = nil, invalidWords: Set<Word>? = nil, points: Int = 0) {
        self.placementState = placementStatus
        self.currentPoints = points
        
        if (validWords != nil && invalidWords != nil) {
            self.currentValidWords = validWords!.map { "\($0)"}.joined(separator: ", ")
            self.currentInvalidWords = invalidWords!.map { "\($0)"}.joined(separator: ", ")
            self.wordCount = validWords!.count + invalidWords!.count
        } else {
            self.currentValidWords = ""
            self.currentInvalidWords = ""
            self.wordCount = 0
        }
    }
}

struct GameView: View {
    private var appViewModel: AppViewModel
    private var gameViewModel: GameViewModel
    
    @State private var inSummaryView = false
    @State private var boardRender: UIImage? = nil
    
    @StateObject private var popupManager = PopupManager()
    @StateObject private var dragManager = DragManager()
    @StateObject private var boardState = BoardState()
    
    var textColor: Color {
        PlacementStatus.getColor(for: boardState.placementState)
    }
    
    init(appViewModel: AppViewModel) {
        self.appViewModel = appViewModel
        
        let boardState = BoardState()
        self._boardState = StateObject(wrappedValue: boardState)
        
        self.gameViewModel = GameViewModel(boardIdentifier: appViewModel.boardIdentifier, boardState: boardState, wordSet: appViewModel.getWordSet())
    }
    
    var body: some View {
        VStack {
            if (inSummaryView) {
                SummaryGameView()
            } else {
                ActiveGameView(active: $inSummaryView, boardRender: $boardRender)
            }
        }
        .withPopupManager(popupManager)
    }
    
    @ViewBuilder
    func ActiveGameView(active: Binding<Bool>, boardRender: Binding<UIImage?>) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text("Moves: \(gameViewModel.gameStats.moves)")
                    .foregroundStyle(.white)
                    .font(.title2)
                    .padding(.bottom, 8)
                    .padding(.leading, 4)
                
                Spacer()
                
                Text("Score: \(gameViewModel.gameStats.score)")
                    .foregroundStyle(.white)
                    .font(.title2)
                    .padding(.bottom, 8)
                
                Spacer()
                
                Text("Words: \(gameViewModel.gameStats.words)")
                    .foregroundStyle(.white)
                    .font(.title2)
                    .padding(.trailing, 4)
            }
            
            Divider()
                .frame(height: 1)
                .background(Color.gray)
                .padding(.horizontal, 4)
        
            VStack {
                Text(PlacementStatus.getMessage(for: gameViewModel.boardState.placementState))
                    .font(.title2)
                    .foregroundStyle(.white)
                    .bold()
                
                HStack {
                    Spacer()
                    
                    Text("Current Points: \(gameViewModel.boardState.currentPoints)")
                        .foregroundStyle(textColor)
                    
                    Spacer()
                    
                    Text("Current Words: \(gameViewModel.boardState.wordCount)")
                        .foregroundStyle(textColor)
                    
                    Spacer()
                }
                
                wordsView()
            }
            
            BoardView(viewModel: gameViewModel, dragManager: dragManager)
                .aspectRatio(1, contentMode: .fit)

            TileRackView(viewModel: gameViewModel, dragManager: dragManager)
            
            VStack(spacing: 8) {
                HStack {
                    Button(action: {
                        popupManager.displayToast(text: "Not implemented", color: .red)
                    }) {
                        Text("Swap Tiles")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .contentShape(Rectangle())
                    .border(.gray)
                    .padding(.horizontal, 4)
                    
                    Button(action: {
                        popupManager.displayConfirmationDialog(message: "Are you sure you want to end the game?", confirmAction: {
                            appViewModel.endGame(finalGameStats: gameViewModel.gameStats)
                            
                            // TODO: add argument for showing points on the tiles and then not render them here
                            
                            let boardView = BoardView(viewModel: gameViewModel, dragManager: dragManager)
                                .aspectRatio(1, contentMode: .fit)
                                .frame(width: 512, height: 512)
                            
                            let renderer = ImageRenderer(content: boardView)
                            if let image = renderer.uiImage {
                                $boardRender.wrappedValue = image
                            }
                            
                            active.wrappedValue = true
                        })
                    }) {
                        Text("End Game")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .contentShape(Rectangle())
                    .border(.gray)
                    .padding(.horizontal, 4)
                    
                    Button(action: {
                        gameViewModel.shuffleOrRecall()
                    }) {
                        Text(gameViewModel.canShuffle() ? "Shuffle Tiles" : "Recall Tiles")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .contentShape(Rectangle())
                    .border(.gray)
                    .padding(.horizontal, 4)
                }
                .frame(maxWidth: .infinity, maxHeight: MainMenu.buttonHeight)
                
                Button(action: {
                    gameViewModel.commitTiles()
                }) {
                    Text("Submit Word")
                        .frame(maxWidth: .infinity, maxHeight: MainMenu.buttonHeight)
                }
                .contentShape(Rectangle())
                .border(.gray)
                .padding(.horizontal, 4)
                .disabled(gameViewModel.boardState.placementState != .valid)
            }
        }
    }
    
    @ViewBuilder
    func SummaryGameView() -> some View {
        VStack(spacing: 8) {
            Spacer()
            
            Text("Board Completed")
                .foregroundStyle(.white)
                .font(.title)
                .bold()
                .underline()
                .padding(.bottom, 8)
            
            Text("Words Played: \(gameViewModel.gameStats.words)")
                .foregroundStyle(.white)
                .font(.title2)
            
            Text("Final Score: \(gameViewModel.gameStats.score)")
                .foregroundStyle(.white)
                .font(.title2)
            
            Text("Tiles Played: \(gameViewModel.gameStats.tiles)")
                .foregroundStyle(.white)
                .font(.title2)
            
            Text("Moves Made: \(gameViewModel.gameStats.moves)")
                .foregroundStyle(.white)
                .font(.title2)
                .padding(.bottom, 24)
            
            GeometryReader { geo in
                let buttonWidth = geo.size.width * 0.5
                let imageWidth = geo.size.width * 0.75
                
                VStack(spacing: 8) {
                    Image(uiImage: boardRender ?? BoardIdentifier.getImage(appViewModel.boardIdentifier))
                        .resizable()
                        .scaledToFit()
                        .frame(width: imageWidth, height: imageWidth)
                        .border(.gray)
                        .onTapGesture {
                            // TODO: download image
                            popupManager.displayToast(text: "NOT IMPLEMENTED - Downloading image...", color: .gray)
                        }
                    
                    Text("Final Board")
                        .foregroundStyle(.white)
                        .font(.subheadline)
                        .padding(.bottom, 24)
                    
                    Button(action: {
                        appViewModel.currentPage = .boardSelector
                    }) {
                        Text("Board Selector")
                            .frame(maxWidth: buttonWidth, maxHeight: MainMenu.buttonHeight)
                    }
                    .contentShape(Rectangle())
                    .border(.gray)
                    .padding(.horizontal, 4)
                    .padding(.bottom, 4)
                    
                    Button(action: {
                        appViewModel.currentPage = .mainMenu
                    }) {
                        Text("Main Menu")
                            .frame(maxWidth: buttonWidth, maxHeight: MainMenu.buttonHeight)
                    }
                    .contentShape(Rectangle())
                    .border(.gray)
                    .padding(.horizontal, 4)
                }
                .frame(width: geo.size.width, alignment: .center)
            }
            
            Spacer()
        }
    }
    
    @ViewBuilder
    func wordsView() -> some View {
        let label = Text("Words: ")
            .foregroundStyle(textColor)
        
        let invalidWords = !gameViewModel.boardState.currentInvalidWords.isEmpty
            ? buildInvalidWords()
            : nil
        
        let validWords = !gameViewModel.boardState.currentValidWords.isEmpty
            ? Text(gameViewModel.boardState.currentValidWords).foregroundStyle(textColor)
            : nil
        
        let commaBetweenWords = invalidWords != nil && validWords != nil
            ? Text(", ").foregroundStyle(textColor)
            : nil
        
        let noWordsLabel = invalidWords == nil && validWords == nil
            ? Text("(none present)").foregroundStyle(textColor)
            : nil
        
        let viewParts: [Text] = [label, invalidWords, commaBetweenWords, validWords, noWordsLabel].compactMap { $0 }
        viewParts.reduce(Text(""), +)
    }
    
    func buildInvalidWords() -> Text {
        let invalidWordsSplit = gameViewModel.boardState.currentInvalidWords.split(separator: ", ")
        var textBuilder: [Text] = []
        
        for index in 0..<invalidWordsSplit.count {
            let splitWord = String(describing: invalidWordsSplit[index]).split(separator: " ")
            
            textBuilder.append(Text(splitWord[0]).foregroundStyle(textColor).underline(true))
            textBuilder.append(Text(" " + splitWord[1]).foregroundStyle(textColor).underline(false))
            
            if (index + 1 < invalidWordsSplit.count) {
                textBuilder.append(Text(", ").foregroundStyle(textColor).underline(false))
            }
        }
        
        return textBuilder.reduce(Text(""), +)
    }
    
    func snapshot<Content: View>(of view: Content, scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        let renderer = ImageRenderer(content: view)
        renderer.scale = scale
        return renderer.uiImage
    }
}
