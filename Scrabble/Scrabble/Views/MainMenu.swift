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
                case .boardSelector:
                    BoardSelectorView(appViewModel: appViewModel)
                case .multiplayer:
                    Text("MULTIPLAYER")
                case .game:
                    GameView(appViewModel: appViewModel)
            }
        }
        // TODO: add an extension method for this
        .confirmationDialog(popupManager.confirmationDialogOptions.message,
                             isPresented: $popupManager.showConfirmationDialog,
                             titleVisibility: popupManager.confirmationDialogOptions.displayTitle ? .visible : .hidden) {
             Button("Confirm", role: .destructive) {
                 popupManager.confirmationDialogOptions.confirmAction()
             }
             
             Button("Cancel", role: .cancel) {
                 popupManager.confirmationDialogOptions.cancelAction()
             }
         }
         .actionSheet(isPresented: $popupManager.showActionSheet) {
             ActionSheet(title: Text(popupManager.actionSheetOptions.title),
                         message: Text(popupManager.actionSheetOptions.message),
                         buttons: popupManager.actionSheetOptions.buttons)
         }
         .toast(isPresenting: $popupManager.showToast,
                duration: popupManager.toastOptions.toastDuration,
                tapToDismiss: true) {
             AlertToast(displayMode: .alert,
                        type: popupManager.toastOptions.toastType,
                        title: popupManager.toastOptions.toastText,
                        style: .style(backgroundColor: popupManager.toastOptions.toastColor))
         }
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
                
                Image(uiImage: BoardIdentifier.getImage(appViewModel.boardIdentifier))
                    .resizable()
                    .scaledToFit()
                    .frame(width: scaledWidth, height: scaledWidth)
                    .border(.gray)
                    .padding(.bottom, 4)
                
                Button(action: {
                    appViewModel.currentPage = .boardSelector
                }) {
                    Text("Single Player")
                        .frame(maxWidth: scaledWidth, maxHeight: MainMenu.buttonHeight)
                }
                .contentShape(Rectangle())
                .border(.gray)
                .padding(.horizontal, 4)
                
                Button(action: {
                    popupManager.displayToast(text: "Not implemented", color: .red)
                }) {
                    Text("Multiplayer")
                        .frame(maxWidth: scaledWidth, maxHeight: MainMenu.buttonHeight)
                }
                .contentShape(Rectangle())
                .border(.gray)
                .padding(.horizontal, 4)
                
                Button(action: {
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
