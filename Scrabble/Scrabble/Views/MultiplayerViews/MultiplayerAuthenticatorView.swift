//
//  MultiplayerView.swift
//  Scrabble
//
//  Created by Eric Johns on 6/28/25.
//

import SwiftUI
import AlertToast

enum AuthStatus {
    case offline, unauthorized, authorized
}

enum AuthTab {
    case login, register
}

enum FocusedTextField {
    case username, password, confirmPassword
}

struct MultiplayerAuthenticatorView: View {
    private var appViewModel: AppViewModel
    private let scrabbleClient: ScrabbleClient
    
    private let inputColor = Color(red: 0.05, green: 0.05, blue: 0.05)
    private let modalColor = Color(red: 0.12, green: 0.12, blue: 0.12)
    
    @State private var AuthStatus: AuthStatus = .unauthorized
    @State private var selectedTab: AuthTab = .login
    
    @State private var pingingServer: Bool = false
    
    @State private var currentUser: Player? = nil
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var rememberUser: Bool = false
    @State private var usernameTaken: Bool = false
    
    @StateObject private var popupManager = PopupManager()
    
    @FocusState private var focusedTextField: FocusedTextField?
    
    var usernameLengthValid: Bool {
        return username.count >= 3 && username.count <= 32
    }
    
    var validCharacters: Bool {
        return username.range(of: "^[a-zA-Z0-9_\\-\\.]+$", options: .regularExpression) != nil
    }
    
    var loginRegisterButtonsDisabled: Bool {
        if (selectedTab == .register) {
            return !usernameLengthValid || !validCharacters || password.isEmpty || confirmPassword != password || usernameTaken
        } else {
            return username.isEmpty || password.isEmpty
        }
    }
    
    init(appViewModel: AppViewModel) {
        self.appViewModel = appViewModel
        
        username = KeychainHelper.shared.read("lastAuthenticatedPlayer") as String? ?? ""
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
            switch (AuthStatus) {
                // TODO: check for auth in pinging view and skip online_unauthed if good
                case .offline:
                    NoConnectionView()
                case .unauthorized:
                    LoginOrRegisterView()
                case .authorized:
                    AuthedMultiplayerView(
                        appViewModel: appViewModel,
                        scrabbleClient: scrabbleClient,
                        currentUser: currentUser!,
                        logoutCallback: {
                            self.AuthStatus = .unauthorized
                            self.scrabbleClient.removeCredentials()
                            self.currentUser = nil
                        }
                    )
            }
        }
        .ignoresSafeArea(.keyboard)
        .withPopupManager(popupManager)
        .task {
            await pingServer()
            
            if (AuthStatus == .unauthorized && scrabbleClient.hasRefreshToken()) {
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
                Text("Authentication")
                    .foregroundStyle(.white)
                    .font(.title)
                    .bold()
                
                VStack(spacing: 0) {
                    Picker("", selection: $selectedTab) {
                        Text("Login").tag(AuthTab.login)
                        Text("Register").tag(AuthTab.register)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    
                    VStack(spacing: 12) {
                        TextField("Username", text: $username)
                            .focused($focusedTextField, equals: .username)
                            .submitLabel(.next)
                            .padding(12)
                            .background(inputColor)
                            .cornerRadius(8)
                            .textInputAutocapitalization(.none)
                            .autocorrectionDisabled()
                            .onChange(of: username) {
                                if (selectedTab == .register) {
                                    Task {
                                        usernameTaken = await scrabbleClient.isNameTaken(proposedName: username)
                                    }
                                }
                            }
                        
                        SecureField("Password", text: $password)
                            .focused($focusedTextField, equals: .password)
                            .submitLabel(.next)
                            .padding(12)
                            .background(inputColor)
                            .cornerRadius(8)
                        
                        if (selectedTab == .login) {
                            Toggle(isOn: $rememberUser) {
                                Text("Remember me")
                            }
                            .frame(width: buttonSize)
                        }
                        
                        if selectedTab == .register {
                            SecureField("Confirm Password", text: $confirmPassword)
                                .focused($focusedTextField, equals: .confirmPassword)
                                .submitLabel(.next)
                                .padding(12)
                                .background(inputColor)
                                .cornerRadius(8)
                            
                            UsernameLengthView()
                            UsernameValid()
                            PasswordsMatch()
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
                        .disabled(loginRegisterButtonsDisabled)
                        .padding(.bottom, 12)
                    }
                    .padding(.horizontal, 12)
                    .onSubmit {
                        switch focusedTextField {
                        case .username:
                            focusedTextField = .password
                        case .password:
                            if (selectedTab == .register) {
                                focusedTextField = .confirmPassword
                            } else {
                                focusedTextField = nil
                            }
                        default:
                            break
                        }
                    }
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
    func UsernameLengthView() -> some View {
        if (username.count < 3) {
            Label("Username is too short", systemImage: "x.circle.fill")
                .foregroundStyle(.red)
        } else if (username.count > 32) {
            Label("Username is too long", systemImage: "x.circle.fill")
                .foregroundStyle(.red)
        } else {
            Label("Username length valid", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
        }
    }
    
    @ViewBuilder
    func UsernameValid() -> some View {
        if (!validCharacters) {
            Label("Username has invalid characters", systemImage: "x.circle.fill")
                .foregroundStyle(.red)
        } else if (usernameTaken) {
            Label("Username is taken", systemImage: "x.circle.fill")
                .foregroundStyle(.red)
        } else {
            Label("Username is valid", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
        }
    }
    
    @ViewBuilder
    func PasswordsMatch() -> some View {
        if (password != confirmPassword) {
            Label("Passwords do not match", systemImage: "x.circle.fill")
                .foregroundStyle(.red)
        } else {
            Label("Passwords match", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
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
                
                if (pingingServer) {
                    ProgressView()
                }
                
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
        let tokensResponse = await scrabbleClient.login(username: username, password: password)
        
        if (tokensResponse.data == nil) {
            popupManager.displayToast(text: "Invalid username or password", color: .red)
            
            scrabbleClient.removeCredentials()
            self.currentUser = nil
        } else {
            await updateSelf()
            
            if (rememberUser) {
                KeychainHelper.shared.set(tokensResponse.data!.refreshToken, forKey: "refreshToken")
                KeychainHelper.shared.set(currentUser?.username, forKey: "lastAuthenticatedPlayer")
            }
        }
        
        self.password = ""
    }
    
    private func registerCallback() async {
        guard password == confirmPassword else {
            popupManager.displayToast(text: "Passwords do not match", color: .red)
            return
        }
        
        let tokensResponse = await scrabbleClient.register(username: username, password: password)
        
        if (tokensResponse.data == nil) {
            popupManager.displayToast(text: tokensResponse.errorMessage, color: .red)
            
            scrabbleClient.removeCredentials()
            self.currentUser = nil
        } else {
            await updateSelf()
            
            KeychainHelper.shared.set(tokensResponse.data!.refreshToken, forKey: "refreshToken")
            KeychainHelper.shared.set(currentUser?.username, forKey: "lastAuthenticatedPlayer")
        }
        
        self.password = ""
        self.confirmPassword = ""
    }
    
    private func pingServer() async {
        pingingServer = true
        
        if (await scrabbleClient.pingServer()) {
            AuthStatus = .unauthorized
        } else {
            AuthStatus = .offline
        }
        
        pingingServer = false
    }
    
    private func updateSelf() async {
        let serverResponse = await scrabbleClient.getSelf()
        
        if let self = serverResponse.data {
            currentUser = self
            
            if (scrabbleClient.isAuthenticated()) {
                AuthStatus = .authorized
            }
        } else {
            currentUser = nil
        }
    }
}
