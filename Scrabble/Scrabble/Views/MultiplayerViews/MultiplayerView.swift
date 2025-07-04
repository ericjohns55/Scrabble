//
//  AuthedMultiplayerView.swift
//  Scrabble
//
//  Created by Eric Johns on 6/30/25.
//

import SwiftUI
import AlertToast

enum ExtraRowButtons {
    case decline, accept, forfeit
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
        ZStack {
            VStack {
                Section {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            if (!multiplayerViewModel.pendingGames.isEmpty) {
                                GameListBuilder(titleText: "Pending Games", gameList: multiplayerViewModel.pendingGames, extraButtons: [.accept, .decline])
                            }
                            
                            if (!multiplayerViewModel.currentPlayersTurn.isEmpty) {
                                GameListBuilder(titleText: "Your Turn", gameList: multiplayerViewModel.currentPlayersTurn, extraButtons: [.forfeit])
                            }
                            
                            if (!multiplayerViewModel.otherPlayersTurn.isEmpty) {
                                GameListBuilder(titleText: "Opponent's Turn", gameList: multiplayerViewModel.otherPlayersTurn, extraButtons: [.forfeit])
                            }
                            
                            if (!multiplayerViewModel.completedGames.isEmpty) {
                                GameListBuilder(titleText: "Completed Games", gameList: multiplayerViewModel.completedGames)
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
        .withPopupManager(popupManager)
        .task {
            await multiplayerViewModel.loadMultiplayerMenuData()
        }
    }
    
    @ViewBuilder
    func GameListBuilder(titleText: String, gameList: [Game], extraButtons: [ExtraRowButtons] = []) -> some View {
        VStack(spacing: 8) {
            Text(titleText)
                .font(.title2)
                .foregroundStyle(.white)
                .bold()
                
            VStack(alignment: .leading) {
                ForEach(gameList.indices, id: \.self) { index in
                    GameRow(gameList[index], extraButtons: extraButtons)
                    
                    if (index < gameList.count - 1) {
                        Divider()
                    }
                }
            }
        }
        .padding(.bottom, 12)
    }
    
    @ViewBuilder
    func GameRow(_ game: Game, extraButtons: [ExtraRowButtons]) -> some View {
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
                            Task {
                                _ = await scrabbleClient.forfeitGame(gameId: game.uuid)
                                await multiplayerViewModel.fetchGames()
                            }
                        }
                }
                
            }
        }
        .frame(height: rowHeight) 
        .contentShape(Rectangle())
        .onTapGesture {
            print("TODO: Load game \(game.uuid.uuidString)")
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
}
