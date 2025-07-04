//
//  StatsView.swift
//  Scrabble
//
//  Created by Eric Johns on 7/4/25.
//

import SwiftUI

struct StatsView: View {
    private var appViewModel: AppViewModel
    
    init(appViewModel: AppViewModel) {
        self.appViewModel = appViewModel
    }
    
    var body: some View {
        Text("Not implemented")
            .foregroundStyle(.white)
            .font(.title)
            .bold()
            .padding(.vertical, 8)
        
        Button(action: {
            appViewModel.currentPage = .mainMenu
        }) {
            Text("Back to Main Menu")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .contentShape(Rectangle())
        .border(.gray)
        .padding(.vertical, 8)
    }
}
