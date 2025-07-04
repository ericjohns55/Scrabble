//
//  AuthedMultiplayerView.swift
//  Scrabble
//
//  Created by Eric Johns on 6/30/25.
//

import SwiftUI
import AlertToast

enum ExtraRowButtons {
    case decline, accept, forfeit, hide
}

struct AuthedMultiplayerView: View {
    private let rowHeight: CGFloat = 64
    
    private var appViewModel: AppViewModel
    private var scrabbleClient: ScrabbleClient
    private var currentUser: Player
    private var logoutCallback: () -> Void
    
    @State private var showCreationModal: Bool = false
    
    @StateObject private var popupManager = PopupManager()
    @StateObject private var multiplayerViewModel = MultiplayerViewModel()
    
    init(appViewModel: AppViewModel, scrabbleClient: ScrabbleClient, currentUser: Player, logoutCallback: @escaping () -> Void) {
        self.appViewModel = appViewModel
        self.scrabbleClient = scrabbleClient
        self.currentUser = currentUser
        self.logoutCallback = logoutCallback
        
        let multiplayerViewModel = MultiplayerViewModel(scrabbleClient: scrabbleClient, currentPlayer: currentUser)
        self._multiplayerViewModel = StateObject(wrappedValue: multiplayerViewModel)
    }
    
    var body: some View {
        VStack {
            if (multiplayerViewModel.currentGame == nil) {
                MultiplayerHomeScreen()
            } else {
                if (multiplayerViewModel.inGame) {
                    GameView(appViewModel: appViewModel, multiplayerViewModel: multiplayerViewModel)
                } else {
                    MultiplayerGameSummaryScreen()
                }
            }
        }
        .withPopupManager(popupManager)
        .task {
            await multiplayerViewModel.loadMultiplayerMenuData()
        }
    }
    
    @ViewBuilder
    func MultiplayerHomeScreen() -> some View {
        ZStack {
            VStack {
                Section {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            if (!multiplayerViewModel.pendingGames.isEmpty) {
                                GameListBuilder(
                                    titleText: "Pending Games",
                                    gameList: multiplayerViewModel.pendingGames,
                                    extraButtons: [.accept, .decline],
                                    tapCallback: { game in
                                        popupManager.displayToast(text: "You must accept or decline the game first", color: .red)
                                    })
                            }
                            
                            if (!multiplayerViewModel.currentPlayersTurn.isEmpty) {
                                GameListBuilder(
                                    titleText: "Your Turn",
                                    gameList: multiplayerViewModel.currentPlayersTurn,
                                    extraButtons: [.forfeit],
                                    tapCallback: { game in
                                        popupManager.displayConfirmationDialog(
                                            message: "Once you start the game you cannot exit it (this is temporary)",
                                            displayTitle: true,
                                            confirmAction: {
                                                multiplayerViewModel.inGame = true
                                                multiplayerViewModel.currentGame = game
                                            })
                                    })
                            }
                            
                            if (!multiplayerViewModel.otherPlayersTurn.isEmpty) {
                                GameListBuilder(
                                    titleText: "Opponent's Turn",
                                    gameList: multiplayerViewModel.otherPlayersTurn,
                                    extraButtons: [.forfeit],
                                    tapCallback: { game in
                                        multiplayerViewModel.inGame = false
                                        multiplayerViewModel.currentGame = game
                                    })
                            }
                            
                            if (!multiplayerViewModel.completedGames.isEmpty) {
                                GameListBuilder(
                                    titleText: "Completed Games",
                                    gameList: multiplayerViewModel.completedGames,
                                    extraButtons: [.hide],
                                    tapCallback: { game in
                                        multiplayerViewModel.inGame = false
                                        multiplayerViewModel.currentGame = game
                                    })
                            }
                            
                            if (multiplayerViewModel.allGamesEmpty()) {
                                Text("No existing games found")
                                    .foregroundStyle(.white)
                                    .font(.title)
                                    .bold()
                                
                                Text("Create a new game to get started")
                                    .foregroundStyle(.white)
                                    .font(.title3)
                                    .bold()
                            }
                        }
                    }
                    .padding()
                    .refreshable {
                        await multiplayerViewModel.fetchGames()
                    }
                    
                    Button(action: {
                        showCreationModal = true
                    }) {
                        Text("Create Game")
                            .frame(maxWidth: .infinity, maxHeight: MainMenu.buttonHeight)
                    }
                    .contentShape(Rectangle())
                    .border(.gray)
                    .padding(.horizontal, 24)
                } header: {
                    TopBar()
                }
            }
            
            if (showCreationModal) {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showCreationModal = false
                    }
                
                GameCreationView(multiplayerViewModel: multiplayerViewModel, isPresented: $showCreationModal)
                    .transition(.scale)
                    .zIndex(1)
            }
        }
    }
    
    @ViewBuilder
    func GameListBuilder(titleText: String, gameList: [Game], extraButtons: [ExtraRowButtons] = [], tapCallback: ((Game) -> Void)? = nil) -> some View {
        VStack(spacing: 8) {
            Text(titleText)
                .font(.title2)
                .foregroundStyle(.white)
                .bold()
                
            VStack(alignment: .leading) {
                ForEach(gameList.indices, id: \.self) { index in
                    GameRow(gameList[index], extraButtons: extraButtons, tapCallback: tapCallback)
                    
                    if (index < gameList.count - 1) {
                        Divider()
                    }
                }
            }
        }
        .padding(.bottom, 12)
    }
    
    @ViewBuilder
    func GameRow(_ game: Game, extraButtons: [ExtraRowButtons], tapCallback: ((Game) -> Void)? = nil) -> some View {
        HStack {
            Image(String(describing: game.boardIdentifier))
                .resizable()
                .scaledToFit()
                .frame(width: rowHeight, height: rowHeight)
            
            VStack(alignment: .leading) {
                Text(game.getOtherPlayer(currentPlayer: currentUser).username)
                    .font(.title2)
                    .foregroundStyle(.white)
                    .bold()
                
                Text(multiplayerViewModel.getStatusTextForGame(game: game))
                    .font(.subheadline)
                    .foregroundStyle(.white)
            }
            
            
            if (!extraButtons.isEmpty) {
                Spacer()
                
                let leadingPadding: CGFloat = extraButtons.count > 1 ? 8 : 0
                
                if (extraButtons.contains(.decline)) {
                    Image(systemName: "xmark")
                        .resizable()
                        .scaledToFill()
                        .frame(width: rowHeight / 2, height: rowHeight / 2)
                        .foregroundStyle(.red)
                        .padding(.leading, leadingPadding)
                        .onTapGesture {
                            Task {
                                _ = await scrabbleClient.declineGame(gameId: game.uuid)
                                await multiplayerViewModel.fetchGames()
                            }
                        }
                }
                
                if (extraButtons.contains(.accept)) {
                    Image(systemName: "checkmark")
                        .resizable()
                        .scaledToFill()
                        .frame(width: rowHeight / 2, height: rowHeight / 2)
                        .foregroundStyle(.green)
                        .padding(.leading, leadingPadding)
                        .onTapGesture {
                            Task {
                                _ = await scrabbleClient.acceptGame(gameId: game.uuid)
                                await multiplayerViewModel.fetchGames()
                            }
                        }
                }
                
                if (extraButtons.contains(.forfeit)) {
                    Image(systemName: "flag.slash")
                        .resizable()
                        .scaledToFill()
                        .frame(width: rowHeight / 2, height: rowHeight / 2)
                        .foregroundStyle(.red)
                        .padding(.leading, leadingPadding)
                        .onTapGesture {
                            popupManager.displayConfirmationDialog(message: "Are you sure you want to forfeit this game?", displayTitle: true, confirmAction: {
                                Task {
                                    _ = await scrabbleClient.forfeitGame(gameId: game.uuid)
                                    await multiplayerViewModel.fetchGames()
                                }
                            })
                        }
                }
                
                if (extraButtons.contains(.hide)) {
                    Image(systemName: "trash")
                        .resizable()
                        .scaledToFit()
                        .frame(width: rowHeight / 2, height: rowHeight / 2)
                        .foregroundStyle(.red)
                        .padding(.leading, leadingPadding)
                        .onTapGesture {
                            popupManager.displayConfirmationDialog(message: "Are you sure you want to delete this game result? This currently cannot be undone", displayTitle: true, confirmAction: {
                                Task {
                                    _ = await scrabbleClient.hideGame(gameId: game.uuid)
                                    await multiplayerViewModel.fetchGames()
                                }
                            })
                        }
                }
            }
        }
        .frame(height: rowHeight) 
        .contentShape(Rectangle())
        .onTapGesture {
            tapCallback?(game)
        }
    }
    
    @ViewBuilder
    func TopBar() -> some View {
        VStack(spacing: 8) {
            ZStack {
                HStack {
                    Button {
                        appViewModel.currentPage = .mainMenu
                    } label: {
                        Image(systemName: "arrow.backward.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                            .foregroundStyle(.white)
                    }
                    .padding(.leading, 16)
                    
                    Spacer()
                    
                    Menu {
                        Button("View Info", action: {
                            let userInfo = "Username: \(currentUser.username)\nDate Registered: \(currentUser.createdDate.toLocalString())\nUUID: \(currentUser.uuid.uuidString)"
                            popupManager.displayAlert(title: "User Information", message: userInfo)
                        })
                        
                        Button("Log Out", action: {
                            logoutCallback()
                        })
                    } label: {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                            .foregroundStyle(.white)
                    }
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .padding(.trailing, 16)
                }
                
                Text(currentUser.username)
                    .foregroundStyle(.white)
                    .bold()
                    .font(.title2)
            }
            
            Divider()
                .frame(height: 1)
                .background(Color.gray)
                .padding(.horizontal, 4)
        }

    }
    
    @ViewBuilder
    func MultiplayerGameSummaryScreen() -> some View {
        let currentGame = multiplayerViewModel.currentGame!
        let opponent = currentGame.getOtherPlayer(currentPlayer: currentUser)
        
        let currentPlayersMove = currentGame.getGameMove(player: currentUser)
        let opponentsMove = currentGame.getGameMove(player: opponent)
        
        let isTied = currentGame.gameTied != nil && currentGame.gameTied!
        let currentPlayerWinStatus = isTied || currentGame.winningPlayer?.id == currentUser.id
        let opposingPlayerWinStatus = isTied || currentGame.winningPlayer?.id == opponent.id
        
        VStack(spacing: 8) {
            VStack {
                if (currentGame.isCompleted()) {
                    Text("Game Complete!")
                        .foregroundStyle(.white)
                        .font(.title)
                        .bold()
                        .padding(.bottom, 24)
                    
                    if (currentGame.gameState == .forfeited && currentGame.winningPlayer != nil) {
                        let forfeitingPlayer = currentGame.getOtherPlayer(currentPlayer: currentGame.winningPlayer!)
                        
                        Text("\(forfeitingPlayer.username) forfeited!")
                            .foregroundStyle(.white)
                            .font(.title3)
                            .bold()
                        
                    } else if (currentGame.gameState == .declined) {
                        Text("\(opponent.username) declined the game!")
                            .foregroundStyle(.white)
                            .font(.title3)
                            .bold()
                    } else {
                        if (isTied) {
                            Text("Game ended in a tie!")
                                .foregroundStyle(.white)
                                .font(.title3)
                                .bold()
                        } else {
                            Text("\(currentGame.winningPlayer!.username) won!")
                                .foregroundStyle(.white)
                                .font(.title3)
                                .bold()
                        }
                        
                    }
                } else {
                    Text("Game still in progress")
                        .foregroundStyle(.white)
                        .font(.title)
                        .bold()
                }
            }
            .padding(.bottom, 24)
            
            let emptyMoveSuffix = currentGame.isCompleted() ? "never played" : "has not played yet"
            let colorOverride = currentGame.isCompleted() ? nil : Color.white
                        
            VStack {
                if let renderedMove = currentPlayersMove {
                    GameMoveView(gameMove: renderedMove, player: currentUser, isWinner: currentPlayerWinStatus, colorOverride: colorOverride)
                } else {
                    Text("You \(emptyMoveSuffix)")
                        .foregroundStyle(.white)
                        .font(.title3)
                }
            }
            
            VStack {
                if let renderedMove = opponentsMove {
                    GameMoveView(gameMove: renderedMove, player: opponent, isWinner: opposingPlayerWinStatus, colorOverride: colorOverride)
                } else {
                    Text("\(opponent.username) \(emptyMoveSuffix)")
                        .foregroundStyle(.white)
                        .font(.title3)
                }
            }
            
            Button(action: {
                multiplayerViewModel.currentGame = nil
            }) {
                Text("Back")
                    .frame(maxWidth: 200, maxHeight: MainMenu.buttonHeight)
            }
            .contentShape(Rectangle())
            .border(.gray)
            .padding(.horizontal, 4)
            .padding(.top, 48)
        }
    }
    
    @ViewBuilder
    func GameMoveView(gameMove: GameMove, player: Player, isWinner: Bool, gameInProgress: Bool = true, colorOverride: Color? = nil) -> some View {
        let textColor = colorOverride ?? (isWinner ? Color.green : Color.red)
        
        Text(player.username)
            .foregroundStyle(textColor)
            .font(.title2)
            .underline()
        
        Text("Words Played: \(gameMove.wordsPlayed)")
            .foregroundStyle(textColor)
            .font(.title2)
        
        Text("Final Score: \(gameMove.score)")
            .foregroundStyle(textColor)
            .font(.title2)
        
        Text("Tiles Played: \(gameMove.tilesPlayed)")
            .foregroundStyle(textColor)
            .font(.title2)
        
        Text("Moves Made: \(gameMove.movesMade)")
            .foregroundStyle(textColor)
            .font(.title2)
            .padding(.bottom, 24)
    }
}
