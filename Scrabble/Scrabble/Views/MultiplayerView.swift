//
//  MultiplayerView.swift
//  Scrabble
//
//  Created by Eric Johns on 6/28/25.
//

import SwiftUI

struct MultiplayerView: View {
    private var appViewModel: AppViewModel
    private let scrabbleClient: ScrabbleClient
    
    @State private var currentUser: Player? = nil
    @State private var username: String = "player1"
    @State private var password: String = "abc123"
    
    init(appViewModel: AppViewModel) {
        self.appViewModel = appViewModel
        self.scrabbleClient = ScrabbleClient(serverUrl: "")
    }
    
    var body: some View {
        GeometryReader { geometry in
            let halfWidth = geometry.size.width * 0.5
            
            VStack(alignment: .leading) {
                Text("Please login")
                    .foregroundStyle(.white)
                    .font(.title)
                    .bold()
                    .padding(24)
                
                LabeledContent {
                    TextField("Username", text: $username)
                } label: {
                    Text("Username")
                }
                
                LabeledContent {
                    TextField("Password", text: $password)
                } label: {
                    Text("Password")
                }
                
                Button(action: {
                    Task {
                        try await scrabbleClient.login(username: username, password: password)
                        currentUser = try await scrabbleClient.getSelf()
                    }
                }) {
                    Text("Login")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(width: halfWidth, height: geometry.size.width * 0.15)
                .contentShape(Rectangle())
                .border(.gray)
                .padding(.vertical, 8)
                
                Button(action: {
                    appViewModel.currentPage = .mainMenu
                }) {
                    Text("Back to Main Menu")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(width: halfWidth, height: geometry.size.width * 0.15)
                .contentShape(Rectangle())
                .border(.gray)
                .padding(.vertical, 8)
                
                Text("Current User: \(currentUser?.uuid ?? "Not authenticated")")
                    .foregroundStyle(.white)
                    .font(.caption)
                    .bold()
                    .padding(24)
            }
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
}
