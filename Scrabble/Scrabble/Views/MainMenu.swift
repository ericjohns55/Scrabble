//
//  MainMenu.swift
//  Scrabble
//
//  Created by Eric Johns on 6/21/25.
//

import SwiftUI
import AlertToast

struct MainMenu: View {
    public static let buttonHeight: CGFloat = 60
    
    @EnvironmentObject var appViewModel: AppViewModel
    
    @StateObject private var popupManager = PopupManager()
    
    @ViewBuilder
    var body: some View {
        VStack {
            switch (appViewModel.currentPage) {
                case .mainMenu:
                    MainMenuView()
                case .singleplayer:
                    SingleplayerView(appViewModel: appViewModel)
                case .multiplayer:
                    MultiplayerAuthenticatorView(appViewModel: appViewModel)
                case .stats:
                    StatsView(appViewModel: appViewModel)
            }
        }
        .withPopupManager(popupManager)
    }
    
    @ViewBuilder
    func MainMenuView() -> some View {
        GeometryReader { geo in
            let scaledWidth = geo.size.width * 0.75
            
            VStack(spacing: 12) {
                Text("Temporary Name")
                    .foregroundStyle(.white)
                    .font(.title)
                    .bold()
                
                Image(uiImage: BoardIdentifier.getImage(.diamond11))
                    .resizable()
                    .scaledToFit()
                    .frame(width: scaledWidth, height: scaledWidth)
                    .border(.gray)
                    .padding(.bottom, 4)
                
                Button(action: {
                    appViewModel.currentPage = .singleplayer
                }) {
                    Text("Single Player")
                        .frame(maxWidth: scaledWidth, maxHeight: MainMenu.buttonHeight)
                }
                .contentShape(Rectangle())
                .border(.gray)
                .padding(.horizontal, 4)
                
                Button(action: {
                    appViewModel.currentPage = .multiplayer
                }) {
                    Text("Multiplayer")
                        .frame(maxWidth: scaledWidth, maxHeight: MainMenu.buttonHeight)
                }
                .contentShape(Rectangle())
                .border(.gray)
                .padding(.horizontal, 4)
                
                Button(action: {
//                    appViewModel.currentPage = .stats
                    popupManager.displayToast(text: "Not implemented", color: .red)
                }) {
                    Text("View Stats")
                        .frame(maxWidth: scaledWidth, maxHeight: MainMenu.buttonHeight)
                }
                .contentShape(Rectangle())
                .border(.gray)
                .padding(.horizontal, 4)
            }
            .frame(width: geo.size.width, alignment: .center)
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
    }
}
