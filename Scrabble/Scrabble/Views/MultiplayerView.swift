//
//  MultiplayerView.swift
//  Scrabble
//
//  Created by Eric Johns on 6/28/25.
//

import SwiftUI
import AlertToast

enum ServerStatus {
    case online, pinging, offline
}

struct MultiplayerView: View {
    private var appViewModel: AppViewModel
    private let scrabbleClient: ScrabbleClient
    
    @State private var serverStatus: ServerStatus = .pinging
    @State private var currentUser: Player? = nil
    @State private var username: String = ""
    @State private var password: String = ""
    
    @StateObject private var popupManager = PopupManager()
    
    var buttonsEnabled: Bool {
        username.isEmpty || password.isEmpty
    }
    
    init(appViewModel: AppViewModel) {
        self.appViewModel = appViewModel
        self.scrabbleClient = ScrabbleClient(serverUrl: "") // TODO: online/offline checks on requests
    }
    
    var body: some View {
        Group {
            switch (serverStatus) {
                case .offline:
                    NoConnectionView()
                case .pinging:
                    PingingView()
                case .online:
                    LoginView()
            }
        }
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
        .task {
            await pingServer()
        }
    }
    
    func pingServer() async {
        serverStatus = .pinging
        
        if (await scrabbleClient.pingServer()) {
            serverStatus = .online
        } else {
            serverStatus = .offline
        }
    }
    
    func updateSelf() async {
        let serverResponse = await scrabbleClient.getSelf()
        
        if let self = serverResponse.data {
            currentUser = self
        } else {
            currentUser = nil
        }
    }
    
    @ViewBuilder
    func PingingView() -> some View {
        VStack {
            Text("Waiting for connection...")
                .foregroundStyle(.white)
                .font(.title)
                .bold()
            
            ProgressView()
        }
    }
    
    @ViewBuilder
    func NoConnectionView() -> some View {
        GeometryReader { geo in
            let scaledWidth = geo.size.width * 0.5
            
            VStack(spacing: 12) {
                Text("Could not connect to server")
                    .foregroundStyle(.red)
                    .font(.title)
                    .bold()
                
                Button(action: {
                    Task {
                        await pingServer()
                    }
                }) {
                    Text("Refresh")
                        .frame(maxWidth: scaledWidth, maxHeight: MainMenu.buttonHeight)
                }
                .contentShape(Rectangle())
                .border(.gray)
                .padding(.horizontal, 4)
                
                Button(action: {
                    appViewModel.currentPage = .mainMenu
                }) {
                    Text("Back to Main Menu")
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
    
    @ViewBuilder
    func LoginView() -> some View {
        GeometryReader { geometry in
            let buttonSize = geometry.size.width * 0.45
            
            VStack(alignment: .center) {
                Text("Please login or register")
                    .foregroundStyle(.white)
                    .font(.title)
                    .bold()
                    .padding(24)
                
                TextField("Username", text: $username)
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                    .textInputAutocapitalization(.none)
                    .autocorrectionDisabled()
                
                SecureField("Password", text: $password)
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                
                HStack {
                    Button(action: {
                        Task {
                            let loginSuccessful = await scrabbleClient.login(username: username, password: password)
                            
                            if (!loginSuccessful) {
                                popupManager.displayToast(text: "Invalid username or password", color: .red)
                                
                                scrabbleClient.removeCredentials()
                                self.currentUser = nil
                            } else {
                                await updateSelf()
                            }
                            
                            self.password = ""
                        }
                    }) {
                        Text("Login")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(width: buttonSize, height: geometry.size.width * 0.15)
                    .contentShape(Rectangle())
                    .border(.gray)
                    .disabled(buttonsEnabled)
                    
                    Button(action: {
                        Task {
                            let response = await scrabbleClient.register(username: username, password: password)
                            
                            if (response.data == nil) {
                                popupManager.displayToast(text: response.errorMessage, color: .red)
                                
                                scrabbleClient.removeCredentials()
                                self.currentUser = nil
                            } else {
                                await updateSelf()
                            }
                            
                            self.password = ""
                        }
                    }) {
                        Text("Register")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(width: buttonSize, height: geometry.size.width * 0.15)
                    .contentShape(Rectangle())
                    .border(.gray)
                    .disabled(buttonsEnabled)
                }
                .padding(.vertical, 8)
                
                Text("Current User: \(currentUser?.uuid ?? "Not authenticated")")
                    .foregroundStyle(.white)
                    .font(.caption)
                    .bold()
                    .padding(24)
                
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
            }
            .frame(width: geometry.size.width, alignment: .center)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
}
