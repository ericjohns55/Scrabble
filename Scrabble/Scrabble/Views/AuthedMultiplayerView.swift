//
//  AuthedMultiplayerView.swift
//  Scrabble
//
//  Created by Eric Johns on 6/30/25.
//

import SwiftUI
import AlertToast

struct AuthedMultiplayerView: View {
    private var appViewModel: AppViewModel
    private var scrabbleClient: ScrabbleClient
    private var currentUser: Player
    private var logoutCallback: () -> Void
    
    init(appViewModel: AppViewModel, scrabbleClient: ScrabbleClient, currentUser: Player, logoutCallback: @escaping () -> Void) {
        self.appViewModel = appViewModel
        self.scrabbleClient = scrabbleClient
        self.currentUser = currentUser
        self.logoutCallback = logoutCallback
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text(currentUser.username)
                    .foregroundStyle(.white)
                    .font(.title)
                    .bold()
                    .padding(12)
                
                Text("UUID: \(currentUser.uuid.uuidString)")
                    .foregroundStyle(.white)
                    .font(.caption)
                    .bold()
                    .padding(12)
                
                Text("Registered at: \(currentUser.createdDate.toLocalString())")
                    .foregroundStyle(.white)
                    .font(.caption)
                    .bold()
                    .padding(12)
                
                Button(action: {
                    appViewModel.currentPage = .mainMenu
                }) {
                    Text("Back to Main Menu")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(width: geometry.size.width * 0.5, height: geometry.size.width * 0.15)
                .contentShape(Rectangle())
                .border(.gray)
                .padding(.top, 64)
                
                Button(action: {
                    logoutCallback()
                }) {
                    Text("Log Out")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(width: geometry.size.width * 0.5, height: geometry.size.width * 0.15)
                .contentShape(Rectangle())
                .border(.gray)
            }
            .frame(width: geometry.size.width, alignment: .center)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
}
