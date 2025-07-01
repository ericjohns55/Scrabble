//
//  MultiplayerView.swift
//  Scrabble
//
//  Created by Eric Johns on 6/28/25.
//

import SwiftUI
import AlertToast

enum ServerPage {
    case online_authed, online_unauthed, pinging, offline
}

enum AuthTab {
    case login, register
}

struct MultiplayerView: View {
    private var appViewModel: AppViewModel
    private let scrabbleClient: ScrabbleClient
    
    private let inputColor = Color(red: 0.05, green: 0.05, blue: 0.05)
    private let modalColor = Color(red: 0.12, green: 0.12, blue: 0.12)
    
    @State private var serverPage: ServerPage = .pinging
    @State private var currentUser: Player? = nil
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var selectedTab: AuthTab = .login
    
    @StateObject private var popupManager = PopupManager()
    
    var buttonsEnabled: Bool {
        username.isEmpty || password.isEmpty
    }
    
    init(appViewModel: AppViewModel) {
        self.appViewModel = appViewModel
        
        let refreshToken = KeychainHelper.shared.read("refreshToken") as String?
        let serverUrl = ""
                
        if (refreshToken != nil) {
            self.scrabbleClient = ScrabbleClient(serverUrl: serverUrl, refreshToken: refreshToken!)
        } else {
            self.scrabbleClient = ScrabbleClient(serverUrl: serverUrl)
        }
    }
    
    var body: some View {
        Group {
            switch (serverPage) {
                // TODO: check for auth in pinging view and skip online_unauthed if good
                case .offline:
                    NoConnectionView()
                case .pinging:
                    PingingView()
                case .online_unauthed:
                    LoginOrRegisterView()
                case .online_authed:
                    AuthedMultiplayerView(
                        appViewModel: appViewModel,
                        scrabbleClient: scrabbleClient,
                        currentUser: currentUser!,
                        logoutCallback: {
                            self.serverPage = .online_unauthed
                            self.scrabbleClient.removeCredentials()
                            self.currentUser = nil
                        }
                    )
            }
        }
        .withPopupManager(popupManager)
        .task {
            await pingServer()
            
            if (serverPage == .online_unauthed && scrabbleClient.hasRefreshToken()) {
                if (await scrabbleClient.refreshTokens()) {
                    await updateSelf()
                }
            }
        }
    }
    
    @ViewBuilder
    func LoginOrRegisterView() -> some View {
        GeometryReader { geometry in
            let buttonSize = geometry.size.width * 0.5
            
            VStack {
                VStack(spacing: 0) {
                    Picker("", selection: $selectedTab) {
                        Text("Login").tag(AuthTab.login)
                        Text("Register").tag(AuthTab.register)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    
                    VStack(spacing: 12) {
                        TextField("Username", text: $username)
                            .padding(12)
                            .background(inputColor)
                            .cornerRadius(8)
                            .textInputAutocapitalization(.none)
                            .autocorrectionDisabled()
                        
                        SecureField("Password", text: $password)
                            .padding(12)
                            .background(inputColor)
                            .cornerRadius(8)
                        
                        if selectedTab == .register {
                            SecureField("Confirm Password", text: $confirmPassword)
                                .padding(12)
                                .background(inputColor)
                                .cornerRadius(8)
                        }
                        
                        Button(action: {
                            Task {
                                if (selectedTab == .login) {
                                    await loginCallback()
                                } else {
                                    await registerCallback()
                                }
                            }
                        }) {
                            Text(selectedTab == .login ? "Login" : "Register")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .frame(width: buttonSize, height: MainMenu.buttonHeight)
                        .contentShape(Rectangle())
                        .border(.gray)
                        .disabled(buttonsEnabled)
                        .padding(.bottom, 12)
                    }
                    .padding(.horizontal, 12)
                }
                .background(modalColor)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                Button(action: {
                    appViewModel.currentPage = .mainMenu
                }) {
                    Text("Back to Main Menu")
                        .frame(maxWidth: buttonSize, maxHeight: MainMenu.buttonHeight)
                }
                .contentShape(Rectangle())
                .border(.gray)
                .padding(.vertical, 48)
                .padding(.horizontal, 4)
            }
            .frame(width: geometry.size.width * 0.95, alignment: .center)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
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
    
    private func loginCallback() async {
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
    
    private func registerCallback() async {
        guard password == confirmPassword else {
            popupManager.displayToast(text: "Passwords do not match", color: .red)
            return
        }
        
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
    
    private func pingServer() async {
        serverPage = .pinging
        
        if (await scrabbleClient.pingServer()) {
            serverPage = .online_unauthed
        } else {
            serverPage = .offline
        }
    }
    
    private func updateSelf() async {
        let serverResponse = await scrabbleClient.getSelf()
        
        if let self = serverResponse.data {
            currentUser = self
            
            if (scrabbleClient.isAuthenticated()) {
                serverPage = .online_authed
            }
        } else {
            currentUser = nil
        }
    }
}
