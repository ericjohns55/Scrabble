//
//  GameCreationView.swift
//  Scrabble
//
//  Created by Eric Johns on 7/3/25.
//

import SwiftUI

struct GameCreationView: View {
    let multiplayerViewModel: MultiplayerViewModel
    
    @State private var selectedPlayerUuid: UUID? = nil
    @State private var selectedBoard: BoardIdentifier = .diamond11
    @State private var popupManager = PopupManager()
    
    @Binding var isPresented: Bool
    
    init(multiplayerViewModel: MultiplayerViewModel, isPresented: Binding<Bool>) {
        self.multiplayerViewModel = multiplayerViewModel
        self._isPresented = isPresented
        self._selectedPlayerUuid = State(initialValue: multiplayerViewModel.allPlayers.first?.uuid)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("New Game")
                .font(.title2)
                .foregroundStyle(.white)
                .bold()
            
            LabeledContent {
                Picker("Opponent", selection: $selectedPlayerUuid) {
                    ForEach(multiplayerViewModel.allPlayers, id: \.uuid) { player in
                        Text(player.username).tag(player.uuid)
                    }
                }
                .pickerStyle(.menu)
                .onAppear() {
                    self.selectedPlayerUuid = multiplayerViewModel.allPlayers.first!.uuid
                }
            } label: {
                Text("Opponent")
            }
            
            LabeledContent {
                Picker("Board Identifier", selection: $selectedBoard) {
                    ForEach(BoardIdentifier.allCases, id: \.self) { identifier in
                        Text(BoardIdentifier.getLabel(identifier))
                    }
                }
                .pickerStyle(.menu)
            } label: {
                Text("Board")
            }
            
            VStack(spacing: 8) {
                Image(String(describing: selectedBoard))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .border(.gray)
                
                Text("Board Preview")
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
            }
            
            Button(action: {
                Task { 
                    if (await multiplayerViewModel.createGame(opponentUuid: selectedPlayerUuid!, board: selectedBoard)) {
                        isPresented = false
                        
                        await multiplayerViewModel.fetchGames()
                    } else {
                        popupManager.displayToast(text: "Failed to create game", color: .red)
                    }
                }
            }) {
                Text("Create Game")
                    .frame(maxWidth: .infinity, maxHeight: MainMenu.buttonHeight)
            }
            .disabled(selectedPlayerUuid == nil)
            .contentShape(Rectangle())
            .border(.gray)
            .padding(.horizontal, 24)
            
            Button(action: {
                isPresented = false
            }) {
                Text("Cancel")
                    .frame(maxWidth: .infinity, maxHeight: MainMenu.buttonHeight)
            }
            .contentShape(Rectangle())
            .border(.gray)
            .padding(.horizontal, 24)
            
        }
        .withPopupManager(popupManager)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
                .shadow(radius: 20)
        )
        .padding(.horizontal, 48)
    }
}
